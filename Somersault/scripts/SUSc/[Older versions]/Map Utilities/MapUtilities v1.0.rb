#==============================================================================#
#                           MAP UTILITIES SCRIPT v1.0                          #
#                              (by A. Somersault)                              #
#==============================================================================#
#  This is an auxiliar one for my scripts that are somehow related with maps.  #
#==============================================================================#
MC_STEPS_TRACKED = 4        #Size of the n last visited positions to be recorded
#==============================================================================#
#==============================================================================#
#                              STOP EDITING HERE                               #
#==============================================================================#
SEPARATOR = "####################"
PBS_SINNOH_PATH = "PBS/sinnohMap.txt"
$LOCATIONS_ARRAY={}
$DESC_ARRAY = {}
$mapDataLoaded = false
$enteredNewMap = true
$currentMapId = -1
$curPortionX  = -1
$curPortionY  = -1
$mcPositions  =[]
#==============================================================================#
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

def pbCheckChangingPortion(mode)
  change = false
  vars = []
  
  if $LOCATIONS_ARRAY[$game_map.map_id]
    if $currentMapId == $game_map.map_id
      $enteredNewMap = false
      case mode
        when "X"
          vars = [$game_player.x,$game_map.width,$curPortionX, 2]
        when "Y"
          vars = [$game_player.y,$game_map.height,$curPortionY,3]
      end
      #checking upper bound:
      if vars[0] - vars[1] * (vars[2]+1) / $LOCATIONS_ARRAY[$game_map.map_id][vars[3]] > 0
        change = true
      #checking lower bound:
      elsif vars[0] - vars[1] * vars[2] / $LOCATIONS_ARRAY[$game_map.map_id][vars[3]] <= 0
        change = true
      end
    else
      $currentMapId = $game_map.map_id
      $enteredNewMap = true
      change = true
    end
  end
  return change
end

def pbCheckChangingPortions; return pbCheckChangingPortion("X") || pbCheckChangingPortion("Y"); end

def pbUpdateCurPos(tileSize=1,scale=1,mapPos=[0,0],relPos=[0,0],offset=[0,0],modify=true)
  if $LOCATIONS_ARRAY[$game_map.map_id]
    
    #checking in which part of the town/route/city is the player
    if $LOCATIONS_ARRAY[$game_map.map_id][2] > 1 || $LOCATIONS_ARRAY[$game_map.map_id][3] > 1
      
      #find x portion
      for i in 0...$LOCATIONS_ARRAY[$game_map.map_id][2]
        if $game_player.x <= ($game_map.width * (i+1) / $LOCATIONS_ARRAY[$game_map.map_id][2])
          $curPortionX = i if modify
          break
        end
      end
      
      #find y portion
      for i in 0...$LOCATIONS_ARRAY[$game_map.map_id][3]
        if $game_player.y <= ($game_map.height * (i+1) / $LOCATIONS_ARRAY[$game_map.map_id][3])
          $curPortionY= i if modify
          break
        end
      end
    else
      $curPortionX = 0
      $curPortionY = 0
    end
  else
    $curPortionX = 0
    $curPortionY = 0  
  end
end

def pbUpdateMapPosTrack
  if $LOCATIONS_ARRAY[$game_map.map_id]
    auxX = $LOCATIONS_ARRAY[$game_map.map_id][0]+$curPortionX
    auxY = $LOCATIONS_ARRAY[$game_map.map_id][1]+$curPortionY
    
    if $mcPositions.length <= 0
      for i in 0...MC_STEPS_TRACKED; $mcPositions[i]=[auxX,auxY]; end
    else
      for i in 0...MC_STEPS_TRACKED-1; $mcPositions[i]=[$mcPositions[i+1][0],$mcPositions[i+1][1]]; end
      $mcPositions[$mcPositions.length-1] = [auxX,auxY]
    end
  end
end

def pbObtainCoord(cmp,tileSize,scale,spritePos,relPos,offset, offset2)
  return scale*(tileSize*(cmp+offset+offset2)+relPos)+spritePos
end

def pbObtainRealPos(cmp,tileSize=1,spritePos=[0,0],relPos=[0,0],scale=1,offset=[0,0])
  newX = pbObtainCoord(cmp[0],tileSize,scale,spritePos[0],relPos[0],offset[0],$curPortionX)
  newY = pbObtainCoord(cmp[1],tileSize,scale,spritePos[1],relPos[1],offset[1],$curPortionY)
  return [newX,newY]
end

Events.onStepTaken += proc do
  pbLoadSinnohMapData
  pbUpdLocData if pbCheckChangingPortions
end

def pbUpdLocData
  pbUpdateCurPos
  pbUpdateMapPosTrack
end

def pbOnLocation?(mapId,pos)
  return $LOCATIONS_ARRAY[mapId] &&
  pos[0] >= $LOCATIONS_ARRAY[mapId][0] &&
  pos[0] <= $LOCATIONS_ARRAY[mapId][0] + $LOCATIONS_ARRAY[mapId][2]-1 &&
  pos[1] >= $LOCATIONS_ARRAY[mapId][1] &&
  pos[1] <= $LOCATIONS_ARRAY[mapId][1] + $LOCATIONS_ARRAY[mapId][3]-1
end

def pbCheckAllOnLocation(pos)
  prevName = ""
  for i in $LOCATIONS_ARRAY.keys
    if prevName = "" != $LOCATIONS_ARRAY[i][4]
      prevName = $LOCATIONS_ARRAY[i][4]
      return i if pbOnLocation?(i,pos)
    end
  end
  
  return -1
end

def pbLoadSinnohMapData
  if !$mapDataLoaded
    curRegionID= !$game_map ? 0 : pbGetMetadata($game_map.map_id,MetadataMapPosition)[0]
    regionSelected = false
    
    ret1 = {}
    ret2 = {}
    begin
      File.open(PBS_SINNOH_PATH) do |file|
        regionId = -1
        line = ""
        while regionId !=curRegionID && !file.eof?
          line = file.readline()
          regionId = line[1,line.length-3].to_i if line.include? "["
        end
        
        line = file.readline()
        while !(line.include? "[") && !file.eof?
          if !(line.include? SEPARATOR)
            line = line.split(',',-1)
            locN = line[0] #name
            locI = line[1] if line.length > 1 #icon
            line = file.readline()
            locCS = line.split(',',-1) #position and size
    
            line = file.readline()
            locM = line.split(',',-1) #map(s) IDs
            ret2[locN] = file.readline() if !file.eof? && !ret2[locN] #&& !(locN.include? "Route") #description
            ret2[locN] = "" if (!ret2[locN] || (ret2[locN].include? SEPARATOR))
            for i in 0...locM.length-1
              width  = i == 0 ? locCS[2].to_i : 1
              height = i == 0 ? locCS[3].to_i : 1
              ret1[locM[i].to_i] = [locCS[0].to_i,locCS[1].to_i,width,height,locN.to_s]
              ret1[locM[i].to_i][5] = locI.to_i if i == 0 && locM.length > 2
            end
          end
          line = file.readline() if !file.eof?
        end
      end
    rescue
      pbThrow(_INTL(
        "Incorrect format in {1}. Please, read the script documentation to learn "+
        "the exact format and if you have any further problem do not hesitate "+
        "in contact the author.",PBS_SINNOH_PATH),
        true
      )
    end
    $LOCATIONS_ARRAY = ret1
    $DESC_ARRAY = ret2
    $mapDataLoaded = true
  end
end