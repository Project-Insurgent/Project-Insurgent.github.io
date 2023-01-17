#==============================================================================#
# * Movement & Animation Script
# By Zexion
# Sections by Dirtie & DerVVulfman
# Helped by KK20
# Version 1.5
#==============================================================================#
# With this script you can enable eight directional movement without the need
# of a custom character graphic. You can modify graphics on a per-file basis
# which allows for tons of custom character files. You can have 8 directional
# characters along side 4 directional characters and use an optional "standing"
# graphic as the first sprite of the charset.
#==============================================================================#
# Directions:
# Place below the default scripts.
# Adjustments take place in the file name. Add tags to a filename to change
# the way it works. You can configure some of those tags here.
#-------------------------
# Default Tags include:
# "iso" - Converts a file into an 8 pose charset. Do not use this & the "vs_#"
# tag in the same file name.
# "stn" - Looks for an additional sprite at the start of the graphic for a
# standing graphic. E.g. If you have 5 walking frames you can use this to ensure
# that the first sprite is a standing sprite and doesn't play in the walking
# animation loop.
#-------------------------
# Other Tags (non-custom) include:
# (Please note that "#" represents a number you must enter)
# "a_#" - Control the speed of an animation. 14 is good for longer animations.
# "vs_#" - The number of poses a file contains. E.g: vs_1 allows only 1 pose.
# "cs_#" - The number of frames a file contains. E.g: cs_4 allows 4 animated frames.
# "h_#" - Horizontal Shift : Allows for a file to be properly centered horizontally without editing.
# "v_#" - Vertical Shift : Allows for a file to be properly centered vertically without editing.
#==============================================================================#
module ANIM_DATA
	SPEED = 14                # Default animation speed
	ISO_TAG = "iso"           # Tag for 8 pose charset.
	EIGHT_DIR = true          # Does not require certain number
							  # of frames, or custom charset.
	STND_TAG = "stn"          # This uses the first pose as
							  # a standing pose. Useful for
							  # larger animation sheets.
end

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
# This section by:
# Dirtie & Zexion
# 16th December 2006
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
class Game_Actor < Game_Battler
	#--------------------------------------------------------------------------
	# * Get Number of Frames for Character Graphic
	#--------------------------------------------------------------------------
	def character_frames
		@character_name.gsub(/cs\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return 4
	end
	#--------------------------------------------------------------------------
	# * Get Number of Rows for Character Graphic (allows for 1 row charsets.
	#--------------------------------------------------------------------------
	def character_rows
		@character_name.gsub(/vs\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return 4
	end
	#--------------------------------------------------------------------------
	# * Control the speed of an animation (is no longer affected by move_speed
	#--------------------------------------------------------------------------
	def animation_speed
		@character_name.gsub(/a\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return ANIM_DATA::SPEED
	end
end

class Sprite_Character < RPG::Sprite
	#--------------------------------------------------------------------------
	# * Get Number of Frames for Character Graphic
	#--------------------------------------------------------------------------
	def character_frames
		@character_name.gsub(/cs\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return 4
	end
	#--------------------------------------------------------------------------
	# * Get Number of Rows for Character Graphic (allows for 1 row charsets.
	#--------------------------------------------------------------------------
	def character_rows
		@character_name.gsub(/vs\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return 4
	end
	#--------------------------------------------------------------------------
	# * Control the speed of an animation (is no longer affected by move_speed
	#--------------------------------------------------------------------------
	def animation_speed
		@character_name.gsub(/a\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return ANIM_DATA::SPEED
	end
end

class Game_Character
	#--------------------------------------------------------------------------
	# * Get Number of Frames for Character Graphic
	#--------------------------------------------------------------------------
	def character_frames
		@character_name.gsub(/cs\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return 4
	end
	#--------------------------------------------------------------------------
	# * Get Number of Rows for Character Graphic (allows for 1 row charsets.
	#--------------------------------------------------------------------------
	def character_rows
		@character_name.gsub(/vs\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return 4
	end
	#--------------------------------------------------------------------------
	# * Control the speed of an animation (is no longer affected by move_speed
	#--------------------------------------------------------------------------
	def animation_speed
		@character_name.gsub(/a\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return ANIM_DATA::SPEED
	end
	#--------------------------------------------------------------------------
	# * Get Vertical Adjustment for Character Graphic
	#--------------------------------------------------------------------------
	def character_adjust_y
		@character_name.gsub(/v\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return 0
	end
	#--------------------------------------------------------------------------
	# * Get Horizontal Adjustment for Character Graphic
	#--------------------------------------------------------------------------
	def character_adjust_x
		@character_name.gsub(/h\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return 0
	end
end

class Window_Base < Window
	#--------------------------------------------------------------------------
	# * Get Vertical Adjustment for Character Graphic
	#--------------------------------------------------------------------------
	def character_adjust_y(actor)
		actor.character_name.gsub(/v\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return 0
	end
	#--------------------------------------------------------------------------
	# * Get Horizontal Adjustment for Character Graphic
	#--------------------------------------------------------------------------
	def character_adjust_x(actor)
		actor.character_name.gsub(/h\_(\d+)/) do
			if $1 != @character_name
				return $1.to_i
			end
		end
		return 0
	end
	#--------------------------------------------------------------------------
	# * Draw Graphic
	#     actor : actor
	#     x     : draw spot x-coordinate
	#     y     : draw spot y-coordinate
	#--------------------------------------------------------------------------
	def draw_actor_graphic(actor, x, y)
		yalign = character_adjust_y(actor)
		xalign = character_adjust_x(actor)
		bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
		cw = bitmap.width / actor.character_frames
		if actor.character_name.include?(ANIM_DATA::ISO_TAG)
			ch = bitmap.height / 8
		else
			ch = bitmap.height / 4
		end
		src_rect = Rect.new(0, ch * 2, cw, ch)
		self.contents.blt(x - cw / 2 + xalign, y - ch + yalign, bitmap, src_rect)
	end
end
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
# End of section by: Dirtie & Zexion
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
# This section by:
# DerVVulfman
# Zexion
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
class Game_Character  
	#--------------------------------------------------------------------------
	# * Public Instance Variables
	#--------------------------------------------------------------------------
	attr_reader   :step_anime               # Holds a sprite's step flag
	attr_reader   :walk_anime               # Holds an event's movement flag
	attr_reader   :stop_count               # The number of steps left to count
	attr_reader   :jump_count               # The number of steps in a jump
	#--------------------------------------------------------------------------
	# * Frame Update
	#--------------------------------------------------------------------------
	def update
		# Branch with jumping, moving, and stopping
		if jumping?
			update_jump
		elsif moving?
			update_move
		else
			update_stop
		end
		if @anime_count > 18 - (self.animation_speed)
			# If stop animation is OFF when stopping
			if not @step_anime and @stop_count > 0
				# Return to original pattern
				@pattern = @original_pattern
				# If stop animation is ON when moving
			else
				# Update pattern
				@pattern = (@pattern + 1) % self.character_frames
			end
			# Clear animation count
			@anime_count = 0
		end
		# If waiting
		if @wait_count > 0
			# Reduce wait count
			@wait_count -= 1
			return
		end
		# If move route is forced
		if @move_route_forcing
			# Custom move
			move_type_custom
			return
		end
		# When waiting for event execution or locked
		if @starting or lock?
			# Not moving by self
			return
		end
		# If stop count exceeds a certain value (computed from move frequency)
		if @stop_count > (40 - @move_frequency * 2) * (6 - @move_frequency)
			# Branch by move type
			case @move_type
			when 1  # Random
			move_type_random
			when 2  # Approach
			move_type_toward_player
			when 3  # Custom
			move_type_custom
			end
		end
	end

	#--------------------------------------------------------------------------
	# * Move Lower Left
	#--------------------------------------------------------------------------
	def move_lower_left
		# If no direction fix
		unless @direction_fix
			turn_down_left
		end
		# When a down to left or a left to down course is passable
		if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 4)) or
			(passable?(@x, @y, 4) and passable?(@x - 1, @y, 2))
			# Update coordinates
			@x -= 1
			@y += 1
			# Increase steps
			increase_steps
		end
	end
	#--------------------------------------------------------------------------
	# * Move Lower Right
	#--------------------------------------------------------------------------
	def move_lower_right
		# If no direction fix
		unless @direction_fix
			turn_down_right
		end
		# When a down to right or a right to down course is passable
		if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 6)) or
			(passable?(@x, @y, 6) and passable?(@x + 1, @y, 2))
			# Update coordinates
			@x += 1
			@y += 1
			# Increase steps
			increase_steps
		end
	end
	#--------------------------------------------------------------------------
	# * Move Upper Left
	#--------------------------------------------------------------------------
	def move_upper_left
		# If no direction fix
		unless @direction_fix
			turn_up_left
		end
		# When an up to left or a left to up course is passable
		if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 4)) or
			(passable?(@x, @y, 4) and passable?(@x - 1, @y, 8))
			# Update coordinates
			@x -= 1
			@y -= 1
			# Increase steps
			increase_steps
		end
	end
	#--------------------------------------------------------------------------
	# * Move Upper Right
	#--------------------------------------------------------------------------
	def move_upper_right
		# If no direction fix
		unless @direction_fix
			turn_up_right
		end
		# When an up to right or a right to up course is passable
		if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 6)) or
			(passable?(@x, @y, 6) and passable?(@x + 1, @y, 8))
			# Update coordinates
			@x += 1
			@y -= 1
			# Increase steps
			increase_steps
		end
	end
	#--------------------------------------------------------------------------
	# * Turn Up Left (Added for diagonal animation)
	#--------------------------------------------------------------------------  
	def turn_up_left
		unless @direction_fix
			if @character_name.include?(ANIM_DATA::ISO_TAG)
				@direction = 7
			else
				# Face left if facing right, and face up if facing down
				@direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
			end      
		end
	end
	#--------------------------------------------------------------------------
	# * Turn Up Right (Added for diagonal animation)
	#--------------------------------------------------------------------------  
	def turn_up_right
		unless @direction_fix
				if @character_name.include?(ANIM_DATA::ISO_TAG)
				@direction = 9
			else
				# Face right if facing left, and face up if facing down
				@direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Turn Down Left (Added for diagonal animation)
	#--------------------------------------------------------------------------  
	def turn_down_left
		unless @direction_fix
			if @character_name.include?(ANIM_DATA::ISO_TAG)
				# Face down-left
				@direction = 1
			else
				# Face down is facing right or up
				@direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)       
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Turn Down Right (Added for diagonal animation)
	#--------------------------------------------------------------------------  
	def turn_down_right
		unless @direction_fix
			if @character_name.include?(ANIM_DATA::ISO_TAG)
				@direction = 3
			else
				# Face right if facing left, and face down if facing up
				@direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
			end
		end
	end

	#------------------------------------------------------------------------
	# * Move Random
	#------------------------------------------------------------------------
	def move_random
		case rand(8)
			when 0 ; move_down(false)
			when 1 ; move_left(false)
			when 2 ; move_right(false)
			when 3 ; move_up(false)
			when 4 ; move_lower_left
			when 5 ; move_lower_right
			when 6 ; move_upper_left
			when 7 ; move_upper_right  
		end
	end
	#------------------------------------------------------------------------
	# * Move Toward Player
	#------------------------------------------------------------------------
	def move_toward_player
		sx = @x - $game_player.x
		sy = @y - $game_player.y
		return if sx == 0 and sy == 0
		abs_sx = sx.abs
		abs_sy = sy.abs
		if abs_sx == abs_sy
			rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
		end
		if abs_sx
			move_upper_right  if sx < 0 and sy > 0
			move_upper_left   if sx > 0 and sy > 0
			move_lower_left   if sx > 0 and sy < 0
			move_lower_right  if sx < 0 and sy < 0
			move_right        if sx < 0 
			move_left         if sx > 0 
			move_up           if sy > 0 
			move_down         if sy < 0 
		end
	end

	#------------------------------------------------------------------------
	# * Move Away from Player
	#------------------------------------------------------------------------
	def move_away_from_player
		sx = @x - $game_player.x
		sy = @y - $game_player.y
		return if sx == 0 and sy == 0
		abs_sx = sx.abs
		abs_sy = sy.abs
		if abs_sx == abs_sy
			rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
		end
		if abs_sx
			move_lower_left   if sx < 0 and sy > 0
			move_lower_right  if sx > 0 and sy > 0
			move_upper_right  if sx > 0 and sy < 0
			move_upper_left   if sx < 0 and sy < 0
			move_left         if sx < 0 
			move_right        if sx > 0 
			move_down         if sy > 0    
			move_up           if sy < 0 
		end
	end

	#--------------------------------------------------------------------------
	# * Set Custom Animation
	#--------------------------------------------------------------------------
	def set_custom_anim
		return if @animating
		@frame_count    = self.character_frames
		@animating      = true
		@anim_wait      = 40
		@pattern        = 0
		@direction_fix  = true
	end  
end

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display the character.It observes the Game_Character
#  class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Character < RPG::Sprite
	#--------------------------------------------------------------------------
	# * Public Instance Variables
	#--------------------------------------------------------------------------
	attr_accessor :character                # character
	attr_accessor :pattern
	#--------------------------------------------------------------------------
	# * Object Initialization
	#     viewport  : viewport
	#     character : character (Game_Character)
	#--------------------------------------------------------------------------
	def initialize(viewport, character = nil)
		super(viewport)
		@character = character
		update
	end
	#--------------------------------------------------------------------------
	# * Frame Update
	#--------------------------------------------------------------------------
	def update
		super
		# If tile ID, file name, or hue are different from current ones
		if @tile_id != @character.tile_id or
			@character_name != @character.character_name or
			@character_hue != @character.character_hue
			# Remember tile ID, file name, and hue
			@tile_id = @character.tile_id
			@character_name = @character.character_name
			@character_hue = @character.character_hue
			# If tile ID value is valid
			if @tile_id >= 384
				self.bitmap = RPG::Cache.tile($game_map.tileset_name,
				@tile_id, @character.character_hue)
				self.src_rect.set(0, 0, 32, 32)
				self.ox = 16
				self.oy = 32
				# If tile ID value is invalid
			else
				self.bitmap = RPG::Cache.character(@character.character_name,
				@character.character_hue)
				if @character.character_name.include?(ANIM_DATA::STND_TAG)
					@cw = bitmap.width / (self.character_frames + 1)
				else
					@cw = bitmap.width / self.character_frames
				end
				if @character.character_name.include?(ANIM_DATA::ISO_TAG)
					@ch = bitmap.height / 8
				else
					@ch = bitmap.height / self.character_rows
				end
				if @character.character_adjust_x != nil 
					self.ox = (@cw - @character.character_adjust_x) / 2
				else
					self.ox = @cw / 2
				end
				if @character.character_adjust_y != nil 
					self.oy = @ch - @character.character_adjust_y
				else
					self.oy = @ch
				end
			end
		end
		# Set visible situation
		self.visible = (not @character.transparent)
		# If graphic is character
		if @tile_id == 0
			if not @character.step_anime and @character.stop_count > 0
				sx = (@character.pattern) * @cw
			else      
				# If event's Movement flag is checked (or player sprite)
				if @character.walk_anime                  
					# Set rectangular transfer
					if @character.character_name.include?(ANIM_DATA::STND_TAG)
						sx = (@character.pattern + 1) * @cw
					else
						sx = @character.pattern * @cw
					end
				else
					sx = @character.pattern * @cw
				end
			end
			# Basic direction value
			dir = @character.direction
			# If a custom character in use
			if @character.character_name.include?(ANIM_DATA::ISO_TAG)
				dec = (dir == 7 or dir== 9) ? 3 : 1   # directional movement.
				sy = (dir - dec) * @ch     
			else
				sy = (dir - 2) / 2 * @ch        
			end
			# Typical block transfer
			self.src_rect.set(sx, sy, @cw, @ch)
		end
		# Set sprite coordinates
		self.x = @character.screen_x
		self.y = @character.screen_y
		self.z = @character.screen_z(@ch)
		# Set opacity level, blend method, and bush depth
		self.opacity = @character.opacity
		self.blend_type = @character.blend_type
		self.bush_depth = @character.bush_depth
		# Animation
		if @character.animation_id != 0
			animation = $data_animations[@character.animation_id]
			animation(animation, true)
			@character.animation_id = 0
		end
	end
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player. Its functions include event starting
#  determinants and map scrolling. Refer to "$game_player" for the one
#  instance of this class.
#==============================================================================

class Game_Player < Game_Character
	@@poin1 = 0    
	@@poin2 = 0
	@@wait_time = 0
	#--------------------------------------------------------------------------
	# * Public Instance Variables
	#--------------------------------------------------------------------------
	attr_accessor :waiting
	attr_accessor :wait_time
	#------------------------------------------------------------------------
	# * Update Character Movement
	#------------------------------------------------------------------------
	def update
		last_moving = moving?
		#----------------------------------------------------------------------
		#  * Movement Handling
		#----------------------------------------------------------------------
		unless moving? or $game_system.map_interpreter.running? or
			@move_route_forcing or $game_temp.message_window_showing  
			if ANIM_DATA::EIGHT_DIR == true
				case Input.dir8
					when 1 ; move_lower_left
					when 3 ; move_lower_right
					when 7 ; move_upper_left
					when 9 ; move_upper_right
					when 2 ; move_down
					when 4 ; move_left
					when 6 ; move_right
					when 8 ; move_up
					end
					else      
					case Input.dir4
					when 2 ; move_down
					when 4 ; move_left
					when 6 ; move_right
					when 8 ; move_up
				end
			end
		end
		#----------------------------------------------------------------------
		#  * Screen Positioning
		#----------------------------------------------------------------------
		last_real_x = @real_x
		last_real_y = @real_y
		super
		if @real_y > last_real_y and @real_y - $game_map.display_y > CENTER_Y
			$game_map.scroll_down(@real_y - last_real_y)
		end
		if @real_x < last_real_x and @real_x - $game_map.display_x < CENTER_X
			$game_map.scroll_left(last_real_x - @real_x)
		end
		if @real_x > last_real_x and @real_x - $game_map.display_x > CENTER_X
			$game_map.scroll_right(@real_x - last_real_x)
		end
		if @real_y < last_real_y and @real_y - $game_map.display_y < CENTER_Y
			$game_map.scroll_up(last_real_y - @real_y)
		end
		#----------------------------------------------------------------------
		#  * Encounter and Event Processing
		#----------------------------------------------------------------------
		unless moving?
			if last_moving
				result = check_event_trigger_here([1,2])
				if result == false
					unless $DEBUG and Input.press?(Input::CTRL)
						@encounter_count -= 1 if @encounter_count > 0
					end
				end
			end
			if Input.trigger?(Input::C)
				check_event_trigger_here([0])
				check_event_trigger_there([0,1,2])
			end
		end
	end
	#------------------------------------------------------------------------
	#  * Encounter and Event Processing
	#------------------------------------------------------------------------  
	def idle_wait(duration, value)
		for i in 0...duration
			@@wait_time += 1 if value == false
			break if i >= duration / 2
		end
	end
end