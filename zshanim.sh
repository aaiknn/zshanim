#! /bin/zsh

if [[ $1 = "--debug" ]]; then
  DEBUG=1;
fi

tSize=`stty size`
if [[ "$?" > "0" ]]; then
  cols=40
  lines=16
else
  cols=${tSize#* }
  lines=${tSize% *}
fi

hPad="  "
vRepeat=$(( cols/4-1 ))

sky01="$hPad`printf '-   %.0s' {1..$vRepeat}`
$hPad`printf '   -%.0s' {1..$vRepeat}`
$hPad`printf '-   %.0s' {1..$vRepeat}`
$hPad`printf '   -%.0s' {1..$vRepeat}`
$hPad`printf '-   %.0s' {1..$vRepeat}`
$hPad`printf '   -%.0s' {1..$vRepeat}`"

sky02="$hPad`printf ' -  %.0s' {1..$vRepeat}`
$hPad`printf '  - %.0s' {1..$vRepeat}`
$hPad`printf ' -  %.0s' {1..$vRepeat}`
$hPad`printf '  - %.0s' {1..$vRepeat}`
$hPad`printf ' -  %.0s' {1..$vRepeat}`
$hPad`printf '  - %.0s' {1..$vRepeat}`"

sky03="$hPad`printf '  - %.0s' {1..$vRepeat}`
$hPad`printf ' -  %.0s' {1..$vRepeat}`
$hPad`printf '  - %.0s' {1..$vRepeat}`
$hPad`printf ' -  %.0s' {1..$vRepeat}`
$hPad`printf '  - %.0s' {1..$vRepeat}`
$hPad`printf ' -  %.0s' {1..$vRepeat}`"

sky04="$hPad`printf '   -%.0s' {1..$vRepeat}` 
$hPad`printf '-   %.0s' {1..$vRepeat}`
$hPad`printf '   -%.0s' {1..$vRepeat}`
$hPad`printf '-   %.0s' {1..$vRepeat}`
$hPad`printf '   -%.0s' {1..$vRepeat}`
$hPad`printf '-   %.0s' {1..$vRepeat}`"

ground="\n$hPad`printf '____%.0s' {1..$vRepeat}`\n"
nothing="$hPad`printf '    %.0s' {1..$vRepeat}`\n"
head="$hPad`printf '(0/>' ``printf '    %.0s' {1..$((vRepeat-1))}`\n"
body="$hPad`printf '(V| ' ``printf '    %.0s' {1..$((vRepeat-1))}`\n"
feet="$hPad`printf 'UU  ' ``printf '    %.0s' {1..$((vRepeat-1))}`\n"
street=$ground$nothing$nothing$nothing$nothing$nothing$ground
filledSt=$ground$nothing$head$body$feet$nothing$ground
vPad=$nothing

passiveFrames=(
  $vPad$sky01$street
  $vPad$sky02$street
  $vPad$sky03$street
  $vPad$sky04$street
)

activeFrames=(
  $vPad$sky01$filledSt
  $vPad$sky02$filledSt
  $vPad$sky03$filledSt
  $vPad$sky04$filledSt
)

gamePaused=0
gameOver=0
playerSpawned=0
gameRunning=0
userInputDump=""

function paintFrames() {
  for frame in ${passiveFrames[@]}; do
    clear
    echo $frame
    if [[ $DEBUG = "1" ]]; then
      echo "  | Game paused: $gamePaused | Game over: $gameOver | Player spawned: $playerSpawned | Game running: $gameRunning |"
      echo "  | User input dump: $userInputDump |"
    fi
    while read -t 1 userInput; do
      if [[ $userInput = "" ]]; then
        unset userInputDump
      else
        userInputDump="$userInputDump$userInput"
      fi
      handleUserInput "$userInputDump"
    done
  done
}

function handlePlayerCtrl() {
  if [[ $gameRunning = "0" ]]; then
    gameRunning=1
  fi
  if [[ $playerSpawned = "0" ]]; then
    echo "PLAYERCTRL"
    spawnPlayer
    # populate play frames
  fi
}

function handleUserInput() {
  case $1 in
    q | exit );
      gameOver=1
      break
      exit
      ;;
    d );
      if [[ $gamePaused = "1" ]]; then
        unpauseGame
      elif [[ $gameRunning = "0" ]]; then
        handlePlayerCtrl
      else
        main
      fi
      ;;
    p );
      if [[ $gamePaused = "0" ]]; then
        gamePaused=1
        break
      elif [[ $gamePaused = "1" ]]; then
        unpauseGame
      fi
      ;;
    * );
      unset userInputDump
  esac
}

function pausedGame() {
  echo "PAUSED"
  read userInput
  handleUserInput "$userInput"
}

function unpauseGame() {
  gamePaused=0
  echo "UNPAUSED"
  # unpause rather instead of fresh main
  main
}

function gameOvered() {
  echo "GAME OVER"
  echo "Start new game? [y|n]"
  read userInput
  if [[ $userInput = "y" ]] || [[ $userInput = "yes" ]]; then
    gamePaused=0
    gameOver=0
    gameRunning=0
    unset userInputDump
    unspawnPlayer
    main
  else
    exit
  fi
}

function spawnPlayer() {
  playerSpawned=1
  paintFrames
}

function unspawnPlayer() {
  playerSpawned=0
  paintFrames
}

function main() {
  while [[ $gameOver = "0" ]] && [[ $gamePaused = "0" ]]; do
      paintFrames
  done
  while [[ $gamePaused = "1" ]]; do
      pausedGame
  done
  while [[ $gameOver = "1" ]]; do
      gameOvered
  done
}

main
exit