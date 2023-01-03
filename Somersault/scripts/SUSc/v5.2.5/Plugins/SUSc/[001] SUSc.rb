#==============================================================================#
#                      SOMERSAULT'S UTILITIES SCRIPT v5.2.5                    #
#                              Give credit if used                             #
#==============================================================================#
# Several small functions to handle my other scripts and/or to use as standalone
#==============================================================================#
module SUSC
	# turn on only if you have installed KleinStudio's Xtransceiver script.
	XTRANSCEIVERADDED = false
  
	#Whether to use map utilities features or not:
	ACTIVATE_MAP_UTILITIES = false
	
	# folder inside which to place all my scripts graphics
	SUSC_PATH = "Graphics/Somerscripts/"
  
	# Whether to display panels as a multiple-screen system or not.
	# true  -> panels will be displayed as defined below;
	# false -> all my other scripts will run in "single-panel" mode
	MULTI_SCREEN = false 
  
	# settings of the different frames or "screens" to be added
	SCR_SETTINGS = {
	 #:PANEL_NAME => [  x,  y,  w,  h],
	  :MAIN_PANEL => [  0,  0,512,384], # main panel (you can modify this one, but DO NOT delete it)
	  :SECN_PANEL => [512,192,256,192], # scnd panel (you can modify this one, but DO NOT delete it)
	 #you can freely modify/add/delete from this point on:
	  :AUXI_PANEL => [512,  0,256,192]  # aux panel (used by my scripts just to fill space with black when in multiple screen system)
	}
  
	# Whether the intro of the game should pop up or not during debug mode.
	# Look for "def pbCallTitle" and add "&& !SUSC::DEBUG_INTRO" at the end of the
	# line "return Scene_DebugIntro.new if $DEBUG" to use this feature
	DEBUG_INTRO = false
  #==============================================================================#
	#Whether to use custom suggested names or not when aborting the name selection
	USE_CUSTOM_SUG_NAME = true
	
	MALE_CHAR = "Rogue"
	FEM_CHAR  = "Rebel"
  # Stop editing here ===========================================================#
  #==============================================================================#
  #                              SET CHARACTER NAME                              #
  #==============================================================================#
  #     Simple function to name a character depending on the player's gender     #
  #==============================================================================#
  #Usage: pbSetCharName(male_name,female_name, variable_to_store_the_name_in)
  #Suggestion: Use it in the intro event after setting the player's gender so that
  #each time you want to access the name in a text you can simply do \v[var_value] 
  #==============================================================================#
	def self.pbSetCharName(name_m,name_f,var)
	  pbSet(var,name_m) if $Trainer.female?
	  pbSet(var,name_f) if $Trainer.male?
	end
  #==============================================================================#
  #==============================================================================#
  #                                  DIGIT FORMAT                                #
  #==============================================================================#
  #A simple function to change the number of digits (and zeroes at the left) that
  #a variable has. Call pbChDigitsAmount(NUMBER, NUMBER_OF_DIGITS)
  #==============================================================================#
	def self.pbChDigitsAmount(num, n = 5)
	  stringNum = num.to_s
	  digitFiller = n - stringNum.length
	  digitFiller = 0 if digitFiller < 0
	  zeroes = "0" * digitFiller
	  return zeroes + stringNum
	end
  #==============================================================================#
  #==============================================================================#
  #                              DISPLAY NUMBER LCD                              #
  #==============================================================================#
  #A simple function to represent a number with graphics.
  #==============================================================================#
	def self.pbDisplayNumberLCD(number, digits, numWidth, numHeight)
	  daSteps = SUSC.pbChDigitsAmount(number).to_s.split("")
	
	  for i in 0...digits.length()
		digits[digits.length()-1-i].set_src_rect(
		  daSteps[i].to_i*numWidth,0,numWidth,numHeight)
	  end
	end
  #==============================================================================#
  #==============================================================================#
  #                         U.A.R.M. functions for sprites!                      #
  #==============================================================================#
  # Methods to apply basic Physics to sprites!
  # Note: gravitation force is much weaker in the sprite world
  # Note: Notice that since y axis grows downwards, gravity is now positive.
  #==============================================================================#
	#calculate next uarm position:
	def self.pbNext_mrua_Pos(sprite,speed=[0,0],timePassed=1,g=1)
	  sprite.x = (sprite.x.to_f + speed[0]*timePassed).to_i
	  sprite.y = (sprite.y.to_f - speed[1]*timePassed + (g*(timePassed**2))/2).to_i
	  sy = speed[1] - g*timePassed
	  return [speed[0],sy]
	end
  
	#calculate next n uarm positions:
	def self.pbMrua(sprite,speed=[0,0],frames=1,deltaTime=1,g=1)
	  _speed = speed
	  frames.times do
		_speed = pbNext_mrua_Pos(sprite,_speed,deltaTime,g)
		Graphics.update
	  end
	end
  #==============================================================================#
  #==============================================================================#
  #                          U.R.M. functions for sprites!                       #
  #==============================================================================#
  # Methods to apply basic Physics to sprites!
  # Note: Notice that since y axis grows downwards, gravity is now positive.
  #==============================================================================#
	#calculate next urm position:
	def self.pbNext_mru_Pos(sprite,speed=[0,0],deltaTime=1)
	  sprite.x = (sprite.x + speed[0]*deltaTime).to_i
	  sprite.y = (sprite.y + speed[1]*deltaTime).to_i
	end
  
	#calculate next n urm positions:
	def self.pbMru(sprite,speed=[0,0],frames=1,deltaTime=1)
	  frames.times do
		pbNext_mru_Pos(sprite,speed,deltaTime)
		Graphics.update
	  end
	end
  
  #==============================================================================#
  #==============================================================================#
  #                               BUTTON ANIMATION                               #
  #==============================================================================#
  # An easy function to handle pressed button animations.
  # Call pbFrameAnimation(sprite,frames,delay) where
  #    -sprite is the sprite to play the animation
  #    -frames is the number of frames the graphic has
  #    -se is the sound to be played, optional.
  #    -row is the actual row of the sprite to which apply the animation (in case there
  #       is more than one sequence in it); optional, too
  #==============================================================================#
	def self.pbFrameAnimation(sprite,frames,se="",row=0)
	  w = sprite.width 
	  h = sprite.height
  
	  pbSEPlay(se)
	  for i in 1..frames
		sprite.src_rect.set((i%frames)*w,row*h,w,h)
		Graphics.update
	  end
	end
  #==============================================================================#
  #==============================================================================#
  #                              AMBIENT SOUND                                   #
  #==============================================================================#
  # A function to add ambient sounds!
  # 0. Create an event with parallel trigger at the source point
  # 1. Call the script pbAmbSound(SOUNDFILE,EVENT_ID,MAX_VOLUME,SCOPE_RADIUS)
  #
  # NOTE:
  #   -The files will be placed at SE folder.
  #   -If at some point the radius is bigger than the distance to the map border,
  #    then the SE will still be noticeable when the player goes out of the map.
  #   -Only one ambient sound per map (for the moment)
  #
  # example: pbAmbSound("Crowd.mp3",24,80,15)
  # =>The file "Crowd.mp3" will be played and you will start hearing at a distance
  # of 15 tiles. The volume will be at 80 when you are on the source point. The
  # event id that calls the script is 24.
  #==============================================================================#
	def self.pbAmbSound(soundFile,eventId,maxVolume,radius)
	  radius = radius.to_f
	  distance = 0.0
	  _maxVolume = maxVolume.to_f
	  
	  if $game_map.events[eventId]
		if ($game_player.x - $game_map.events[eventId].x).abs >= ($game_player.y - $game_map.events[eventId].y).abs
		  distance = ($game_player.x - $game_map.events[eventId].x).abs
		else; distance = ($game_player.y - $game_map.events[eventId].y).abs; end
		distance = 1 if distance == 0
		
		volume = distance >= radius ? 0 : (_maxVolume - (distance * _maxVolume.to_f/radius)).to_i + 30
		volume = _maxVolume if volume > maxVolume + 30
  
		pbBGSPlay(soundFile,volume,100)
	  end
	end
  #==============================================================================#
  #==============================================================================#
  #                           LINEAR AMBIENT SOUNDS                              #
  #==============================================================================#
  # A function to add ambient sounds for bigger objects, like for example a coast.
  # 0. Create an event with parallel trigger at the source point and Call the
  # script: pbLAmbSound(SOUNDFILE,EVENT_ID,MAX_VOLUME,RANGE,MODE,LEFT/RIGHT)
  # where MODE is true or false, being true horizontal and false vertical. You can
  # also ommit this if want a vertical ambient; LEFT/RIGHT accepts true or false,
  # and that will be the side of the sound sourece where the sounfile won't be
  # played lower as you get away in that direction (false for left or up, true for
  # right or down). Again, this is for sounds like the sea waves,
  # for example.
  #
  # NOTE:
  #   -The files will be placed at SE folder.
  #   -If at some point the radius is bigger than the distance to the map border,
  #    then the SE will still be noticeable when the player goes out of the map.
  #   -Only one ambient sound per map (for the moment)
  #
  # example: pbLAmbSound("Waves.mp3",24,80,15)
  # =>The file "Waves.mp3" will be played and you will start hearing at a distance
  # of 15 tiles. The volume will be at 80 when you are on the source point. The
  # event id that calls the script is 24. It will be in vertical and the volume will
  # be lowered when you walk westwards.
  #==============================================================================#
	def self.pbLAmbSound(soundFile,eventId,maxVolume,range,mode=false,side=false)
	  if @map_id==$game_map.map_id
		daRange = range.to_f
		daDistance = 0.0
		daMaxVolume = maxVolume.to_f
		
		if mode
		  daPlayerPos = $game_player.y
		  daEventPos = $game_map.events[eventId].y
		else
		  daPlayerPos = $game_player.x
		  daEventPos = $game_map.events[eventId].x
		end
		
		if $game_map.events[eventId]
		  daDistance += (daPlayerPos - daEventPos)
		  daDistance = 1 if daDistance == 0
		  
		  if (mode && daDistance < 0) || (!mode && daDistance >= 0)
			daDistance = daDistance.abs
			if daDistance >= daRange
			  volume = 0
			else
			  volume =(daMaxVolume - (daDistance * daMaxVolume.to_f/range)).to_i + 30
			end
		  else
			volume = daMaxVolume + 30
		  end
		  
		  volume = daMaxVolume + 30 if volume > daMaxVolume + 30
	  
		  pbBGSPlay(soundFile,volume,100)
		end
	  end
	end
  #==============================================================================#
  #==============================================================================#
  #                              PLAY BGM WITH INTRO                             #
  #==============================================================================#
  # A function to play bgm with an intro that will be played only once:          #
  # 0. Call the intro file the same as the main audio file you want to play, but #
  #   add "_intro" at the end of it.                                             #
  # 1. Place the intro file in ME and the main audio file in BGM.                #
  # Call pbPlayBGM_withIntro(YOURFILE,VOLUME,PITCH) where:                       #
  #   -YOURFILE is the name of your file (without "_intro")                      #
  #   -VOLUME is, the volume you want to play it at (you can omit this param)    #
  #   -PTICH is the pitch you want to play it at (you can also omit this param)  #
  #                                                                              #
  # example: pbPlayBGM_withIntro("Caught.mp3")                                   #
  # =>The file "Caught.mp3" will be played and you will start hearing at the     #
  # standard volume and pitch                                                    #
  #==============================================================================#
	def self.pbPlayBGM_withIntro(audioFile=nil,volume=100,pitch=100)
	  pbMEPlay(audioFile + "_Intro",volume,pitch)
	  pbBGMPlay(audioFile,volume,pitch)
	end
  #==============================================================================#
  #                      Small function to add items anywhere                    #
  #==============================================================================#
  #for adding one or more items without noticing to the player at all.
	def self.pbAddItem(item,amount=1); amount.times do; $PokemonBag.pbStoreItem(item); end;end
  #==============================================================================#
  #              Small function to raise a custom exception message              #
  #==============================================================================#
	def self.pbThrow(msg="",closeGame=true)
	  p msg
	  Kernel.exit! if closeGame
	end
  #==============================================================================#
  #==============================================================================#
  #                          SET CUSTOM SUGGESTION NAMES                         #
  #==============================================================================#
  #Simple function to make a custom suggestion when choosing a name for the player
  # Note: You shouldn't need to explicitly call this
  #==============================================================================#
	alias pbSuggestTrainerNameOld pbSuggestTrainerName
	def pbSuggestTrainerName(gender)
	  if SUSC::USE_CUSTOM_SUG_NAME
		return SUSC::FEM_CHAR  if gender == 1
		return SUSC::MALE_CHAR if gender == 0
	  else
		return pbSuggestTrainerNameOld
	  end
	end
  
	def self.pbChoicesWithVp(msgwindow=nil,commands=nil,vp = nil,cmdIfCancel=0,defaultCmd=0)
	  w = vp ? vp.rect.width  : Graphics.width
	  h = vp ? vp.rect.height : Graphics.height
	  cmdwindow = Window_CommandPokemon.new(commands)
	  cmdwindow.viewport = vp
	  cmdwindow.x = w - cmdwindow.width
	  cmdwindow.y = h - cmdwindow.height
	  cmdwindow.y -= msgwindow.height if msgwindow
	  cmdwindow.z = vp ? vp.z+1 : 99999
	  cmdwindow.index=defaultCmd
  
	  ret = 0
	  loop do
		Graphics.update
		Input.update
		cmdwindow.update
		msgwindow.update if msgwindow
		yield if block_given?
		if Input.trigger?(Input::BACK)
		  if cmdIfCancel>0
			ret=cmdIfCancel-1
			break
		  elsif cmdIfCancel<0
			ret=cmdIfCancel
			break
		  end
		end
		if Input.trigger?(Input::USE)
		  ret=cmdwindow.index
		  break
		end
		pbUpdateSceneMap
	  end
	  cmdwindow.dispose
	  Input.update
	  return ret
	end
  end
  #function borrowed from Marin's Utilities script and adapted
  module Input
	# Returns true if any of the buttons below are pressed
	def self.any?#Input::
	  #return true if defined?(Game_Mouse) && $mouse && ($mouse.leftClick? || $mouse.rightClick?)
	  keys = [USE,BACK,ACTION,JUMPUP,JUMPDOWN,SPECIAL,AUX1,AUX2,LEFT,RIGHT,UP,DOWN,
  
	  # 0-9, a-z
	  0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x41,0x42,0x43,0x44,
	  0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x50,0x51,0x52,0x53,
	  0x54,0x55,0x56,0x57,0x58,0x59,0x5A]
	  for key in keys; return true if Input.triggerex?(key); end
	  return false
	end
  end