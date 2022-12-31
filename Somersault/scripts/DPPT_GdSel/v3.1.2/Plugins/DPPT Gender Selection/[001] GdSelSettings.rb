# SETTINGS ====================================================================#
module DPPTGenderSel
    PATH = SUSC::SUSC_PATH+"DPPTGenderSel/"
    ID = "GenderSel"

    # name of the female graphic.
    GENDERFEMALE = "Rebel"
    # name of the male graphic.
    GENDERMALE   = "Rogue"       

    # whether the walking animation will be played
    ANIMATED = true              

    # width and height of each Male frame 
    FRAMEWIDTH_M = 47
    FRAMEHEIGHT_M = 109            

    # width and height of each Female frame
    FRAMEWIDTH_F = 52                        
    FRAMEHEIGHT_F = 110            

    # number of frames in the animation
    NUMFRAMES = 6
    # animation speed (the higher, the slower the animation will be; min 1)
    INVSPEED  = 6

    #male position on screen:
    MALEX = 340
    MALEY = 40

    #female position on screen:
    FEMALEX = 170
    FEMALEY = 40

    #keys to select the corresponding characters (Options: {Input::LEFT, Input::RIGHT, Input::UP, Input::DOWN}):
    FEMALE_ARROW = Input::LEFT
    MALE_ARROW   = Input::RIGHT

    #initial selected character (0 for boy, 1 for girl):
    INITIAL_SELECTION = 1
end
# STOP EDITING HERE ===========================================================#