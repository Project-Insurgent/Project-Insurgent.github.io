#==============================================================================#
#                          CATCHING TUTORIAL SCRIPT v1.2                       #
#                                (by A.Somersault)                             #
#==============================================================================#
#A script to invoque a catching tutorial in which you will be actually able to #
#control the professor! (or the corresponding character teaching you to catch) #
#==============================================================================#
#Note: the script returns true only if the player catches the pokémon, in order
#to allow the corresponding event to branch correctly. But it still allows the
#player to defeat the pokémon, so take this into account.
#==============================================================================#
#Usage: pbCatchingTutorial
#return type: boolean -> returns true if the pokémon has been caught.
#                     -> returns false if the wild pokémon has been defeated.
#                     -> returns false if the user pokémon has been defeated.
#==============================================================================#
#Bugfix 1.2 (19/5/21): Party now won't ignore the trainer after the tutorial.
#==============================================================================#
TUTORIAL_SPECIES = :SNOVER        #wild pokémon species
TUTORIAL_LEVEL = 10               #wild pokémon level

TUTORIAL_ALLY_SPECIES = :ROTOM    #user pokémon species
TUTORIAL_ALLY_LEVEL = 15          #user pokémon level

ALLY_MOVES = [                    #moves of the user's pokémon
  :THUNDERSHOCK,
  :DOUBLETEAM,
  :THUNDERWAVE
]

GENDER_DEPENDING_TEACHER = true    #whether you want the teacher's gender to depend on player's
                                   #(will use female version if set to false)
MALE_TEACHER_NAME = "Lucas"
FEMALE_TEACHER_NAME = "Dawn"

NEW_POKEBALL_ID = 527             #id of the new pokéball
NUM_POKEBALLS_ON_POCKET = 20      #number of pokéballs in the user's pocket
#==============================================================================#
BallHandlers::IsUnconditional.add(:POKEBALL_M,proc{|ball,battle,battler| next true})
#==============================================================================#
class PokemonBag; attr_accessor :pockets; end
def pbCatchingTutorial
  counter = 0
  trainerId = $Trainer.id
  $CatchingTutorial = true
  $otherparty=$Trainer.party
  pok=PokeBattle_Pokemon.new(TUTORIAL_ALLY_SPECIES,TUTORIAL_ALLY_LEVEL,$Trainer)
  bag = $PokemonBag.pockets if $PokemonBag
  
  trname = $Trainer.name
  if GENDER_DEPENDING_TEACHER
    male = $Trainer.isMale?
    if male
       pbTrainerName(FEMALE_TEACHER_NAME)
       pbChangePlayer(2)
    else
       pbTrainerName(MALE_TEACHER_NAME)
       pbChangePlayer(3)
    end
  else
    male = $Trainer.isMale?
    pbTrainerName(FEMALE_TEACHER_NAME)
    pbChangePlayer(2)
  end
   
  $Trainer.party=[pok]
  3.times do
    pok.pbDeleteMoveAtIndex(0)
  end
  
  for i in 0...ALLY_MOVES.length
    pok.moves[i]=PBMove.new(getID(PBMoves,ALLY_MOVES[i]))
  end
  
  pbAddItem(NEW_POKEBALL_ID,NUM_POKEBALLS_ON_POCKET)
  pbWildBattle(TUTORIAL_SPECIES,TUTORIAL_LEVEL,1,false,true)
  ret = ($game_variables[1] == 4)
  
  if male
    pbChangePlayer(0)
  else
    pbChangePlayer(1)
  end
   
  pbTrainerName(trname) 
  $Trainer.party=$otherparty
  $Trainer.id     = trainerId
  $PokemonBag.pbDeleteItem(NEW_POKEBALL_ID,NUM_POKEBALLS_ON_POCKET)
  $PokemonBag.pockets = bag
  $CatchingTutorial = false
  $Trainer.pokedex=true
  return ret
end
#==============================================================================#