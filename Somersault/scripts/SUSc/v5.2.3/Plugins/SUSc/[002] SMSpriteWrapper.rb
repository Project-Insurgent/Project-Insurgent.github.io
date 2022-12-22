module SUSC
	PARAMETERS_FORMAT = { 
		:NAME 		=> "", 
		:PATH 		=> "", 
		:X 			=> 0,
		:Y 			=> 0,
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
		#puts(entryHash.to_s)
		@name = entryHash[:NAME]
		@ctrl			= entryHash[:CTRL]
		@spriteViewport = entryHash[:VIEWPORT]
		@path		 = entryHash[:PATH]
		@objectsList = {}
		@visible 	 = true
		@zoom_x		 = 1
		@zoom_y		 = 1
		@absScaleX	 = 1
		@absScaleY	 = 1

		#Used only when wrapping something different from a simple sprite:
		@core			= entryHash[:CORE] ? entryHash[:CORE] : Sprite.new(@spriteViewport)
		@core.bitmap	= Bitmap.new(entryHash[:PATH]+@name) if @name != ""
		@core.viewport  = @spriteViewport

		#used when wrapping a sprite:
		@sprite 		 = @core.class == Sprite ? @core : @core.sprite
		@sprite.viewport = @spriteViewport

		@xRel = entryHash[:XREL]
		@yRel = entryHash[:YREL]
		if @sprite
		  self.x = @xRel
		  self.y = @yRel
		end
	end

	#key,x=0,y=0,grName="",p=@path,cl=Sprite.new(@spriteViewport),vp=@spriteViewport
	def addObj(key, grName="", _x=0, _y=0, path=@path, vp = @spriteViewport,entry_Hash={})
		entryHash = PARAMETERS_FORMAT.clone.merge(entry_Hash)
		entryHash[:NAME] 	 = grName != "" ? (grName ? grName : "") : key.to_s
		entryHash[:X] 		 = @sprite.x+_x
		entryHash[:Y] 		 = @sprite.y+_y
		entryHash[:XREL]	 = _x
		entryHash[:YREL]	 = _y
		entryHash[:PATH] 	 = path
		entryHash[:VIEWPORT] = vp
		entryHash[:CTRL] 	 = self

		@objectsList[key]	= SMSpriteWrapper.new(entryHash)
		@objectsList[key].z = self.z
	end

	def addEmpty(key,path=@path,vp=@spriteViewport); addObj(key,nil,0,0,path,vp); end

	def insertObj(key, obj, name=nil, _x=obj.sprite.x, _y=obj.sprite.y,path=@path)
		addObj(key,name,_x-@sprite.x,_y-@sprite.y,path,obj.viewport,{:CORE => obj})
	end

	def remove(key); @objectsList.delete(key) if @objectsList&&@objectsList[key]; end

	#GETTERS:
	def to_s; super(); end
	def ctrl;      return @ctrl;				end
	def grName;	   return @name;				end
	def viewport;  return @spriteViewport;		end
	def core;      return @core;				end
	def sprite;    return @sprite;				end
	def list;      return @objectsList;			end
	def visible;   return @visible;				end
	def path;      return @path;				end
	def xAbs;      return @sprite.x;			end
	def yAbs;      return @sprite.y;			end
	def x;         return @xRel;				end
	def y;         return @yRel;				end
	def ox;        return @core.ox;				end
	def oy;        return @core.oy;				end
	def z;         return @core.z;				end
	def zoom_x;    return @zoom_x;				end
	def zoom_y;    return @zoom_y;				end
	def absScaleX; return @absScaleX;			end
	def absScaleY; return @absScaleY;			end
	def opacity;   return @sprite.opacity;		end
	def bitmap;    return @sprite.bitmap;		end
	def width;     return @sprite.bitmap ? @sprite.bitmap.width  : 0; end
	def height;    return @sprite.bitmap ? @sprite.bitmap.height : 0; end    
	def sprite;    return @sprite;				end
	def disposed?; return @sprite.disposed?;	end
	def angle;     return @sprite.angle;		end
	def tone;      return @sprite.tone;			end	
	def red;       return @core.tone.red;		end
	def green;     return @core.tone.green;		end
	def blue;      return @core.tone.blue;		end
	def gray;      return @core.tone.gray;		end

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

			#@sprite.dispose if !@sprite.disposed?
			settings  = [@sprite.x,@sprite.y,@sprite.z,@sprite.ox,@sprite.oy]
			@sprite   = Sprite.new(@spriteViewport)

			if @name && @name != ""
				@sprite.bitmap = Bitmap.new(@path+@name)
				self.x = settings[0]
				self.y = settings[1]
				self.z = settings[2]
				@sprite.ox     = settings[3]
				@sprite.oy     = settings[4]
			end
			@core.class == Sprite ? @core = @sprite : @core.sprite = @sprite
			for obj in @objectsList.values; obj.viewport=val; end
		end
	end

	def visible=(val)
		@visible = val;
		for obj in @objectsList.values; obj.visible=val; end
	end

	def updateRef(newVal); @ctrl = newVal; end
	def absScaleX=(val); @absScaleX = val; end
	def absScaleY=(val); @absScaleY = val; end

	def x=(val)
		@xRel = val
		begin;  @sprite.x = (@ctrl ? @ctrl.xAbs : 0) + @xRel
		rescue
			puts("The controller of this SMSpriteWrapper is not a SMSpriteWrapper itself\n")
			begin;  @sprite.x = (@ctrl ? @ctrl.x : 0) + @xRel 	#in case @ctrl is not a SMSpriteWrapper
			rescue; 
				@sprite.x = @xRel; 								#in case @ctrl does not have a #x method
				puts("The controller of this SMSpriteWrapper does not have a #x method.\n")
			end		
		end
		for i in @objectsList.keys; @objectsList[i].x = @objectsList[i].x; end
		@sprite.x *= @absScaleX #@zoom_x*
	end

	def y=(val)
		@yRel = val
		begin;  @sprite.y = (@ctrl ? @ctrl.yAbs : 0) + @yRel
		rescue
			puts("The controller of this SMSpriteWrapper is not a SMSpriteWrapper itself\n")
			begin;  @sprite.y = (@ctrl ? @ctrl.y : 0) + @yRel 	#in case @ctrl is not a SMSpriteWrapper
			rescue; 
				@sprite.y = @yRel; 								#in case @ctrl does not have a #y method
				puts("The controller of this SMSpriteWrapper does not have a #y method.\n")
			end						
		end
		for i in @objectsList.keys; @objectsList[i].y = @objectsList[i].y; end
		@sprite.y *= @absScaleY #@zoom_y*
	end

	def z=(val)
		@core.z = val
		for i in @objectsList.keys; @objectsList[i].z= val; end
	end

	def ox=(val); @core.ox=val; end
	def oy=(val); @core.oy=val; end

	def zoom_x=(val)
		@zoom_x = val
		@sprite.zoom_x = @zoom_x*@absScaleX
		for i in @objectsList.keys; @objectsList[i].rescaleX_rel(val,@sprite.x); end
	end

	def zoom_y=(val)
		@zoom_y = val
		@sprite.zoom_y = @zoom_y*@absScaleY
		for i in @objectsList.keys; @objectsList[i].rescaleY_rel(val,@sprite.y); end
	end

	def rescaleX_rel(scale,relOX=@sprite.x)
		@sprite.x  = relOX + (@xRel*scale).to_i
		@absScaleX = scale
		@sprite.zoom_x = @absScaleX*@zoom_x
		for i in @objectsList.keys; @objectsList[i].rescaleX_rel(scale,relOX+@xRel*scale); end
	end

	def rescaleY_rel(scale,relOY=@sprite.y)
		@sprite.y  = relOY + (@yRel*scale).to_i
		@absScaleY = scale
		@sprite.zoom_y = @absScaleY*@zoom_y
		for i in @objectsList.keys; @objectsList[i].rescaleY_rel(scale,relOY+@yRel*scale); end
	end

	def rescale_rel(scale,relOX=@sprite.x,relOY=@sprite.y)
		rescaleX_rel(scale,relOX)
		rescaleY_rel(scale,relOY)
	end

	def fitSpriteInViewport(viewport=@spriteViewport)
		rescaleX_rel(viewport.rect.width  / (@sprite.width  > 0 ? @sprite.width.to_f  : 1),0)
		rescaleY_rel(viewport.rect.height / (@sprite.height > 0 ? @sprite.height.to_f : 1),0)
	end

	def setSystemFont; pbSetSystemFont(@sprite.bitmap); end
	def drawText(val); pbDrawTextPositions(@sprite.bitmap,val); end
	def drawFTextEx(val); drawFormattedTextEx(@sprite.bitmap,val[0],val[1],val[2],val[3],val[4],val[5]); end
	def bitmap=(val); @sprite.bitmap=val; end
	def set_src_rect(x,y,w,h); @sprite.src_rect.set(x,y,w,h); end

	def visible=(val)
		@sprite.visible=val
		for obj in @objectsList.values; obj.visible=val if !obj.disposed?; end
	end

	def opacity=(val)
		@sprite.opacity=val
		for obj in @objectsList.values; obj.opacity=val; end
	end

	def clear
		@sprite.bitmap.clear if @sprite.bitmap
		for obj in @objectsList.values; obj.clear; end
	end

	def dispose
		@core.dispose if @sprite && !@sprite.disposed?
		for obj in @objectsList.values; obj.dispose; end
	end

	def angle=(val)
		@sprite.angle=val

		#this needs to be fixed:
		for obj in @objectsList.values; obj.angle=val; end
	end

	def tone=(tone);   @sprite.tone  = tone;  end
	def color=(color); @sprite.color = color; end

	def red=(val)
		@core.tone.red=val
		for obj in @objectsList.values; obj.red=val; end
	end

	def green=(val)
		@core.tone.green=val
		for obj in @objectsList.values; obj.green=val; end
	end

	def blue=(val)
		@core.tone.blue=val
		for obj in @objectsList.values; obj.blue=val; end
	end

	def gray=(val)
		@core.tone.gray=val
		for obj in @objectsList.values; obj.gray=val; end
	end

	def draw_rectangle(x,y,w,h,color,fill=false)
		@sprite.draw_rectangle(x,y,w,h,color,fill)
	end

	def path=(val); @path = val; end

	def curtainEffect(frames,dir,mode,scale=1)
		if mode == "h"
		  for i in 0...frames
		    self.zoom_x=(@sprite.zoom_x + dir*(1.0/frames)*scale)
		    Graphics.update
		  end
		elsif mode == "v"
		  for i in 0...frames
		    self.zoom_y=(@sprite.zoom_y + dir*(1.0/frames)*scale)
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

	def onSprite(pos) #/@sprite.zoom_x
		rect = @sprite.src_rect
		return pos[0] >= @sprite.x && pos[0] <= @sprite.x + (@sprite.width  * @sprite.zoom_x) && 
		       pos[1] >= @sprite.y && pos[1] <= @sprite.y + (@sprite.height * @sprite.zoom_y)
	end

	def click?(btn,frames,se,type)
		return false if !@sprite.visible
		vp = @spriteViewport
		scrpos = [vp.rect.x,vp.rect.y]
		mposAux=Mouse::getMousePos; mposAux = [0,0] if !mposAux
		mpos=[(mposAux[0]-scrpos[0]),(mposAux[1]-scrpos[1])]
		ok = Input.trigger?(btn) && onSprite(mpos)
		SUSC.pbFrameAnimation(@sprite,frames,se,type) if ok
		return ok
	end

	def leftClick?(frames=1, type=0,se=""); return click?(Input::MOUSELEFT, frames,se,type); end
	def rightClick?(frames=1,type=0,se=""); return click?(Input::MOUSERIGHT,frames,se,type); end
end