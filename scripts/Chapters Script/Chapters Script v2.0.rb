#==============================================================================#
#                               Chapters Script v2.0                           #
#                                (by A.Somersault)                             #
#==============================================================================#
# IMPORTANT: NEEDS SUSc v4.0+ in order to work properly                        #
#==============================================================================#
# How to use: Simply Call pbChapter(NUMCHAPTER,INTROTRANS,ENDTRANS,XPOS,YPOS)
#
# Where:
#  -NUMCHAPTER is the number of the chapter
#  -INTROTRANS and ENDTRANS are booleans. True if you want a fade to black
#     respectively at the beginning and at the end. (both optional. true by default)
#  -XPOS and YPOS are the position of the script on screen and are both optional
#     (0 by default).
# Note: be careful with where you place the script since it might not be shown
# if you place it out of bounds of $topScreen. Refer to SM_SCREEN_WIDTH
# and SM_SCREEN_HEIGHT in SUSc for modifying the size of the top screen viewport.
# (this will only affect the scripts by Somersault, yet it will affect all of them).
#
# Examples:
# pbChapter(0) will call the chapter 0
# pbChapter(2,false) will call the chapter 2 without a fade to black transition.
# pbChapter(3,true,20,5) will call the chapter 3 with fade, at position [20,5]
#     relative to $topScreen.x and $topScreen.y respectively.
#===============================================================================
# Paramters:
#-------------------------------------------------------------------------------
PATH = "Graphics/Pictures/Chapters/Chapter"

ME_ON = true                  #If you want to play a fanfare 
ME_FILE = "Azure Flute.mid"   #File name of the fanfare (located in ME)

#Volume paramters:
ME_VOLUME = 100
ME_PITCH  = 80

#Time-related parameters (60 frames = 1 second, aprox):
FADE_TO_BLACK  = 15           #Duration of the first fade to black
TIME_TO_TEXT   = 60           #Time lapse before the text appears

FADE_IN_TEXT   = 40           #Duration of the text fade in
TEXT_DURATION  = 150          #Duration of the text screen time
FADE_OUT_TEXT  = 50           #Duration of the text fade out

TIME_TO_FADEOUT= 100          #Time lapse before the black screen vanishes
FADE_OUT_BLACK = 20           #Duration of the black screen fade out
#===============================================================================
#===============================================================================

class Scene_Chapter < SMScreen
  def initialize(chapter, introTrans, endTrans, xPos, yPos)
    super()
    @chapter=chapter
    @xPos = xPos
    @yPos = yPos
    @introTrans = introTrans
    @endTrans = endTrans
    @spriteViewport=$topScreen.getViewport
    
    main
  end
  
  def main
    pbStartScene
    pbUpdate
    pbEndScene    
  end
    
  def pbStartScene
    @finished=false
    @front=true
    
    addObj("blScreen",@xPos,@yPos,PATH + "BlScreen")
    @objectsList["blScreen"].set("opacity",0)
    
    addObj("Chapter",@xPos,@yPos,PATH + @chapter.to_s)
    @objectsList["Chapter"].set("opacity",0)
  end

  def pbUpdate
    pbMEPlay(ME_FILE,ME_VOLUME,ME_PITCH) if ME_ON

    if @introTrans
      FADE_TO_BLACK.times do
        pbWait(1)
        Graphics.update
        @objectsList["blScreen"].set("opacity",@objectsList["blScreen"].opacity+255/FADE_TO_BLACK)
      end
    else
      @objectsList["blScreen"].set("opacity",255)
    end
  
    pbWait(TIME_TO_TEXT)    
  
    FADE_IN_TEXT.times do
      pbWait(1)
      Graphics.update
       @objectsList["Chapter"].set("opacity",@objectsList["Chapter"].opacity+255/FADE_IN_TEXT)
    end
    
    pbWait(TEXT_DURATION)
  
    FADE_OUT_TEXT.times do
      pbWait(1)
      Graphics.update
      @objectsList["Chapter"].set("opacity",@objectsList["Chapter"].opacity-255/FADE_OUT_TEXT)
    end
    
    pbWait(TIME_TO_FADEOUT)
    
    if @endTrans
      FADE_OUT_BLACK.times do
        pbWait(1)
        Graphics.update
        @objectsList["blScreen"].set("opacity",@objectsList["blScreen"].opacity-255/FADE_OUT_BLACK)
      end
    end
  end
    
  def pbEndScene
    pbDisposeSpriteHash(@objectsList)
    @spriteViewport.dispose
    $Poketch_On_Forced = false
  end
end

###################################################
def pbChapter(chapter,introTrans=true,endTrans=true,x=0,y=0)
  $Poketch_On_Forced = true
  Scene_Chapter.new(chapter,introTrans,endTrans,x,y)
end