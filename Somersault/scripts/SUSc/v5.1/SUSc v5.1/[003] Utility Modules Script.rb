#==============================================================================#
#                                  SMSManager                                  #
#   (subclass that handles all the different panels to be placed on screen)    #
#==============================================================================#
class ScrManager < SMSpriteWrapper
  include SUSC
  def initialize()
    super()
    for i in SCR_SETTINGS.keys; addPanel(i,SCR_SETTINGS[i]) if i == :MAIN_PANEL || MULTI_SCREEN; end
  end
  
  def addPanel(id,set)
    vp = Viewport.new(set[0],set[1],set[2],set[3])
    vp.z = 99999
    addEmpty(id,@path,vp)
  end
  
  def removePanel(id); 
    for k in @objectsList.keys; 
      @objectsList[k].list[id].visible = false if @objectsList[k].list[id]
      @objectsList[k].remove(id)
    end
  end
  
  def getScreen(key); return @objectsList[key]; end
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
    @scnscreen = MULTI_SCREEN ? :SECN_PANEL : :MAIN_PANEL
    @scrpos = SCR_SETTINGS[@scnscreen][0,2]
    @panels = {}
  end

  def visible=(val)
    super(val)
    for panel in @panels.values; panel.visible = val; end
  end
  
  def fitInViewports
    for key in @panels.keys; @panels[key].fitSpriteInViewport($scrManager.getScreen(key).viewport); end
  end
  
  def initBlackScreens(createNewVp=false)
    for key in $scrManager.list.keys
      scr = $scrManager.getScreen(key)
      vp  = $scrManager.getScreen(key).viewport
      newVP = createNewVp ? Viewport.new(vp.rect.x,vp.rect.y,vp.rect.width,vp.rect.height) : vp
      newVP.z = 99999
      @panels[key] = SMSpriteWrapper.new({:NAME => "blScreen", :PATH => SUSC_PATH, :VIEWPORT => newVP, :CTRL => self})
      @panels[key].fitSpriteInViewport(vp)
      @panels[key].path=@path
      scr.list[@id] = @panels[key]
    end
  end
  
  def initMainPanel
    vp = $scrManager.getScreen(:MAIN_PANEL).viewport
    @panels[:MAIN_PANEL] = SMSpriteWrapper.new({:NAME => "blScreen", :PATH => SUSC_PATH, :VIEWPORT => vp, :CTRL => self})
    @panels[:MAIN_PANEL].clear
  end
  
  def z=(val)
    super(val)
    for panel in @panels.values; panel.z=val if panel; end
  end
  
  def panels;      return @panels;                  end
  def mod;         return @mod;                     end
  def crds(panel); return SCR_SETTINGS[panel][0,2]; end

  def setCtrl(ctrl); @ctrl = ctrl; end
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
    @scnscreen = MULTI_SCREEN ? :SECN_PANEL : :MAIN_PANEL
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
  window.width= $scrManager.getScreen(:MAIN_PANEL).viewport.rect.width
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