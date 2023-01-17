# SETTINGS ====================================================================#
module DPPT_TV
    #You shouldn't touch these:
    ID   = "dpptTV"
    PATH = SUSC::SUSC_PATH+"DPPTV/"

    #Default exposition time for when it is not passed any specific value as a parameter
    DEF_WAITTIME  = 10

    #Vars speed (the higher the value, the lower the speed):
    BARS_SPEED = 2

    #Text Foreground Color:
    TFG_COLOR = Color.new(245,245,245)

    #Text Background Color:
    TBG_COLOR = Color.new(175,175,175)

    #Array of texts to be displayed
    TEXTS = [
        # Text a: ---------------------------------------------------------------------------
        "\"Welcome to a new episode of <b>'The Good News'</b>! "+
        "Today we have an extraordinary news from Eterna City to share with you!\n\n"+
        "After Gardenia's temporal retirement due to her leg's injury, we can now "+
        "confirm that there will be a new young gym leader that will face aspirants during her absence!",

        # Text b: ---------------------------------------------------------------------------
        "\"Good morning, Sinnoh! We couldn't start the day in a better way having the "+
        "great news we have to share with you!\n\n"+
        "Alola's Pokemon League has now officially opened its doors! Who will be crowned "+
        "as the very first Alolan Champion? We will provide you more information "+
        "as the events develop.\"",

        # Text c: ---------------------------------------------------------------------------
        "\"As you can see, several space-time deformations are appearing all over "+
        "the tropical region of Alola.\n\n"+
        "Scientists still don't know why they have appeared, or who cre... WAIT A "+
        "SECOND! WHAT'S THAT! Strange creatures are merging from the wormholes!!! Could "+
        "these creatures be Pokémon?\""
        # Text d: You can add more here: ----------------------------------------------------
        # ...
    ]
end
# STOP EDITING HERE ===========================================================#