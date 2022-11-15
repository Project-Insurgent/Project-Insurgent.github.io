#==============================================================================#
#                               DPPT TV SCRIPT v2.1                            #
#                               (by S.A.Somersault)                            #
#==============================================================================#
# A script that implements a gen 4 styled TV script!                           #
# IMPORTANT: NEEDS SUSc v5.1+ in order to work properly                        #
#==============================================================================#
# Usage: pbTV(bg,textId,time)                                                  #
# where                                                                        #
#   - bg     -> name of the background (located in PATH) to be used            #
#   - textId -> index of the string to use (from TEXTS)                        #
#   - time   -> time the script will be displayed (optional)                   #
# Note: The plugin does not handle BGMs, so you'd have to change it manually.  #
#==============================================================================#
#==============================================================================#
#                                  DPPT TV VIEW                                #
#==============================================================================#
class AnimatedPlane < LargePlane; 
  attr_accessor :__sprite; 
  def sprite; return @__sprite; end
  def viewport=(val); @__sprite.viewport = val; end
end

class DpptTV_View < SMModuleView
  include DPPT_TV
  def initialize(mod,ctrl=nil)
    super({:PATH => PATH, :CTRL => ctrl, :MOD => mod, :ID => ID}) 
    initBlackScreens
    
    descText = [40,55,440,_INTL(@mod.getText),TFG_COLOR,TBG_COLOR]
    @panels[:MAIN_PANEL].addObj("bg",@mod.getBgName)
    @panels[:MAIN_PANEL].get("bg").setSystemFont
    @panels[:MAIN_PANEL].get("bg").drawFTextEx(descText)
    
    @panels[:MAIN_PANEL].insertObj("lines",AnimatedPlane.new(@panels[:MAIN_PANEL].viewport),"TVLines")
    @panels[:MAIN_PANEL].addObj("TV","TV")
    fitInViewports
    deactivate
  end
  
  def execute; @panels[:MAIN_PANEL].get("lines").oy += 1 if @mod.getCounter%BARS_SPEED==0; end
end
#==============================================================================#
#==============================================================================#
#                                 DPPT TV MODULE                               #
#==============================================================================#
class DpptTV_Module < SMModule
  include DPPT_TV
  def initialize(bgName,textId,time)
    super()
    @counter = 0
    @textId  = textId
    @bgName  = bgName
    @time    = time
    @text    = TEXTS[@textId]
    @view    = DpptTV_View.new(self)
  end
  
  def execute;
    @view.execute
    @counter+=1
    return @counter < @time*Graphics.frame_rate
  end

  def getText;    return @text;    end
  def getBgName;  return @bgName;  end
  def getCounter; return @counter; end
end
#==============================================================================#
def pbTV(bg,textId,time=DPPT_TV::DEF_WAITTIME)
  modulesList = { DPPT_TV::ID => DpptTV_Module.new(bg,textId,time) }
  scene=SMController.new(modulesList,DPPT_TV::ID)
  scene.run
end
#==============================================================================#