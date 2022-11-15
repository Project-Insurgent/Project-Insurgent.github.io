#==============================================================================#
#                          DPPT GENDER SELECTOR SCENE v2.0                     #
#                                (by A.Somersault)                             #
#==============================================================================#
# IMPORTANT: NEEDS SUSc v4.0+ in order to work properly                        #
#==============================================================================#
# Changelog 2.0.1 (17/6/2021):
# -Polished a bit the quotes so that they fit more with the original cutscene
#-------------------------------------------------------------------------------
# Changelog 2.0 (3/6/2021):
# -Refactored to implement the new composite system SMObject;
# -Simplified code: grouped pairs of (very) similar functions into single ones.
#-------------------------------------------------------------------------------
# Changelog 1.2 (21/9/2020):
# Fixed a bug that happened only when selecting the boy: If you pressed escape in
# the nameCharacter menu, the script turned glitchy. Now solved.
#-------------------------------------------------------------------------------
# Changelog 1.1:
# Fixed a small bug: when selecting with the arrows for the first time, if you
# selected the male sprite, the script showed you the confirmation screen
# for the female and with an opacity of 127 instead of 255.
#===============================================================================
# How to use:
# Very simple. Just call pbDpptGdSelector and the script will show up. You must
# know that the script doesn't provide a background, though.
#
# You can also make an animated selector: you only have to make each graphic
# to contain all its corresponding animation frames.
#
# Note: Take in mind that after calling this script the player will lose all the
# items, Pokémon and pokédex, if they previously had one. Aka: a reset.
# So make sure you call it at the very start of your game.
#===============================================================================
#                                  PARAMETERS
#===============================================================================
PATH = "Graphics/Pictures/GenderSel/"  #general path for both sprites

GENDERFEMALE = PATH + "Rebel.png"       #name of the female graphic.
GENDERMALE   = PATH + "Rogue.png"       #name of the male graphic.

ANIMATED = true              # whether the walking animation will be played

FRAMEWIDTH_M = 47              # width of each Male frame           
FRAMEHEIGHT_M = 109            # height of each Male frame

FRAMEWIDTH_F = 52              # width of each Female frame           
FRAMEHEIGHT_F = 110            # height of each Female frame

NUMFRAMES = 6                # number of frames in the animation
INVSPEED = 6                 #as higher, as slower the animation will be (min 1)

#Coordinates of the script
SCRIPT_X_POS = 0 
SCRIPT_Y_POS = 0

#male position on screen:
MALEX = 125
MALEY = 60

#female position on screen:
FEMALEX = 307
FEMALEY = 60
#===============================================================================
#===============================================================================
class DpptGdSelScene < SMObject
  def initialize
    super()
    @select=0
    @brDone = false
    @finished=false
    @spriteViewport=$topScreen.getViewport
  
    #FEMALE TRAINER
    @objectsList["girl"]=SMSprite.addObj(FEMALEX,FEMALEY,GENDERFEMALE)
    @objectsList["girl"].set("set_src_rect",[0,0,FRAMEWIDTH_F,FRAMEHEIGHT_F])

    #MALE TRAINER
    @objectsList["boy"]=SMSprite.addObj(MALEX,MALEY,GENDERMALE)
    @objectsList["boy"].set("set_src_rect",[0,0,FRAMEWIDTH_M,FRAMEHEIGHT_M])

    for i in @objectsList.keys
      @objectsList[i].set("zoom_x",2)
      @objectsList[i].set("zoom_y",2)
      @objectsList[i].set("opacity",0)
    end
    
    @objectsList["msgwindow"]=Kernel.pbCreateMessageWindow(@spriteViewport)
  end

  def pbHideShow(mode)
    10.times do
      Graphics.update
      @objectsList["boy"].set("opacity",@objectsList["boy"].opacity+25.5*mode)
      @objectsList["girl"].set("opacity",@objectsList["girl"].opacity+25.5*mode)
    end
  end
  
  INVSPEED = INVSPEED.abs
  INVSPEED = 1 if INVSPEED == 0

#===============================================================================  

  def selectChar(mode)
    @brDone = false
    @select = mode
    frame=0
    
    @vars={}
    case mode
      when 0;
        @vars["gender0"]="boy"
        @vars["gender1"]="girl"
        @vars["dir"]=Input::RIGHT
        @vars["frW"]=FRAMEWIDTH_M
        @vars["frH"]=FRAMEHEIGHT_M
      when 1;
        @vars["gender0"]="girl"
        @vars["gender1"]="boy"
        @vars["dir"]=Input::LEFT
        @vars["frW"]=FRAMEWIDTH_F
        @vars["frH"]=FRAMEHEIGHT_F       
    end
    @objectsList[@vars["gender0"]].set("opacity",255)
    @objectsList[@vars["gender1"]].set("opacity",125)
    
    loop do
      Input.update
      if Input.trigger?(@vars["dir"])
        @select = 1-@select
      elsif Input.trigger?(Input::C)
        @brDone = true
      end
      break if @brDone || Input.trigger?(@vars["dir"])
      
      Graphics.update
      if ANIMATED
        @objectsList[@vars["gender0"]].set("set_src_rect",[(frame / NUMFRAMES) * @vars["frW"], 0, @vars["frW"], @vars["frH"]]) if frame % NUMFRAMES == 0
        frame += 1
        frame = frame % (INVSPEED * NUMFRAMES)
      end
    end
  end
#===============================================================================
  def selection
    sign = @select == 0 ? 1 : -1
    17.times do
      Graphics.update
      @objectsList[@vars["gender1"]].set("opacity",@objectsList[@vars["gender1"]].opacity-15)
      @objectsList[@vars["gender0"]].set("x",@objectsList[@vars["gender0"]].x+5*sign)
    end
    
    if !Kernel.pbConfirmMessage(_INTL("So this is your picture, right?"))
      17.times do
        Graphics.update
        @objectsList[@vars["gender1"]].set("opacity",@objectsList[@vars["gender1"]].opacity+7.5)
        @objectsList[@vars["gender0"]].set("x",@objectsList[@vars["gender0"]].x-5*sign)
      end
      @objectsList["msgwindow"].visible=true
      
      Kernel.pbMessageDisplay(@objectsList["msgwindow"],
      _INTL("So how do you look like if not?"))
      @select = 0
    else
      pbChangePlayer(@select)
      @objectsList["msgwindow"].visible=false
      Kernel.pbMessage("Tell me, what is your name?")
      selectName
    end
  end
#===============================================================================

  def selectName
    pbTrainerName
    Kernel.pbMessage("OK...")
    if !Kernel.pbConfirmMessage(_INTL("So you are {1}?",$Trainer.name))
      selectName
    else
      Kernel.pbMessage("A fine name, that is!")
      pbHideShow(-1)
      @finished=true
    end
  end
  
  def pbUpdate
    pbHideShow(1)
    Kernel.pbMessageDisplay(@objectsList["msgwindow"],
        _INTL("How do you look like?"))
    selectChar(@select)
    loop do
      loop do    
        selectChar(@select)
        break if @brDone
      end
      selection
      break if @finished
    end
  end
end
################################################################################

class DpptGdSelector
  def initialize
    @scene = DpptGdSelScene.new
    pbStartScreen
  end

  def pbStartScreen
   @scene.pbUpdate
   @scene.pbEndScene
  end
end

def pbDpptGdSelector
  screen=DpptGdSelector.new
end