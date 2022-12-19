# SETTINGS ====================================================================#
module SinnohMap
    # You shouldn't touch these:
    ID   = "sinnohMap"
    PATH = SUSC::SUSC_PATH+"DPPTMap/"

    # Size of each tile in pixels:
    TILE_SIDE        = 14
    # Width  of the map in tiles:
    MAP_WIDTH_TILES  = 31
    # Height of the map in tiles:
    MAP_HEIGHT_TILES = 23             

    #MARGINS:
    # Left margin of the map in tiles (aka size in tiles of the left border of the map not to be taken into account):
    X_MARGIN = 3
    # Top  margin of the map in tiles (aka size in tiles of the top border of the map not to be taken into account):
    Y_MARGIN = 0

    # Names of the face icon files to use:
    ICON_NAME_M = "iconM"
    ICON_NAME_F = "iconF"            
    # Frequency of the minicursor in frames:
    MC_MOVEMENT_TIME = 20

    #TOP SCREEN SETTINGS:
    # Location text colors:
    LOC_NAME_FG_COLOR = Color.new( 87, 87, 87)
    LOC_NAME_BG_COLOR = Color.new(180,180,180)

    # Cursor sprite size:
    CURSOR_WIDTH  = 32
    CURSOR_HEIGHT = 32
    # Number of animation frames of the cursor:
    CURSOR_FRAMES = 2
    # Time for each of the cursor animation frames:
    CS_FRAME_TIME = 15
    # Delay of the cursor movement in time frames:
    CSMOVEPERIOD  = 3 

    # Number of last visited positions to be recorded:
    MC_STEPS_TRACKED = 5 
    # Period for the minicursor movement in time frames:
    MINI_CS_PERIOD = 40

    # Position of the location names on top screen:
    LOC_NAME_X = 256
    LOC_NAME_Y = 340

    #BOTTOM SCREEN SETTINGS:
    # Text to be displayed on the top part of the bottom screen:
    TAG_TEXT = "GUIDE MAP"
    # Location of the "TAG_TEXT" tag:
    TAG_X = 0
    TAG_Y = 0

    # Colors of the tag text:
    TAG_TEXT_FG_COLOR = Color.new(87,87,87)
    TAG_TEXT_BG_COLOR = Color.new(180,180,180)

    # Location of the tag text relative to the tag graphic:
    TAG_TEXT_X = 256
    TAG_TEXT_Y = -6

    # Location of the description panel:
    DESC_PANEL_X =  0
    DESC_PANEL_Y = 30

    # Location of the minimap relative to the description panel:
    MINIMAP_X = 20
    MINIMAP_Y = 12

    # SOUND EFFECTS:
    # Changing page SE:
    CHANGE_PAGE_SE = "townmap_page"

    # Opening and closing SE:
    EXIT_MAP_SE    = "gui_choose"   

    # Whether the description should be shown when the cursor is over a route:
    SHOW_DESC_ON_ROUTES = true
end
# STOP EDITING HERE ===========================================================#