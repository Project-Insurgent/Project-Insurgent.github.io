#==============================================================================#
#                                  SMSManager                                  #
#   (subclass that handles all the different panels to be placed on screen)    #
#==============================================================================#
class ScrManager < SMSpriteWrapper
  include SUSC
  def initialize()
    super()
    @screens = {}
    for i in SCR_SETTINGS.keys
      @screens[i] = st = SCR_SETTINGS[MULTI_SCREEN ? i : :MAIN_PANEL].clone
      addEmpty(i,@path,Viewport.new(st[0],st[1],st[2],st[3]))
      updatePanel(list[i],i)
    end
    @multiScreen = MULTI_SCREEN
  end
  
  def setX(screen,x); @screens[screen][0] = x; end
  def setY(screen,y); @screens[screen][1] = y; end
  def setWidth(screen,w);  @screens[screen][0] = w; end
  def setHeight(screen,h); @screens[screen][0] = h; end
  def setMultiScreen(val); @multiScreen = val; end
  def getMultiScreen; return @multiScreen; end
  def getScreens(screen=nil); return screen ? @screens[screen] : @screens; end

  def updateScreen(screen);
    updatePanel(list[screen],screen)
    for panel in list[screen].list
      updatePanel(panel,screen)
      panel.fitSpriteInViewport
    end
    Graphics.update
  end
  
  def updatePanel(obj,screen)
    obj.viewport.rect.x = @screens[screen][0]
    obj.viewport.rect.y = @screens[screen][1]
    obj.viewport.rect.width  = @screens[screen][2]
    obj.viewport.rect.height = @screens[screen][3]
  end

  def removePanel(id);
    for screen in self.list.keys;
      list[screen].list[id].visible = false if list[screen].list[id]
      list[screen].list.delete(id)
    end
  end

  def addPanel(screen,id,obj=nil)
    if obj
      list[screen].list[id] = obj
    else
      vp = Viewport.new(@screens[screen][0],@screens[screen][1],@screens[screen][2],@screens[screen][3])
      vp.z = 99999
      list[screen].addEmpty(id,@path,vp)
    end
    return list[screen].list[id]
  end
end
#==============================================================================#  
#==============================================================================#
#                                 MVC MODULES                                  #
#==============================================================================#
#==============================================================================#
class SMModuleView < SMSpriteWrapper
  include SUSC

  def initialize(entryHash = {})
    super(entryHash)
    @mod  = entryHash[:MOD]  # module associated
    @id   = entryHash[:ID]   # Id for $scrManager
    @scrpos = $scrManager.getScreens(:SECN_PANEL)[0,2]
    @panels = {}
  end

  def visible=(val)
    super(val)
    for panel in @panels.values; panel.visible = val; end
  end
  
  def fitInViewports
    for key in @panels.keys
      @panels[key].fitSpriteInViewport($scrManager.list[key].viewport)
    end
  end
  
  def insertPanel(screen,obj)
    if @panels[screen]
      @panels[screen].visible = false
      @panels.delete(screen)
    end
    @panels[screen] = obj
    $scrManager.addPanel(screen,@id,@panels[screen])
  end

  def initScreens(blScreens=false); for key in $scrManager.list.keys; initScreen(key,blScreens); end; end
  
  def initScreen(screen,blackBg=false,createNewVp=true)
    vp  = $scrManager.list[screen].viewport
    newVP = createNewVp ? Viewport.new(vp.rect.x,vp.rect.y,vp.rect.width,vp.rect.height) : vp
    newVP.z = 99999 if createNewVp
    addBlackBg(screen,@path,newVP)
    @panels[screen].fitSpriteInViewport()
    @panels[screen].clear if !(MULTI_SCREEN && blackBg)
    $scrManager.addPanel(screen,@id,@panels[screen])
  end
  
	def addBlackBg(key,path=@path,vp=@spriteViewport)
    entryHash = PARAMETERS_FORMAT.clone
    entryHash[:NAME]     = "blScreen"
    entryHash[:PATH]     = SUSC_PATH
    entryHash[:VIEWPORT] = vp
    entryHash[:CTRL]     = self
    @panels[key] = SMSpriteWrapper.new(entryHash)
		@panels[key].path=@path
	end

  def removePanels(); for key in @panels.keys; @panels.delete(key); end; end

  def z=(val)
    super(val)
    for panel in @panels.values; panel.z=val if panel; end
  end
  
  def getTopScreen; return @panels[:MAIN_PANEL];          end
  def getBtmScreen; return @panels[:SECN_PANEL];          end
  def getPanels;    return @panels;                       end
  def mod;          return @mod;                          end
  def crds(panel);  return $scrManager.getScreens(panel); end

  def setCtrl(ctrl); @ctrl = ctrl;      end
  def activate;   self.visible = true;  end
  def deactivate; self.visible = false; end
  def id=(val); @id=val; end
      
  #to be overwritten by the subclasses:
  def init;   activate;   end
  def finish; deactivate; end
  def execute; end
end
#-------------------------------------------------------------------------------
class SMModule < SMSpriteWrapper
  attr_accessor :active
  attr_accessor :standby
  include SUSC
  
  def initialize(view=nil,ctrl=nil)
    super()
    @view = view
    @ctrl = ctrl
    @active  = false
    @standby = false
    @id = nil
  end
  
  def update; return (@active && !@standby) ?  execute : @active; end
    
  def main
    init
    execute
    finish
  end
  
  #GETTERS:
  def getCtrl;  return @ctrl;    end
  def getView;  return @view;    end
  def getId;    return @id;      end
  def active?;  return @active;  end
  def standby?; return @standby; end
  def getScreen(key); return @view.getScreen(key); end
   
  #SETTERS:
  def setCtrl(ctrl);   @ctrl    = ctrl; @view.setCtrl(@ctrl); end
  def setView(view);   @view    = view; @view.setCtrl(@ctrl); end
  def setStandby(val); @standby = val;  end
  def activate;   @active=true;  @standby=false; init();   end
  def deactivate; @active=false; @standby=false; finish(); end

  # to be overriden by the subclasses
  def init;   pbFadeOutIn(99999) { @view.init };   end
  def execute; return false; end
  def finish; pbFadeOutIn(99999) { @view.finish; removePanel; }; end
  def removePanel; $scrManager.removePanel(@id); end
end
#==============================================================================#
class SMController
  include SUSC
  def initialize(modulesList={},initModule=nil)
    @modulesList = modulesList
    for key in @modulesList.keys; @modulesList[key].setCtrl(self); end
    @curModule = @modulesList[initModule] if initModule
  end
    
  def addModule(key,newModule); @modulesList[key] = newModule; end
  def deleteModule(key); @modulesList.delete(key);             end
  
  def run
    if @curModule; 
      @curModule.activate
      Input.update
      active=true
      while active;
        active = false
        for key in @modulesList.keys; active ||=@modulesList[key].update; end
        Graphics.update
        Input.update;
      end; 
    end
    for key in @modulesList.keys; @modulesList[key].deactivate; end
    Input.update
  end
end

class SMEntry < SMSpriteWrapper
  def initialize(entryHash={})
    super(entryHash)
    @listPos = 1;
    @id             = entryHash[:ID]
    @entry_V_Offset = entryHash[:V_OFFSET] ? entryHash[:V_OFFSET] : 0
    
    addEmpty("textField")
    list["textField"].bitmap = self.bitmap.clone
    list["textField"].setSystemFont
  end
  
  def update(updateSlow=false,numUpd=1)
    if self.visible
      updatePos(updateSlow,numUpd)
      updateContents(updateSlow,numUpd)
    end
  end

  def updatePos(updateSlow,numUpd)
    newPos = getNewPos
    self.x = newPos[0]
    self.y = newPos[1]
    self.z = newPos[2]
  end
  
  def updateContents(updateSlow,numUpd); end
  
  def visible=(val)
    super(@listPos.to_i < @ctrl.ctrl.lastIdxSeen+@ctrl.ctrl.offset && @listPos.to_i >= 0 && val)
  end
  
  def setListPos(val)
    @listPos = val
    self.visible=true
    update()
  end
  
  def setId(val);     @id       = val; end
  def setName(val);   @name     = val; end
  
  def getNewPos; return [@x,@id*@entry_V_Offset]; end
  def getId; return @id; end
end
#==============================================================================#
#==============================================================================#
alias pbBottomLeftLinesOld pbBottomLeftLines
def pbBottomLeftLines(window,lines,width=nil)
  pbBottomLeftLinesOld(window,lines,width=nil)
  window.width= $scrManager.getScreens(:MAIN_PANEL)[2]
end
#-------------------------------------------------------------------------------
class Window_AdvancedTextPokemon < SpriteWindow_Base
  alias initializeOld initialize
  def initialize(text="")
    initializeOld(text)
    @sprites["minimap"] = Sprite.new(viewport)
    @sprites["minimap"].z = 999999
  end
  
  def getPic; return @sprites["minimap"]; end
    
  def setMinimap(name,crop = nil)
    @sprites["minimap"].bitmap = Bitmap.new(name) if name
    @sprites["minimap"].src_rect.set(crop[0],crop[1],crop[2],crop[3]) if crop
  end
  
  alias privRefreshOld privRefresh
  def privRefresh(changeBitmap=false)
    privRefreshOld(changeBitmap)
    @sprites["minimap"].x = @x+32 if @sprites["minimap"]
    @sprites["minimap"].y = @y+16 if @sprites["minimap"]
  end
end

class Game_Player < Game_Character
  include SUSC
  xBase = (SUSC::SCR_SETTINGS[:MAIN_PANEL][2] / 2 - Game_Map::TILE_WIDTH  / 2)
  yBase = (SUSC::SCR_SETTINGS[:MAIN_PANEL][3] / 2 - Game_Map::TILE_HEIGHT / 2)
  SCREEN_CENTER_X = xBase * Game_Map::X_SUBPIXELS
  SCREEN_CENTER_Y = yBase * Game_Map::Y_SUBPIXELS
end

class Player
  attr_accessor :pokedex
  class Pokedex
    attr_accessor :owned
    attr_accessor :seen
    
    def set_owned(species, should_refresh_dexes = true, owned=true)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @owned[species_id] = owned
      self.refresh_accessible_dexes if should_refresh_dexes
    end
    
    def set_seen(species, should_refresh_dexes = true, seen=true)
      species_id = GameData::Species.try_get(species)&.species
      return if species_id.nil?
      @seen[species_id] = seen
      self.refresh_accessible_dexes if should_refresh_dexes
    end
  end
end
#==============================================================================#
$scrManager = ScrManager.new #do not touch
#==============================================================================#