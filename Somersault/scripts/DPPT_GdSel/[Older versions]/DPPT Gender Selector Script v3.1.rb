#==============================================================================#
#                          DPPT GENDER SELECTOR SCENE v3.1                     #
#                                (by S.A.Somersault)                           #
#==============================================================================#
# Gender selection screen in the purest DPPT style!                            #
#==============================================================================#
# Usage: pbDpptGdSelector                                                      #
#==============================================================================#
# You must know that the script doesn't provide a background, though.
#
# You can also make an animated selector: you only have to make each graphic
# to contain all its corresponding animation frames in horizontal.
#
# Note: Take in mind that after calling this script the player will lose all the
# items, Pokémon and pokédex, if they previously had any. Aka: a reset.
# So make sure you call it at the very start of your game.
#==============================================================================#
#==============================================================================#
#                           DPPT GENDER SELECTOR VIEW                          #
#==============================================================================#
class DpptGdSel_View < SMModuleView
  include DPPTGenderSel
  def initialize(mod,ctrl=nil)
    super({:PATH=>PATH,:MOD=>mod,:CTRL=>ctrl,:ID=>ID})
    @spriteViewport = $scrManager.getScreen(:MAIN_PANEL).viewport
    initMainPanel

    #FEMALE TRAINER    
    @panels[:MAIN_PANEL].addObj("girl",GENDERFEMALE,FEMALEX,FEMALEY,PATH)
    @panels[:MAIN_PANEL].list["girl"].set_src_rect(0,0,FRAMEWIDTH_F,FRAMEHEIGHT_F)

    #MALE TRAINER
    @panels[:MAIN_PANEL].addObj("boy",GENDERMALE,MALEX,MALEY,PATH)
    @panels[:MAIN_PANEL].list["boy"].set_src_rect(0,0,FRAMEWIDTH_M,FRAMEHEIGHT_M)

    @msgWindow = pbCreateMessageWindow(@spriteViewport)
    #@msgWindow.visible = false
    @panels[:MAIN_PANEL].fitSpriteInViewport(@spriteViewport)
    for i in @panels[:MAIN_PANEL].list.keys
      @panels[:MAIN_PANEL].list[i].zoom_x*=2
      @panels[:MAIN_PANEL].list[i].zoom_y*=2
      @panels[:MAIN_PANEL].list[i].opacity=0
      @panels[:MAIN_PANEL].list[i].ox = @panels[:MAIN_PANEL].list[i].width/(2*NUMFRAMES)
    end
    @panels[:MAIN_PANEL].visible=false
  end
  
  def init;
    activate
    pbHideShow(1)
    pbMessageDisplay(@msgWindow,_INTL("What do you look like?"))
  end
  
  def finish
    pbHideShow(-1)
    deactivate
  end
  
  def pbHideShow(mode)
    10.times do
      Graphics.update
      @panels[:MAIN_PANEL].list["boy"].opacity  += 25.5*mode
      @panels[:MAIN_PANEL].list["girl"].opacity += 25.5*mode
    end
  end
  
  def moveSelectionToCenter(vars,mode,select)
    sign = select == 0 ? (MALE_ARROW == Input::RIGHT || MALE_ARROW == Input::DOWN ? -1 : 1) : 
                         (FEMALE_ARROW == Input::LEFT || FEMALE_ARROW == Input::UP ? 1 : -1)

    posVal = 5*sign*mode
    scaVal = 7.5*mode
    17.times do
      Graphics.update
      @panels[:MAIN_PANEL].list[vars["gender1"]].opacity-= scaVal
      cond = select == 0 && (MALE_ARROW   == Input::DOWN || MALE_ARROW   == Input::UP || 
                             FEMALE_ARROW == Input::DOWN || FEMALE_ARROW == Input::UP)
      cond ? @panels[:MAIN_PANEL].list[vars["gender0"]].y += posVal : 
             @panels[:MAIN_PANEL].list[vars["gender0"]].x += posVal
    end
    @msgWindow.visible=false
    return mode == 1 ? pbConfirmMessage(_INTL("So this is your picture, right?")) : true
  end
  
  def confirmationMessage(mode)
    if mode; pbMessage(_INTL("Tell me, what is your name?"))
    else
      @msgWindow.visible=true
      pbMessageDisplay(@msgWindow,_INTL("So how do you look like if not?"))
    end
  end
  
  def selectChar(vars,frame)
    @panels[:MAIN_PANEL].list[vars["gender0"]].opacity=255
    @panels[:MAIN_PANEL].list[vars["gender1"]].opacity=125
    
    if ANIMATED
      @panels[:MAIN_PANEL].list[vars["gender0"]].set_src_rect(
        (frame / NUMFRAMES) * vars["frW"], 0,
        vars["frW"], vars["frH"]
      ) if frame % NUMFRAMES == 0
    end
    Graphics.update
  end
end
#==============================================================================#
#                       DPPT GENDER SELECTOR MAIN MODULE                       #
#==============================================================================#
class DpptGdSelModule < SMModule
  include DPPTGenderSel
  def initialize()
    super()
    @select=INITIAL_SELECTION
    @brDone   = false
    @finished = false
    @invSpeed = INVSPEED == 0 ? 1 : INVSPEED.abs
    @view = DpptGdSel_View.new(self)
  end
  
  def init;   @view.init;   end
  def finish; @view.finish; removePanel; end
    
  def execute
    selectChar
    gdConfirmation
    return !@finished
  end
  
  def selectChar
    @brDone = false
    frame=0
    @vars = {}
      
    loop do
      case @select
        when 0;
          @vars["gender0"]="boy"
          @vars["gender1"]="girl"
          @vars["dir"]=FEMALE_ARROW
          @vars["frW"]=FRAMEWIDTH_M
          @vars["frH"]=FRAMEHEIGHT_M
        when 1;
          @vars["gender0"]="girl"
          @vars["gender1"]="boy"
          @vars["dir"]=MALE_ARROW
          @vars["frW"]=FRAMEWIDTH_F
          @vars["frH"]=FRAMEHEIGHT_F       
      end
        
      @select = 1-@select if Input.trigger?(@vars["dir"])
      @view.selectChar(@vars,frame)
      frame += 1
      frame = frame % (INVSPEED * NUMFRAMES)
      
      Input.update
      @brDone = true if Input.trigger?(Input::USE)
      break          if Input.trigger?(Input::USE)
    end 
  end
  
  def gdConfirmation
    confirm = @view.moveSelectionToCenter(@vars,1,@select)
    confirm ? pbChangePlayer(@select) : @view.moveSelectionToCenter(@vars,-1,@select)
    @view.confirmationMessage(confirm)
    selectName if confirm
  end
  
  def selectName
    loop do
      pbTrainerName
      pbMessage("OK...")
      break if pbConfirmMessage(_INTL("So you are {1}?",$Trainer.name))
    end
    pbMessage("A fine name, that is!")
    @finished=true
  end
  
  def brDone;   return @brDone;   end
  def finished; return @finished; end
  def invSpeed; return @invSpeed; end
  
  def brDone=(val); @brDone   = val; end
  def finished=(val); @finished = val; end
  def invSpeed=(val); @invSpeed = val; end
end
#==============================================================================#
def pbDpptGdSelector
  modulesList = { DPPTGenderSel::ID => DpptGdSelModule.new }
  scene=SMController.new(modulesList,DPPTGenderSel::ID)
  scene.run
end
#==============================================================================#