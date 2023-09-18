module SUSC
	PARAMETERS_FORMAT = { 
		:KEY 	 	=> nil,
		:NAME 		=> "", 
		:PATH 		=> "", 
		:XREL 		=> 0,
		:YREL 		=> 0,
		:CTRL 		=> nil,
		:CORE		=> nil,
		:VIEWPORT 	=> Viewport.new(0,0,Graphics.width,Graphics.height)
	}
end

class SpriteWrapper; attr_accessor :sprite; end
class SMSpriteWrapper < SpriteWrapper
	include SUSC
	def initialize(entry_Hash = {})
		super(entry_Hash[:VIEWPORT])
		entryHash = PARAMETERS_FORMAT.clone.merge(entry_Hash)
		@key 		 	= entryHash[:KEY]
		@name 			= entryHash[:NAME]
		@ctrl			= entryHash[:CTRL]
		@spriteViewport = entryHash[:VIEWPORT]
		@core 			= entryHash[:CORE] ? entryHash[:CORE] : Sprite.new(@spriteViewport)
		@path		 	= entryHash[:PATH]
		@objectsList 	= {}
		@zoom_x		 	= 1
		@zoom_y		 	= 1
		@absScaleX	 	= 1
		@absScaleY	 	= 1

		@core.bitmap = Bitmap.new(entryHash[:PATH]+@name) if @name != ""
		@xRel = entryHash[:XREL]
		@yRel = entryHash[:YREL]
		self.x = @xRel
		self.y = @yRel
	end

	def method_missing(method, *args, &block)
		@core && @core.respond_to?(method) ? @core.send(method, *args, &block) : super
	end

	def remove(key); @objectsList.delete(key) if @objectsList&&@objectsList[key]; end
	def addObj(key, grName="", _x=0, _y=0, path=@path, vp = @spriteViewport,entry_Hash={})
		entryHash = PARAMETERS_FORMAT.clone.merge(entry_Hash)
		entryHash[:KEY]		 = key
		entryHash[:NAME] 	 = grName != "" ? (grName ? grName : "") : key.to_s
		entryHash[:XREL]	 = _x
		entryHash[:YREL]	 = _y
		entryHash[:PATH] 	 = path
		entryHash[:VIEWPORT] = vp
		entryHash[:CTRL] 	 = self

		@objectsList[key]	= SMSpriteWrapper.new(entryHash)
		@objectsList[key].z = self.z
	end

	def addEmpty(key,path=@path,vp=@spriteViewport); addObj(key,nil,0,0,path,vp); end

	def insertObj(key, obj, name=nil, _x=0, _y=0,path=@path)
		addObj(key,name,_x,_y,path,obj.viewport,{:CORE => obj})
	end

	def x=(val)
		@xRel = val
		newX = @xRel*@absScaleX + (@ctrl ? @ctrl.sprite.x : 0)

		if @core.respond_to?("x=")
			@core.x = newX
		elsif @core.respond_to?("sprite")
			@core.sprite.x = newX
		end
		for i in @objectsList.keys; @objectsList[i].x = @objectsList[i].x; end
	end

	def y=(val)
		@yRel = val
		newY = @yRel*@absScaleY + (@ctrl ? @ctrl.sprite.y : 0)

		if @core.respond_to?("y=")
			@core.y = newY
		elsif @core.respond_to?("sprite")
			@core.sprite.y = newY
		end
		for i in @objectsList.keys; @objectsList[i].y = @objectsList[i].y; end
	end

	def z=(val)
		@core.z = val
		for i in @objectsList.keys; @objectsList[i].z= val; end
	end

	#GETTERS:
	def to_s; super(); end
	def getKey;	   return @key;					end
	def ctrl;      return @ctrl;				end
	def grName;	   return @name;				end
	def viewport;  return @spriteViewport;		end
	def path;      return @path;				end
	def core;      return @core;				end
	def list;      return @objectsList;			end
	def sprite;    return @core.class == Sprite ? @core : (@core.respond_to?("sprite")  ? @core.sprite  : nil);	end
	def bitmap;    return @core.respond_to?("bitmap")  ? @core.bitmap  : nil;	end
	def visible;   return @core.respond_to?("visible") ? @core.visible : false;	end
	def opacity;   return @core.respond_to?("opacity") ? @core.opacity : 0;		end
	def xAbs;      return @core.respond_to?("x")  ? @core.x  : 0; end
	def yAbs;      return @core.respond_to?("y")  ? @core.y  : 0; end
	def z;         return @core.respond_to?("z")  ? @core.z  : 0; end
	def ox;        return @core.respond_to?("ox") ? @core.ox : 0; end
	def oy;        return @core.respond_to?("oy") ? @core.oy : 0; end
	def x;         return @xRel;				end
	def y;         return @yRel;				end
	def zoom_x;    return @zoom_x;				end
	def zoom_y;    return @zoom_y;				end
	def absScaleX; return @absScaleX;			end
	def absScaleY; return @absScaleY;			end
	
	def width;     
		bmp = self.bitmap
		spr = self.sprite
		return bmp ? bmp.width : (spr && spr.bitmap ? spr.bitmap.width : 0)
	end

	def height
		bmp = self.bitmap
		spr = self.sprite
		return bmp ? bmp.height : (spr && spr.bitmap ? spr.bitmap.height : 0)
	end  

	def disposed?
		ret = true
		if @core.respond_to?("disposed?") 
			ret = @core.disposed?
		elsif @core.class == Sprite
			ret = @core.disposed?
		elsif @core.respond_to?("sprite")
			ret = @core.sprite.disposed?
		end
		return ret
	end

	def getSpriteProperty(property)
		ret = nil
		if @core.class == Sprite
			ret = @core.angle if property == "angle"
			ret = @core.angle if property == "tone"
		elsif @core.respond_to?("sprite")
			ret = @core.sprite.angle if property == "angle"
			ret = @core.sprite.angle if property == "tone"
		end
		return ret
	end
	
	def angle; return getSpriteProperty("angle"); end
	def tone;  return getSpriteProperty("tone");  end	

	def red
		t = self.tone
		return t ? t.red : 0
	end

	def green
		t = self.tone
		return t ? t.green : 0
	end	

	def blue
		t = self.tone
		return t ? t.blue : 0
	end	

	def gray
		t = self.tone
		return t ? t.gray : 0
	end

	def get(key)
		ret = nil
		if @objectsList[key]
		  ret = @objectsList[key]
		else
		  for i in @objectsList.keys
		    ret = @objectsList[i].get(key)
		    break if ret != nil
		  end
		end
		return ret
	end

	#SETTERS
	def viewport=(val)
		super(val)
		if val
			@spriteViewport   = val
			@spriteViewport.z = val.z ? val.z : 0

			spr = self.sprite
			if spr
				settings  = [ self.xAbs, self.yAbs,	self.z,	self.ox, self.oy ]
				spr.dispose if !spr.disposed?
				if @core.class == Sprite
					@core = Sprite.new(@spriteViewport)
				elsif @core.respond_to?("sprite")
					@core.sprite  = Sprite.new(@spriteViewport)
				end	 

				if @name && @name != ""
					self.sprite.bitmap = Bitmap.new(@path+@name)
					self.x  = settings[0]
					self.y  = settings[1]
					self.z  = settings[2]
					self.ox = settings[3]
					self.oy = settings[4]
				end
			end
			for obj in @objectsList.values; obj.viewport=val; end
		end
	end

	def visible=(val)
		if @core.respond_to?("visible=")
			@core.visible = val
		elsif @core.respond_to?("sprite")
			@core.sprite.visible = val
		end
		for obj in @objectsList.values; obj.visible=val; end
	end

	def updateRef(newVal); @ctrl = newVal; end
	def absScaleX=(val); @absScaleX = val; end
	def absScaleY=(val); @absScaleY = val; end
	def ox=(val); @core.ox=val; end
	def oy=(val); @core.oy=val; end

	def zoom_x=(val)
		@zoom_x = val
		@core.zoom_x = @zoom_x*@absScaleX
		for i in @objectsList.keys; @objectsList[i].rescaleX_rel(val,@core.x); end
	end

	def zoom_y=(val)
		@zoom_y = val
		@core.zoom_y = @zoom_y*@absScaleY
		for i in @objectsList.keys; @objectsList[i].rescaleY_rel(val,@core.y); end
	end

	def rescaleX_rel(scale,relOX=self.x)
		if @core.respond_to?("x=")
			@core.x  = relOX + (@xRel*scale).to_i
		elsif @core.respond_to?("sprite") && @core.sprite.respond_to?("x=")
			@core.sprite.x  = relOX + (@xRel*scale).to_i
		end
		@absScaleX = scale
		@core.zoom_x = @absScaleX*@zoom_x
		for i in @objectsList.keys; @objectsList[i].rescaleX_rel(scale,relOX+@xRel*scale); end
	end

	def rescaleY_rel(scale,relOY=self.y)
		if @core.respond_to?("y=")
			@core.y  = relOY + (@yRel*scale).to_i
		elsif @core.respond_to?("sprite") && @core.sprite.respond_to?("y=")
			@core.sprite.y  = relOY + (@yRel*scale).to_i
		end
		@absScaleY = scale
		@core.zoom_y = @absScaleY*@zoom_y
		for i in @objectsList.keys; @objectsList[i].rescaleY_rel(scale,relOY+@yRel*scale); end
	end

	def rescale_rel(scale,relOX=self.x,relOY=self.y)
		rescaleX_rel(scale,relOX)
		rescaleY_rel(scale,relOY)
	end

	def fitSpriteInViewport(viewport=@spriteViewport)
		rescaleX_rel(viewport.rect.width  / (self.width  > 0 ? self.width.to_f  : 1),0)
		rescaleY_rel(viewport.rect.height / (self.height > 0 ? self.height.to_f : 1),0)
	end

	def setSystemFont; pbSetSystemFont(self.bitmap); end
	def drawText(val); pbDrawTextPositions(self.bitmap,val); end
	def drawFTextEx(val); drawFormattedTextEx(self.bitmap,val[0],val[1],val[2],val[3],val[4],val[5]); end
	def bitmap=(val); @core.bitmap=val; end
	def set_src_rect(x,y,w,h)
		begin; @core.src_rect.set(x,y,w,h)
		rescue; self.sprite.src_rect.set(x,y,w,h); end
	end

	def visible=(val)
		@core.visible=val
		for obj in @objectsList.values; obj.visible=val if !obj.disposed?; end
	end

	def opacity=(val)
		@core.opacity=val
		for obj in @objectsList.values; obj.opacity=val; end
	end

	def clear
		@core.bitmap.clear if @core.bitmap
		for obj in @objectsList.values; obj.clear; end
	end

	def dispose
		@core.dispose if !self.disposed?
		for obj in @objectsList.values; obj.dispose; end
	end

	def angle=(val)
		if @core.respond_to?("angle=")
			@core.angle = val
		elsif @core.respond_to?("sprite")
			@core.sprite.angle = val
		end
		#this needs to be fixed:
		for obj in @objectsList.values; obj.angle=val; end
	end

	def tone=(val)
		if @core.respond_to?("tone=")
			@core.tone = val
		elsif @core.respond_to?("sprite")
			@core.sprite.tone = val
		end

		for obj in @objectsList.values; obj.tone=val; end
	end

	def color=(val)
		if @core.respond_to?("color=")
			@core.color = val
		elsif @core.respond_to?("sprite")
			@core.sprite.color = val
		end

		for obj in @objectsList.values; obj.color=val; end
	end

	def red=(val)
		if @core.respond_to?("red=")
			@core.tone.red = val
		elsif @core.respond_to?("sprite")
			@core.sprite.tone.red = val
		end

		for obj in @objectsList.values; obj.tone.red=val; end
	end

	def green=(val)
		if @core.respond_to?("green=")
			@core.tone.green = val
		elsif @core.respond_to?("sprite")
			@core.sprite.tone.green = val
		end

		for obj in @objectsList.values; obj.tone.green=val; end
	end

	def blue=(val)
		if @core.respond_to?("blue=")
			@core.tone.blue = val
		elsif @core.respond_to?("sprite")
			@core.sprite.tone.blue = val
		end

		for obj in @objectsList.values; obj.tone.blue=val; end
	end

	def gray=(val)
		if @core.respond_to?("gray=")
			@core.tone.gray = val
		elsif @core.respond_to?("sprite")
			@core.sprite.tone.gray = val
		end

		for obj in @objectsList.values; obj.tone.gray=val; end
	end

	def draw_rectangle(x,y,w,h,color,fill=false)
		if @core.respond_to?("draw_rectangle")
			@core.draw_rectangle(x,y,w,h,color,fill)
		elsif @core.respond_to?("sprite")
			@core.sprite.draw_rectangle(x,y,w,h,color,fill)
		end
	end

	def path=(val); @path = val; end

	def curtainEffect(frames,dir,mode,scale=1)
		if mode == "h"
		  for i in 0...frames
		    self.zoom_x=(self.zoom_x + dir*(1.0/frames)*scale)
		    Graphics.update
		  end
		elsif mode == "v"
		  for i in 0...frames
		    self.zoom_y=(self.zoom_y + dir*(1.0/frames)*scale)
		    Graphics.update
		  end
		end
	end

	def fadeInOutSprite(sprite,frames,mode,delay=2)
		ok = false
		frames =  -1*frames if frames < 0
		if sprite == nil
		  fadeInOutSprite(self,frames,mode,delay)
		elsif @objectsList[sprite]
		  begin
		    obj = @objectsList[sprite]
		    frames.times do
		      obj.opacity+=mode*255/frames
		      pbWait(delay)
		      break if (mode==1 && obj.opacity>=255) || (mode==-1 && obj.opacity<=0)
		    end
		    ok = true
		  rescue
		    pbThrow("WARNING: Don't set the value of parameter 'frames' from function fadeInOutSprite to 0.",false)
		    fadeInOutSprite(sprite,1,mode,delay)
		  end
		else
		  for obj in @objectsList.values
		    ok = obj.fadeInOutSprite(sprite,frames,mode,delay)
		    break if ok
		  end
		end
		return ok
	end

	def onSprite(pos)
		ret = false
		spr = self.sprite
		if spr
			rect  = spr.src_rect
			ret   = pos[0] >= spr.x && pos[0] <= spr.x + (spr.width  * spr.zoom_x) && 
					pos[1] >= spr.y && pos[1] <= spr.y + (spr.height * spr.zoom_y)
		end
		return ret
	end

	def click?(btn,frames,se,type)
		return false if !self.visible
		vp = @spriteViewport
		scrpos = [vp.rect.x,vp.rect.y]
		mposAux=Mouse::getMousePos; mposAux = [0,0] if !mposAux
		mpos=[(mposAux[0]-scrpos[0]),(mposAux[1]-scrpos[1])]
		ok = Input.trigger?(btn) && onSprite(mpos)
		SUSC.pbFrameAnimation(self.sprite,frames,se,type) if ok
		return ok
	end

	def leftClick?(frames=1, type=0,se=""); return click?(Input::MOUSELEFT, frames,se,type); end
	def rightClick?(frames=1,type=0,se=""); return click?(Input::MOUSERIGHT,frames,se,type); end
end