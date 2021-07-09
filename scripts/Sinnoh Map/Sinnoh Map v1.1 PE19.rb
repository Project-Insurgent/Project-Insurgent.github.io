#==============================================================================#
#                                 SINNOH MAP v1.1                              #
#                                (by A.Somersault)                             #
#==============================================================================#
# A script that implements a gen 4 style map!                                  #
# IMPORTANT: NEEDS SUSc v4.0+ in order to work properly                        #
#==============================================================================#
# Current problem(s):
#   -There is a bit of lag when loading location descriptions.
#   -For some reason ValleyWindworks spawns a red dot location when visited
#      L-> Provisional solution: added a -1 as icon id
#==============================================================================#
# Future features:
# -Fly destination mode
#==============================================================================#
# Usage: pbSinnohMap                                                           #
#==============================================================================#
#                                 PARAMETERS                                   #
#==============================================================================#
TILE_SIDE        = 14             #size of each tile in pixels
MAP_WIDTH_TILES  = 31             #width  of the map in tiles 
MAP_HEIGHT_TILES = 23             #height of the map in tiles

#borders size:
X_OFFSET = 2                      #num of tiles the map will be moved rightwards
Y_OFFSET = 0                      #num of tiles the map will be moved downwards

#Names of the icon files you want to use
ICON_NAME_M = "iconM"
ICON_NAME_F = "iconF"

BLINKING_TIME    = 15             #blinking period of the cursor in frames
CSMOVEPERIOD     = 1              #delay of the cursor movement in frames

MC_MOVEMENT_TIME = 20             #frequency of the minicursor in frames

CHANGE_PAGE_SE = "townmap_page"   #changing page SE
EXIT_MAP_SE    = "gui_choose"     #opening and closing SE

#position of the location names on top screen
LOC_NAME_X = SM_SCREEN_WIDTH/2
LOC_NAME_Y = 345

SHOW_DESC_ON_ROUTES = true        #whether the description should be shown
                                  #when the cursor is over a route
#==============================================================================#
#                               DO-NOT-TOUCH STUFF                             #
#                    (Unless you want the script to stop working)              #
#==============================================================================#
MAP_PATH= "Graphics/Pictures/SinnohMap/"
$mcPositions = {}
HMARGIN = MAP_WIDTH_TILES/4
VMARGIN = MAP_HEIGHT_TILES/4
#==============================================================================#
#                               STOP EDITING HERE                              #
#==============================================================================#
#==============================================================================#
#                                   TOP SCREEN                                 #
#==============================================================================#
class MapTopScreen < SMScreen
  def initialize(name,x,y,viewport,managerRef)
    super(MAP_PATH,name,x,y,viewport,managerRef)
    pbThrow("Unable to launch the map. Reason: Don't set CSMOVEPERIOD value to 0!",true) if CSMOVEPERIOD == 0
    aux = [0,2]
    if $LOCATIONS_ARRAY[$game_map.map_id]
      aux = $LOCATIONS_ARRAY[$game_map.map_id][0,2]
    end
    
    if $mcPositions.length <= 0
      for i in 0...MC_STEPS_TRACKED; $mcPositions[i]=[aux[0],aux[1]]; end
    end
      
    placeVisitedLocations
    
    @PlayerPos = pbObtainRealPos(aux,1,[x,y])  

    #minicursor:
    @mcCounter = 0
    @mcFrame = 0

    _x=(@PlayerPos[0]+X_OFFSET)*TILE_SIDE
    _y=(@PlayerPos[1]+Y_OFFSET)*TILE_SIDE
    addObj("minicursor",_x,_y,"minicursor")
    
    #player icon:
    plIconFileName = $Trainer.isMale? ? ICON_NAME_M : ICON_NAME_F
    addObj("PlayerIcon",_x,_y,plIconFileName)
    
    @objectsList["PlayerIcon"].ox = 10
    @objectsList["PlayerIcon"].oy = 10
    
    #create cursor:
    @csMovePeriod = 0
    @cursorCounter = 0
    @cursorSkin = 0
    addObj("Cursor",_x,_y,"Cursor")
    
    @objectsList["Cursor"].set_src_rect(0,0,@objectsList["Cursor"].width/2,@objectsList["Cursor"].height)
    @objectsList["Cursor"].ox=10
    @objectsList["Cursor"].oy=10
    
    #create bitmap for location text:
    addObj("Loc",0,0,name)
    @objectsList["Loc"].clear
    
    #tag for single screen mode:
    addObj("sgScTag",400,300,"tag_singleScreen")
    @objectsList["sgScTag"].visible=!DOUBLESCREEN
  end
  
  def placeVisitedLocations
    prevName = ""
    for i in $LOCATIONS_ARRAY.keys
      if $LOCATIONS_ARRAY[i][5] && prevName != $LOCATIONS_ARRAY[i][4]
        prevName = $LOCATIONS_ARRAY[i][4]
        iconNeeded=$LOCATIONS_ARRAY[i][5]
        
        _x = ($LOCATIONS_ARRAY[i][0]+X_OFFSET)*TILE_SIDE
        _y = ($LOCATIONS_ARRAY[i][1]+Y_OFFSET)*TILE_SIDE
        addObj("mapIcons"+i.to_s,_x,_y,"mapIconsSel")
        @objectsList["mapIcons"+i.to_s].set_src_rect(
          TILE_SIDE*2*(iconNeeded%4), TILE_SIDE*2*(iconNeeded/4),
          TILE_SIDE*2, TILE_SIDE*2
        )
        @objectsList["mapIcons"+i.to_s].visible=$PokemonGlobal.visitedMaps[i]
      end
    end
  end
#Cursor handling ---------------------------------------------------------------
  def updateCursorBlinking
    if @cursorCounter == 0
      @cursorSkin = 1-@cursorSkin
      @objectsList["Cursor"].set_src_rect(
        @cursorSkin*@objectsList["Cursor"].width/2,
        0,
        @objectsList["Cursor"].width/2,
        @objectsList["Cursor"].height
      )
    end
    @cursorCounter = (@cursorCounter + 1) % BLINKING_TIME
  end
  
  def updateCursorPos
    @objectsList["Cursor"].x=(@PlayerPos[0]+X_OFFSET)*TILE_SIDE
    @objectsList["Cursor"].y=(@PlayerPos[1]+Y_OFFSET)*TILE_SIDE
  end
  
  def updateCursor
    updateCursorBlinking
    updateCursorPos
  end
  
  def updateMinicursorPos
    if @mcCounter == 0
      newPos = pbObtainRealPos($mcPositions[@mcFrame],TILE_SIDE,[@sprite.x,@sprite.y],[0,0],1,[X_OFFSET,Y_OFFSET])
      @objectsList["minicursor"].x=newPos[0]
      @objectsList["minicursor"].y=newPos[1]
      @mcFrame = (@mcFrame + 1) % MC_STEPS_TRACKED
    end
    @mcCounter = (@mcCounter + 1) % MC_MOVEMENT_TIME
  end
  
  def getCursorPos; return @PlayerPos; end

  def updatePos
    if Input.press?(Input::UP)
      @PlayerPos[1] = (@PlayerPos[1] - 1) if @PlayerPos[1] > Y_OFFSET
    elsif Input.press?(Input::DOWN)
      @PlayerPos[1] = (@PlayerPos[1] + 1) if @PlayerPos[1] < MAP_HEIGHT_TILES
    end
    
    
    if Input.press?(Input::LEFT)
      @PlayerPos[0] = (@PlayerPos[0] - 1) if @PlayerPos[0] > X_OFFSET
    elsif Input.press?(Input::RIGHT)
      @PlayerPos[0] = (@PlayerPos[0] + 1) if @PlayerPos[0] < MAP_WIDTH_TILES
    end
  end
  
  def updateText(locId)
    #Kernel.pbMessage(_INTL("{1}",locId))
    text = locId != -1 ? $LOCATIONS_ARRAY[locId][4] : ""
    @objectsList["Loc"].clear
    @objectsList["Loc"].setSystemFont
    
    lText=[[_INTL(text),@sprite.x+LOC_NAME_X,@sprite.y+LOC_NAME_Y,2,Color.new(87,87,87),Color.new(180,180,180)]]
    @objectsList["Loc"].drawText(lText)
    pbWait(2)
  end
  
  def update(locId)
    if @csMovePeriod == 0
      updatePos
      updateCursor
    end
    @csMovePeriod = (@csMovePeriod+1) % CSMOVEPERIOD
    
    updateText(locId)
    updateMinicursorPos

    if !DOUBLESCREEN and (Input.press?(Input::C) or        #0x4B == 'K' Key
      (Input.press?(Input::B) && @managerRef.detailView?)) 
      pbSEPlay(CHANGE_PAGE_SE) #@detailMap = !@detailMap
      mode = @managerRef.detailView? ? 1 : -1

      curtainEffect(20,mode,"v")
      @managerRef.switchDetMap
    end
  end
end
#==============================================================================#
#                                BOTTOM SCREEN                                 #
#==============================================================================#
class MapBtmScreen < SMScreen
  def initialize(name,x,y,viewport,managerRef)
    super(MAP_PATH,name,x,y,viewport,managerRef)
    
    @curLocName = ""
    @detailMap = false
    
    #button:
    addObj("Button",192,162,"LowScBtn")
    @objectsList["Button"].set_src_rect(0,0,@objectsList["Button"].width/5,@objectsList["Button"].height)
    @objectsList["Button"].visible=DOUBLESCREEN
    
    #detail Map:
    addObj("det_Bg",0,0,"lowerscreenShowMode")
    w = @objectsList["det_Bg"].width
    h = @objectsList["det_Bg"].height
    @objectsList["det_Bg"].zoom_x=2
    @objectsList["det_Bg"].zoom_y=2
    @objectsList["det_Bg"].ox=w/4
    @objectsList["det_Bg"].oy=h/4
    @objectsList["det_Bg"].visible=!DOUBLESCREEN
    
    #map Tag:
    addObj("maptag",0,0,"Tag")
    @objectsList["maptag"].visible=!DOUBLESCREEN
    @objectsList["maptag"].setSystemFont
    lText=[[_INTL("GUIDE MAP"),x+256,y-5,2,Color.new(87,87,87),Color.new(180,180,180)]]
    @objectsList["maptag"].drawText(lText)
    
    #desc Panel:
    addObj("descPanel",0,30,"descPanel")
    @objectsList["descPanel"].addObj("minimap",20,12,MAP_PATH+"signPosts/Empty")
    
    descTitle = SMSprite.new(@sprite.x,@sprite.y,MAP_PATH+name,@spriteViewport,self)
    descTitle.clear
    descTitle.setSystemFont
    @objectsList["descPanel"].insertObj(descTitle,"descTitle")
    
    descText = SMSprite.new(@sprite.x,@sprite.y,MAP_PATH+name,@spriteViewport,self)
    descText.clear
    descText.setSystemFont
    @objectsList["descPanel"].insertObj(descText,"descText")
    
    @objectsList["descPanel"].visible=false
    
    #black curtain:
    addObj("blCurtain",0,0,"blackCurtain")
    @objectsList["blCurtain"].zoom_y=0
    @objectsList["blCurtain"].visible=false 
  end
  
  def detailMap; return @detailMap; end
    
  def curtainAnimation
    if DOUBLESCREEN
      @objectsList["blCurtain"].visible=true
      
      @objectsList["blCurtain"].curtainEffect(20,1,"v")
  
      @objectsList["det_Bg"].visible=!@objectsList["det_Bg"].visible
      @objectsList["descPanel"].visible=false
      @objectsList["maptag"].visible=!@objectsList["maptag"].visible
      placeBtmMap
          
      @objectsList["blCurtain"].curtainEffect(20,-1,"v")
      
      @objectsList["blCurtain"].visible=false
    end
    @detailMap = !@detailMap
  end
  
  def showDesc(locId)
    if locId != -1
      path = MAP_PATH+"signPosts/"+$LOCATIONS_ARRAY[locId][4]
      locName = $LOCATIONS_ARRAY[locId][4]
      if !path.include?("Route") || SHOW_DESC_ON_ROUTES
        offsetX = FileTest.image_exist?(path) ? 96 : 10
        @objectsList["descPanel"].objectsList("descTitle").clear
        lText=[[_INTL(locName),@sprite.x+104+offsetX,@sprite.y+40,2,Color.new(245,245,245),Color.new(215,215,215)]]
        @objectsList["descPanel"].objectsList("descTitle").drawText(lText)

        dText = $DESC_ARRAY[locName] ? $DESC_ARRAY[locName] : ""
        if @curLocName != locName
          @objectsList["descPanel"].objectsList("descText").clear
          descText = [@sprite.x+10,@sprite.y+120,500,_INTL(dText),Color.new(245,245,245),Color.new(215,215,215)]
          @objectsList["descPanel"].objectsList("descText").drawFTextEx(descText)
        end
        path = MAP_PATH+"signPosts/Empty" if !FileTest.image_exist?(path)
        @objectsList["descPanel"].list["minimap"].bitmap=Bitmap.new(path)
        @objectsList["descPanel"].visible=true
      else
        @objectsList["descPanel"].visible=false
      end
      @curLocName = locName
    else
      @objectsList["descPanel"].visible=false
    end
  end
  
  def update(locId)
    if !@detailMap
      if DOUBLESCREEN
        if @objectsList["Button"].leftClick?(nil,5,EXIT_MAP_SE)
          pbSEPlay(CHANGE_PAGE_SE)
          curtainAnimation
        end
      else
        placeBtmMap
      end
    else
      if DOUBLESCREEN and Input.press?(Input::B)
        pbSEPlay(EXIT_MAP_SE)
        pbSEPlay(CHANGE_PAGE_SE)
        curtainAnimation
      else
        placeBtmMap
        showDesc(locId)
      end
    end
  end
  
  def isDetailMapOn; return @detailMap; end
  def switchDetMap; @detailMap = !@detailMap; end
    
  def placeBtmMap
    #(MAP_WIDTH_TILES-7) && @managerRef.getCursorPos[0] > 8
    if @managerRef.getCursorPos[0] < (MAP_WIDTH_TILES-HMARGIN) && @managerRef.getCursorPos[0] > HMARGIN
      posX = @managerRef.getCursorPos[0]
    else
      posX = @managerRef.getCursorPos[0] <= HMARGIN ? HMARGIN+1 : (MAP_WIDTH_TILES-HMARGIN)
    end
    @objectsList["det_Bg"].x=@sprite.x+SM_SCREEN_WIDTH-32*posX
    
    #(MAP_HEIGHT_TILES-5) && @managerRef.getCursorPos[1] > 6
    if @managerRef.getCursorPos[1] < (MAP_HEIGHT_TILES-VMARGIN) && @managerRef.getCursorPos[1] > VMARGIN
      posY = @managerRef.getCursorPos[1]
    else
      posY = @managerRef.getCursorPos[1] <= VMARGIN ? VMARGIN+1 : (MAP_HEIGHT_TILES-VMARGIN)
    end
    @objectsList["det_Bg"].y=@sprite.y+SM_SCREEN_HEIGHT-32*(posY)
  end
end
#===============================================================================
class SinnohMap
  def initialize(x=0,y=0)
    @mapdata = pbLoadTownMapData
    playerpos=!$game_map ? nil : GameData::MapMetadata.get($game_map.map_id).town_map_position
    #pbRgssOpen("Data/townmap.dat","rb"){|f|@mapdata=Marshal.load(f)}
    #playerpos=!$game_map ? nil : pbGetMetadata($game_map.map_id,MetadataMapPosition)   
    
    pbFadeOutIn(999999999) {
      if $POKETCHINSTALLED 
        pbRemovePoketch
        $POKETCHBLACK.opacity = 0
      end
      str = "#{@mapdata[playerpos[0]][1]}"
      pbLoadSinnohMapData
      @btmScreen = MapBtmScreen.new("BtmScreen",x,y,$btmScreen.getViewport,self)
      @topScreen = MapTopScreen.new(str,        x,y,$topScreen.getViewport,self)
      pbSEPlay(CHANGE_PAGE_SE)
    }    
    
    main
  end
  
  def main
    update
    dispose
  end
  
  def getCursorPos; return @topScreen.getCursorPos; end
  def detailView?; return @btmScreen.detailMap; end
  def switchDetMap; @btmScreen.switchDetMap; end
    
  def update
    while !Input.press?(Input::B) do
      Input.update

      id = pbCheckAllOnLocation(@topScreen.getCursorPos)

      @topScreen.update(id)
      @btmScreen.update(id)
      
      Graphics.update
    end
  end
  
  def dispose
    pbSEPlay(EXIT_MAP_SE)
    pbFadeOutIn(999999999) {
      if $POKETCHINSTALLED
        pbGetPoketch($PokemonGlobal.poketchModel,false)
        $POKETCHBLACK.opacity = 0
      end
      @topScreen.dispose
      @btmScreen.dispose
    }
  end
end
#===============================================================================
MetadataMapPosition = 7
def pbShowMap(region=-1,wallmap=false)
  pbSinnohMap
end
#===============================================================================
def pbSinnohMap; sinnohMap = SinnohMap.new; end