Name         = Chapters Script
Version      = 3.1.0
Requires     = Somersault Utilities Script,5.1
Credits      = S.A.Somersault

## How to install the catching tutorial script:##
(Please follow the steps rigurously. If you skip one, it won't work properly)

0. Install Somersault's Utilities Script.

1. Extract all the folders (except this file, of course) into the root directory of your game.

2. DONE! ENJOY!

#==============================================================================#
                                   ##USAGE:##
#==============================================================================#
pbChapter(NUMCHAPTER,INTROTRANS,ENDTRANS,XPOS,YPOS)
#==============================================================================#
# Where:
#  -NUMCHAPTER              -> number of the chapter
#  -INTROTRANS and ENDTRANS -> booleans. True if you want a fade to black respectively at the beginning and at the end. (both optional. true by default)
#  -XPOS and YPOS           -> position of the script on screen and are both optional (0 by default).
# Examples:
# pbChapter(0) will call the chapter 0
# pbChapter(2,false) will call the chapter 2 without a fade to black transition.
# pbChapter(3,true,20,5) will call the chapter 3 with fade, at position [20,5].
#==============================================================================#
