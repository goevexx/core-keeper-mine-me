#Requires AutoHotkey v2.0

; The Machine managing the mining state
class MiningStateMachine {
    __New(resetThreshhold := 20000) {
        this.resetThreshhold := resetThreshhold

        this.coreKeeperWindowWidth := 1920
        this.coreKeeperWindowHeight := 1080
        this.initState()
    }

    initState(){
        this.directionStepper := DirectionStepper()
        SendMode("Event")
        SetKeyDelay(, 25)
        this.setState(IdleState(this))
    }

    setState(state) {
        if(HasProp(this, "currentState")){
            previoustateName := this.currentState.__Class
        } else {
            previoustateName := "(no state)"
        }
        this.currentState := state
    }

    handleState(){
        this.currentState.handle()
    }

    reset() {
        this.initState()
    }

    setWindowBoundaries(windowWidth, windowHeight){
        this.windowWidth := windowWidth
        this.windowHeight := windowHeight

        this.miningClickRightX := windowWidth * 0.55
        this.miningClickRightY := windowHeight * 0.5

        this.miningClickLeftX := windowWidth * 0.45
        this.miningClickLeftY := windowHeight * 0.5

        this.miningClickTopX := windowWidth / 2
        this.miningClickTopY := windowHeight * 0.45

        this.miningClickBottomX := windowWidth / 2
        this.miningClickBottomY := windowHeight * 0.55
    }

    areWindowBoundriesSet(){
        return HasProp(this, "windowWidth") and HasProp(this, "windowHeight") and HasProp(this, "miningClickRightX") and HasProp(this, "miningClickRightY") and HasProp(this, "miningClickLeftX") and HasProp(this, "miningClickLeftY") and HasProp(this, "miningClickTopX") and HasProp(this, "miningClickTopY") and HasProp(this, "miningClickBottomX") and HasProp(this, "miningClickBottomY")
    }

    miningCoordX[direction] {
        get {
            Switch (direction) {
                Case "right":
                    return this.miningClickRightX
                Case "left":
                    return this.miningClickLeftX
                Case "top":
                    return this.miningClickTopX
                Case "bottom":
                    return this.miningClickBottomX
            }
        }
    }

    miningCoordY[direction] {
        get {
            Switch (direction) {
                Case "right":
                    return this.miningClickRightY
                Case "left":
                    return this.miningClickLeftY
                Case "top":
                    return this.miningClickTopY
                Case "bottom":
                    return this.miningClickBottomY
            }
        }
    }
}

; The way your current state looks like while you are mining
class MiningStateMachineState {
    __New(context) {
        this.context := context
        this.startTime := A_TickCount
    }

    ; Sets the context's state
    changeState(state){
        if(this.isLastDirection){
            sleep(100)
            this.directionStepper.next()
            this.context.setState(state)
        } else {
            this.directionStepper.next()
        }
    }

    ; Needs to be implemented in subclasses
    handle(){
    }

    hit(){
        this.jiggleMouse()
        Click(this.miningClickX, this.miningClickY)
    }

    jiggleMouse(){
        for(x in [1,3,6]){
            jiggle := Sin(x) * 0.01
            MouseMove(this.miningClickX * (1-jiggle), this.miningClickY * (1-jiggle))
        }
    }

    place(){
        this.jiggleMouse()
        Click(this.miningClickX, this.miningClickY, "Right")
        sleep(30)
    }
    
    select(shortcutNumber){
        SendInput(shortcutNumber)
        sleep(50)
    }

    miningClickX => this.context.miningCoordX[this.direction]
    miningClickY => this.context.miningCoordY[this.direction]
    directionStepper => this.context.directionStepper
    direction => this.directionStepper.value
    isLastDirection => this.directionStepper.isLast()
    isFirstDirection => this.directionStepper.isFirst()
}


; State implementations

; Standing next to the ground on all directions
class IdleState extends MiningStateMachineState {
    handle(){
        this.startMining()
    }

    startMining(){
        this.changeState(NoBlockState(this.context))
    }
}

; No Block in direction
class NoBlockState extends MiningStateMachineState {
    handle(){
        if(this.isFirstDirection){
            this.selectBlock()
        }
        this.placeBlock()
    }

    selectBlock(){
        this.select("0")
    }

    placeBlock(){
        this.place()
        this.changeState(BlockState(this.context))
    }
}

; Block in direction
class BlockState extends MiningStateMachineState {
    handle(){
        if(not this.isFirstDirection){
            this.selectPickaxe()
        }
        this.removeBlock()
    }

    selectPickaxe(){
        this.select("9")
    }

    removeBlock(){
        this.hit()
        this.changeState(NoBlockState(this.context))
    }
}

; Pointer to current direction
class DirectionStepper {
    static directions := ["right", "left", "top", "bottom"]
    currentIndex := 1
    value {
        get => DirectionStepper.directions[this.currentIndex]
    }

    isLast() {
        return this.currentIndex = DirectionStepper.directions.length
    }
    
    isFirst() {
        return this.currentIndex = 1
    }

    next(){
        this.currentIndex := Mod(this.currentIndex, DirectionStepper.directions.length) + 1
    }
}
