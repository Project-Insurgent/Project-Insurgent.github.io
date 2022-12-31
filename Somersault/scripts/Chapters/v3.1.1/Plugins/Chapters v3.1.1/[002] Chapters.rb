#==============================================================================#
#                             Chapters Script v3.1.1                           #
#                               (by S.A.Somersault)                            #
#==============================================================================#
# IMPORTANT: NEEDS SUSc v5.0+ in order to work properly                        #
#==============================================================================#
#==============================================================================#
# Usage: pbChapter(NUMCHAPTER,INTROTRANS,ENDTRANS,XPOS,YPOS)
#==============================================================================#
# Where:
#  -NUMCHAPTER              -> number of the chapter
#  -INTROTRANS and ENDTRANS -> booleans. True if you want a fade to black
#     respectively at the beginning and at the end. (both optional. true by default)
#  -XPOS and YPOS           -> position of the script on screen and are both
#     optional (0 by default).
# Examples:
# pbChapter(0) will call the chapter 0
# pbChapter(2,false) will call the chapter 2 without a fade to black transition.
# pbChapter(3,true,20,5) will call the chapter 3 with fade, at position [20,5].
#==============================================================================#
#===============================================================================
class ChaptersView < SMModuleView
  include SMChapters
  def initialize(mod,ctrl=nil)
    super({:PATH => PATH, :CTRL => ctrl, :MOD => mod, :ID => ID})    
  end
  
  def init
    activate
    initScreens(true)

    @panels[:MAIN_PANEL].addObj("title","Chapter#{@mod.getChap}")
    @panels[:MAIN_PANEL].list["title"].z-=1
    
    for k in @panels.keys; @panels[k].opacity = 0; end
    pbMEPlay(ME_FILE,ME_VOLUME,ME_PITCH) if ME_ON

    if @mod.getIntroTrans
      FADE_TO_BLACK.times do
        for k in @panels.keys; @panels[k].sprite.opacity+=255/FADE_TO_BLACK; end
        Graphics.update
      end
    end
    
    pbWait(TIME_TO_TEXT)
    @panels[:MAIN_PANEL].list["title"].opacity = 255
  end
  
  def execute  
    FADE_IN_TEXT.times do
      @panels[:MAIN_PANEL].sprite.opacity-=255/FADE_IN_TEXT
      Graphics.update
    end
    
    pbWait(TEXT_DURATION)
  
    FADE_OUT_TEXT.times do
      @panels[:MAIN_PANEL].sprite.opacity+=255/FADE_OUT_TEXT
      Graphics.update
    end
    
    pbWait(TIME_TO_FADEOUT)
    @panels[:MAIN_PANEL].list["title"].visible = false
  end
  
  def finish
    if @mod.getEndTrans
      FADE_OUT_BLACK.times do
        for k in @panels.keys; @panels[k].sprite.opacity-=255/FADE_OUT_BLACK; end
        Graphics.update
      end
    end
    deactivate
  end
end

class ChaptersModule < SMModule
  include SMChapters
  def initialize(chapter, introTrans, endTrans)
    super()
    @chapter    = chapter
    @introTrans = introTrans
    @endTrans   = endTrans
    @finished   = false
    @front      = true
    @view = ChaptersView.new(self)
    main
  end
  
  def getChap;       return @chapter;    end
  def getIntroTrans; return @introTrans; end
  def getEndTrans;   return @endTrans;   end
  def finished?;     return @finished;   end
  def front?;        return @front;      end
  
  def init;    @view.init;    end
  def execute; @view.execute; return false; end
  def finish;  @view.finish;  removePanel;  end
end
#===============================================================================
def pbChapter(chapter,introTrans=true,endTrans=true)
  ChaptersModule.new(chapter,introTrans,endTrans)
end
#===============================================================================