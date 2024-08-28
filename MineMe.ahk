#SingleInstance Force
#Include "lib/MiningStateMachine.ahk"

readyToStart := false
startMining := false
instructions := "1. Open Core Keeper.`n2. Move your character to a position so that in all your directions is some ground. No wall. No hole.`n3. Place a pickaxe with which you have enough mining power to destroy a certain block with one hit on hotkey 9. RECOMMEND: Empty slot`n4. Put this certain block on hotkey 0. RECOMMEND: Sand`n5. Press CTRL + M to get started power up your mining skill. Don't move your ass.`n`nControls:`nPress CTRL + M to stop/start the procedure`nPress CTRL + Q to quit this script"

resultOk := MsgBox("Hey there core keepers`n`nIt's a nice day to go mining, ain't it? Huho.`n`n" . instructions, "Core Keeper - MineMe", 0)
readyToStart := resultOk = "OK"
if !readyToStart
    ExitApp

miningMachine := MiningStateMachine()
Loop {
    if (!startMining) {
        continue
    }

    If !WinExist("Core Keeper") {
        MsgBox("Core Keeper is not open. You need to obey:`n`n" . instructions, "MineMe - Core Keeper not open", "OK")
        startMining := false
        miningMachine.reset()
        continue
    }
    If !WinActive("Core Keeper") {
        yesResult := MsgBox("Core Keeper needs to be your active window.`n`nWait, let me activate it...", "MineMe - Core Keeper not active", "YesNo")
        if (yesResult = "Yes"){
            WinActivate("Core Keeper")
            setMachinesWindowBoundries()
            startMining := true
        } else if (yesResult = "No"){
            startMining := false
        }
        miningMachine.reset()
        continue
    } else if (!miningMachine.areWindowBoundriesSet()){
        setMachinesWindowBoundries()
    }

    miningMachine.handleState()
}

setMachinesWindowBoundries(){
    global miningMachine
    WinGetPos(&WinX, &WinY, &WinW, &WinH)
    miningMachine.setWindowBoundaries(WinW, WinH)
}

$^m::{
    global
    if(readyToStart) {
        startMining := !startMining
        if(startMining){
            miningMachine.reset()
        }
    }
}
$^q::ExitApp