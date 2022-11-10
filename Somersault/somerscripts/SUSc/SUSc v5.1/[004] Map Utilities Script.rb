#==============================================================================#
#                           MAP UTILITIES SCRIPT v3.0                          #
#                             (by S.A. Somersault)                             #
#==============================================================================#
#  This is an auxiliar one for my scripts that are somehow related with maps.  #
#==============================================================================#
# SETTINGS ====================================================================#
  # Size of the n last visited positions to be recorded
  MC_STEPS_TRACKED = 4        
  SHOW_MAP_LOADING_LOG = true

  #lines with the following keys will be saved as they are, keeping commas etc:
  #Note: They all will be saved as strings.
  STR_DATA_TYPE = [ "Name", "Desc" ]

  #lines with the following keys will be saved as they are, keeping commas etc:
  #Note: They all will be saved as strings.
  NUM_DATA_TYPE = [ "Icon" ]

  #lines with the following keys will be saved as booleans.
  #Possible values: {True, False}
  BOOL_DATA_TYPE   = []

  #lines with the following keys will be saved as an array, separating elements 
  #with commas.
  #Note: They all will be saved as strings.
  STR_ARRAY_DATA_TYPE   = []

  #Similar thing as the previous one but in this case with numbers:
  NUM_ARRAY_DATA_TYPE   = [ "Pos", "Size", "SecMaps" ]

  #Similar thing as the previous one but in this case with Booleans:
  #Possible values: {True, False}
  BOOL_ARRAY_DATA_TYPE   = []

  #Default values used when the resepctive keys are not provided. If you don't 
  #add a key here, then it is mandatory to include it for each map:
  #(tags "Name" and "Id" are special and hence they are not included here)
  DEFAULT_VALUES    = {
    "Icon" => -1,
    "Size" => [1,1],
    "Pos"  => [0,0],
    "Desc" => "",
    "SecMaps" => []
  }
#==============================================================================#
#==============================================================================#
#                              STOP EDITING HERE                               #
#==============================================================================#
COMMENT_TOKEN = "##"
SEPARATOR = "####################"
SIGNPOSTSPATH = SUSC::SUSC_PATH + "DPPTsignPosts/"
PBS_SINNOH_PATH = "Plugins/SUSc/sinnohMap.txt"
$LOCATIONS_ARRAY={}
$DESC_ARRAY = {}
$enteredNewMap = true
$currentMapId = -1
$curPortionX  = -1
$curPortionY  = -1
$mcPositions  =[]
#==============================================================================#
=begin
    attr_reader :id
    attr_reader :outdoor_map
    attr_reader :announce_location
    attr_reader :can_bicycle
    attr_reader :always_bicycle
    attr_reader :teleport_destination
    attr_reader :weather
    attr_reader :town_map_position
    attr_reader :dive_map_id
    attr_reader :dark_map
    attr_reader :safari_map
    attr_reader :snap_edges
    attr_reader :random_dungeon
    attr_reader :battle_background
    attr_reader :wild_battle_BGM
    attr_reader :trainer_battle_BGM
    attr_reader :wild_victory_ME
    attr_reader :trainer_victory_ME
    attr_reader :wild_capture_ME
    attr_reader :town_map_size
    attr_reader :battle_environment

    GameData::MapMetadata.get($game_map.map_id).outdoor_map
=end


module SMapUtil
  def self.getData(id,type=nil)
    #$smMapDataPtrs[MapId] --> MapName
    #$smMapData[MapName]: { "Common" => {...}, "Maps" => { map_1, map_2, ... }  }
    #where map_i = { "Icon" => N, "Pos" => [X,Y], "Size" => [W,H], "SecMaps" =>[...] }
    data = $smMapData[$smMapDataPtrs[id]]

    ret = nil
    if data
      if data["Maps"][id] #if the id is a mapId
        #Appends the specific data for that mapId as well as the common one. Also, appends the mapName in order to have the full information about that map:
        ret = data["Maps"][id].merge(data["Common"]).merge({ "Name" => $smMapDataPtrs[id] })  
      elsif $smMapData.keys.include?(id) #if the id is a map name
        ret = data["Maps"]
      end
    end                  
    return type == nil || ret == nil ? ret : ret[type]
  end

  def self.pbLoadSMMapData
    $smMapData     = {}
    $smMapDataPtrs = {}
    begin
      file = File.open(PBS_SINNOH_PATH)
      begin
        puts("====== SOMERSAULT MAP UTILITIES LOADING LOG ======") if $DEBUG and SHOW_MAP_LOADING_LOG
        line = file.readline()
        curId = -1
        curName = ""
        while !file.eof?
          if !line.include?(COMMENT_TOKEN) #ignore lines with the comment token
            line = line.tr("\n",'').gsub(": ",":").split(':',-1)
            key  = line[0]
            data = line[1]

            if key == "Name"
              curName = data
              $smMapData[curName] = {}
              $smMapData[curName]["Maps"] = {}    #hash with all the maps sharing the same name
              $smMapData[curName]["Common"] = {}  #common data for all maps with the same name
              $smMapData[curName]["Common"]["Desc"] = DEFAULT_VALUES["Desc"]
              puts("\n----------[ Map Name: #{curName.upcase} ]----------") if $DEBUG and SHOW_MAP_LOADING_LOG
            elsif key == "Id"
              curId = data.to_i
              $smMapDataPtrs[curId] = curName

              #initializing default values:
              $smMapData[curName]["Maps"][curId] = DEFAULT_VALUES.clone
              $smMapData[curName]["Maps"][curId].delete("Desc")
              #$smMapData[curName]["Maps"][curId] = {}
              #for key in DEFAULT_VALUES.keys; $smMapData[curName]["Maps"][curId][key] = DEFAULT_VALUES[key] unless key == "Desc"; end
              puts("   Map id -> #{curId}:")            
            else 
              #inserts the field into the hashmap:
              key = key.gsub("\t","")
              dataRet,str = processMapData(key,data)
              $smMapData[curName]["Maps"][curId][key] = dataRet.dup
              puts(str) if $DEBUG and SHOW_MAP_LOADING_LOG
            end
          end
          line = file.readline()
        end
      rescue

      end
      file.close()
    rescue
      puts("There was an error opening the file " + PBS_SINNOH_PATH)
    end

    #creating pointers for all the map ids in the "Maps" field of a certain mapId:
    for mapName in $smMapData.keys
      mapHashMap = {}
      for mapId in $smMapData[mapName]["Maps"].keys
        for map in $smMapData[mapName]["Maps"][mapId]["SecMaps"]
          $smMapDataPtrs[map] = mapName
          $smMapDataPtrs[mapName] = mapName
          mapHashMap[map] = {}
          mapHashMap[map] = $smMapData[mapName]["Maps"][mapId].clone
          mapHashMap[map].delete("SecMaps")
          #myMap = $smMapData[mapName]["Maps"][mapId]
          #for key in myMap.keys; mapHashMap[map][key] = myMap[key] unless key == "SecMaps"; end
          mapHashMap[map]["Size"] = [1,1]
        end
      end
      $smMapData[mapName]["Maps"] = $smMapData[mapName]["Maps"].dup.merge(mapHashMap)
      #puts(mapName + ": " + $smMapData[mapName]["Maps"].keys.to_s)
    end

    #create array for tracked coordinates:
    $mcPositions = []
    $inValidMap = false
    for i in 0...MC_STEPS_TRACKED; $mcPositions.append([-1,-1]); end

    pbUpdLocData
    
  end

  def self.processMapData(key,data)
    str = (key == "Desc" ? "" : "   ") + "   #{key}: " #this is just for the debug log

    #formats the string data type:
    data,str = processStrData(key,data,str)
    
    #formats the numerical data type:
    data,str = processNumData(key,data,str)

    #formats the array data types:
    data,str = processArrayData(key,data,str)

    #here you can add more functionality. Simply add an if statement with the following format: if DATA_TYPE.include?(key):
    #...

    return data,str
  end

  def self.processNumData(key,data,logStr="",extraCond=true)
    if NUM_DATA_TYPE.include?(key) && extraCond
      data = data.to_i
      logStr+=data.to_s+"\n"
    end
    return data,logStr
  end

  def self.processStrData(key,data,logStr="",extraCond=true)
    if STR_DATA_TYPE.include?(key) && extraCond
      logData = data.length >= 40 ? data[0,40] + "..." : data
      logStr += logData + "\n"
    end
    return data,logStr
  end

  def self.processArrayData(key,data,logStr="",extraCond=true)
    if STR_ARRAY_DATA_TYPE.include?(key) || NUM_ARRAY_DATA_TYPE.include?(key) || BOOL_ARRAY_DATA_TYPE.include?(key)
      data = data.split(',',-1)

      logStr += "["
      for i in 0...data.length
        logStr += data[i] + (i < data.length-1 ? ", " : "")
        data[i] = data[i].to_i  if NUM_ARRAY_DATA_TYPE.include?(key)
        data[i] = data[i] == "True" if BOOL_ARRAY_DATA_TYPE.include?(key)                
      end
      logStr += "]\n"
    end
    return data,logStr
  end

  def self.pbUpdLocData
    pbUpdateCurPos
    pbUpdateMapPosTrack
  end

  def self.pbUpdateCurPos(modify=true)
    mapData = getData($game_map.map_id)
    $curPortionX = 0
    $curPortionY = 0 
    if mapData  
      #checking in which chunk of the town/route/city is the player
      #find x portion
      if mapData["Size"][0] > 1
        for i in 0...mapData["Size"][0]
            ($curPortionX = i; break) if modify && ($game_player.x <= ($game_map.width * (i+1) / mapData["Size"][0]))
        end
      end

      #find y portion
      if mapData["Size"][1] > 1
        for i in 0...mapData["Size"][1]
          ($curPortionY = i; break) if modify && ($game_player.y <= ($game_map.height * (i+1) / mapData["Size"][1]))
        end
      end
    end
  end
  
  def self.pbUpdateMapPosTrack
    mapData = getData($game_map.map_id)
    oldInValidMap = $inValidMap
    if mapData
      $inValidMap = true
      #if starting the game in an invalid map, when changing from to a valid one for the first time, apply a full refresh of the record.
      #otherwise, just shift the array one position and add new entry:
      for k in 0...(oldInValidMap ? 1 : MC_STEPS_TRACKED)
        $mcPositions[0] = [
          mapData["Pos"][0]+$curPortionX,
          mapData["Pos"][1]+$curPortionY]
      end
    end
  end

  def self.pbCheckChangingPortions
    change = false    
    data = getData($game_map.map_id)
    if data
      if $currentMapId == $game_map.map_id
        $enteredNewMap = false

        #check whether the player has moved to a new chunk inside the same map
        chunkWidthSize  = $game_map.width  / data["Size"][0]
        chunkHeightSize = $game_map.height / data["Size"][1]
        change = ($game_player.x - ($game_player.x % chunkWidthSize)  - chunkWidthSize *$curPortionX) != 0 ||
                 ($game_player.y - ($game_player.y % chunkHeightSize) - chunkHeightSize*$curPortionY) != 0
      else
        $currentMapId = $game_map.map_id
        $enteredNewMap = true
        change = true
      end
    end
    return change
  end
  
  def self.pbObtainCoord(cmp,tileSize,scale,spritePos,offset, offset2)
    return (scale*(tileSize*(cmp+offset+offset2)+spritePos)).to_i
  end
  
  def self.pbObtainRealPos(cmp,tileSize=1,spritePos=[0,0],scale=1,offset=[0,0])
    newX = pbObtainCoord(cmp[0],tileSize,scale,spritePos[0],offset[0],$curPortionX)
    newY = pbObtainCoord(cmp[1],tileSize,scale,spritePos[1],offset[1],$curPortionY)
    return [newX,newY]
  end
  
  def self.pbOnLocation?(mapId,pos)
    data = getData(mapId)
    return data && pos[0] >= data["Pos"][0] && pos[0] < data["Pos"][0] + data["Size"][0] &&
                   pos[1] >= data["Pos"][1] && pos[1] < data["Pos"][1] + data["Size"][1]
  end
  
  def self.pbGetLocationName(pos)
    for key in $smMapData.keys
      for mapId in $smMapData[key]["Maps"].keys
        return key if pbOnLocation?(mapId,pos)
      end
    end
    return nil
  end
end
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :locations_array
  attr_accessor :desc_array
  
  def locations_array
    @locations_array = nil if !@locations_array
    return @locations_array
  end
  
  def desc_array
    @desc_array = nil if !@desc_array
    return @desc_array
  end
end

class PokemonLoadScreen
  alias old_PbStartLoadScreen pbStartLoadScreen
  def pbStartLoadScreen
    old_PbStartLoadScreen
    SMapUtil.pbLoadSMMapData
  end
end

Events.onStepTaken += proc do;
  SMapUtil.pbUpdLocData if SMapUtil.pbCheckChangingPortions;
end
#===============================================================================
$Fog_frame_counter = 0

def pbSetFogName(name = ""); $game_map.fog_name = name; end
def pbSetFogOpacity (_opacity = 255); $game_map.fog_opacity = _opacity; end
def pbSetFogSx(val=0); $game_map.fog_sx = val; end
def pbSetFogSy(val=0); $game_map.fog_sy = val; end
def pbSetFogHue(val); $game_map.fog_hue = val; end
def pbTintFogDayNight; $game_map.start_fog_tone_change(PBDayNight.getTone(), 0); end
def pbTintMapDayNight; $game_screen.start_tone_change(PBDayNight.getTone(),0); end

#JUST TESTING STUFF
def pbChangeFogAnim(_fogName, numFrames = 1, nightSprite = false, _opacity = 255)
  fogName = _fogName
  fogName += "n" if $game_switches[15] && nightSprite
  fogName += $Fog_frame_counter.to_s
  
  pbSetFogOpacity(_opacity)
  pbSetFogName(fogName)
  pbTintFogDayNight if !nightSprite || !$game_switches[15]
  $Fog_frame_counter = ($Fog_frame_counter + 1) % numFrames
end