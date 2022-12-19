# SETTINGS ====================================================================#
module SMChapters
    PATH = SUSC::SUSC_PATH+"Chapters/"
    ID   = "Chapters"

    # Whether to play a fanfare (and File name of such fanfare, located in ME)
    ME_ON = true                  
    ME_FILE = "Azure Flute.mid"

    # Volume paramters
    ME_VOLUME = 100
    ME_PITCH  = 80

    # Time-related parameters in frames (60 frames = 1 second, aprox)
    # Duration of the first fade to black
    FADE_TO_BLACK  = 15
    # Time lapse before the text appears
    TIME_TO_TEXT   = 60           

    # Duration of the text fade in
    FADE_IN_TEXT   = 40
    # Duration of the text screen time
    TEXT_DURATION  = 150
    # Duration of the text fade out
    FADE_OUT_TEXT  = 50           

    # Time lapse before the black screen vanishes
    TIME_TO_FADEOUT= 100 
    # Duration of the black screen fade out
    FADE_OUT_BLACK = 20           
end
# STOP EDITING HERE ===========================================================#