
//  Created by Sanjay Madan on June 17, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// Snake segments and food position are points
// on a kCols x kRows grid. SnkPoint conforms
// to Equatable so we can do collision testing.

struct SnkPoint {
    var x = 0, y = 0
}
extension SnkPoint: Equatable {}
func ==(lhs: SnkPoint, rhs: SnkPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

final class GameVC: NSViewController, CALayerDelegate, CAAnimationDelegate {
    
    enum SnkState {
        case initializing, playing, crashed, victorious, gameOver, paused
    }
    
    enum SnkDirection {
        case up, down, left, right
    }
    
    let level: SnkLevel
    
    // Layers draw and animate the various game objects. 
    // The replLayer replicates the other layers for the 
    // shadow when the game goes 3D.
    
    let wallLayer  = CALayer()
    let foodLayer  = CALayer()
    let snakeLayer = CALayer()
    let replLayer  = CAReplicatorLayer()

    let scoreLabel = SnkScoreLabel(fgColor: SharedTheme.color(.background), bgColor: SharedTheme.color(.wall))
    var scoreIncrement = kMaxScoreIncrement
    
    let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())

    // The snake is represented by a list of points with
    // the head at the end of the list (snakePoints.last).
    
    var snakePoints = [SnkPoint]()
    var foodPoint = SnkPoint()
    
    var direction: SnkDirection = .right
    var directionBuffer = [SnkDirection]()

    // When the score is over kScoreSpin, the board
    // will start to spin and the walls will disable.
    
    var wallsEnabled = true
    
    var state: SnkState = .initializing {
        didSet {
            // Hide the cursor when state == .Playing
            NSCursor.setHiddenUntilMouseMoves(state == .playing)
        }
    }
    
    init!(level: SnkLevel) {
        self.level = level
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        let v = MoView()

        // Set up the layers that make up the game objects.
        
        var frame = CGRect(x: 0, y: 0, width: kStep * kCols, height: kStep * kRows)
        
        wallLayer.frame = frame
        wallLayer.borderWidth = CGFloat(kStep)
        wallLayer.borderColor = SharedTheme.color(.wall).cgColor
        
        snakeLayer.frame = frame
        snakeLayer.delegate = self
        // Disable implicit animations between drawing frames.
        snakeLayer.actions = ["contents": NSNull()]
        
        foodLayer.frame = CGRect(x: 0, y: 0, width: kStep, height: kStep)
        foodLayer.backgroundColor = SharedTheme.color(.food).cgColor
        // Disable implicit animations for changes in position.
        foodLayer.actions = ["position": NSNull()]
        
        // The wall, food and snake layers are sublayers of
        // the replicator layer so it can replicate them to
        // draw the 3D shadow.
        
        frame.origin = CGPoint(x: kStep, y: kStep)
        replLayer.frame = frame
        replLayer.instanceCount = 2
        replLayer.instanceTransform = CATransform3DMakeTranslation(0, 0, CGFloat(-4 * kStep))
        replLayer.instanceAlphaOffset = -0.8
        replLayer.instanceRedOffset   = -1
        replLayer.instanceGreenOffset = -1
        replLayer.instanceBlueOffset  = -1
        replLayer.preservesDepth = true
        
        replLayer.addSublayer(wallLayer)
        replLayer.addSublayer(foodLayer)
        replLayer.addSublayer(snakeLayer)
        
        // Make our main view layer-hosting and add the
        // replicator layer.
        
        v.layer = CALayer()
        v.wantsLayer = true
        v.layer?.addSublayer(replLayer)
        
        // The score label is located in the top right corner
        // inset from the top and trailing egdes of the view
        // so that it appears inside the wall.
        
        v.addSubview(scoreLabel)
        scoreLabel.alignTrailing(with: v, constant: CGFloat(kStep) + 10 * kScale)
        scoreLabel.alignBottomToTop(of: v, constant: CGFloat(-kStep) - 12 * kScale)
        
        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the snake halfway down the board and
        // 2 points to the left.
        
        snakePoints = [SnkPoint( x: 2, y: Int(kRows/2) )]
        snakeLayer.setNeedsDisplay()
        
        setupFood()
        startTimer()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Since we own the snakeLayer, we have responsibility
        // for setting its contentScale.
        snakeLayer.contentsScale = self.view.window!.backingScaleFactor

        view.window!.makeFirstResponder(self)
        
        switch level {
        case .slow:   SharedAudio.play(music: kSong1, loop: true)
        case .medium: SharedAudio.play(music: kSong2, loop: true)
        case .fast:   SharedAudio.play(music: kSong3, loop: true)
        }
        
        state = .playing
    }
    
    // MARK: - Input
    
    override func keyDown(with theEvent: NSEvent) {
        func key(_ x: Int) -> String {
            return UnicodeScalar(x)!.escaped(asASCII: false)
        }
        if let chars = theEvent.charactersIgnoringModifiers {
            switch chars {
            case "w", "W", key(NSUpArrowFunctionKey):    addDirection(.up)
            case "s", "S", key(NSDownArrowFunctionKey):  addDirection(.down)
            case "a", "A", key(NSLeftArrowFunctionKey):  addDirection(.left)
            case "d", "D", key(NSRightArrowFunctionKey): addDirection(.right)
            case "P":
                if state == .playing || state == .paused {
                    state = state == .playing ? .paused : .playing
                }
            case "1": play(level: .slow)
            case "2": play(level: .medium)
            case "3": play(level: .fast)
            default: super.keyDown(with: theEvent)
            }
        }
        else {
            super.keyDown(with: theEvent)
        }
    }
    
    func addDirection(_ newDir: SnkDirection) {
        // Buffer directional keypresses in directionBuffer. 
        // Only do so when state == .Playing.
        // Consecutive directions can't be the same or
        // opposite (Snake going .Up can only go .Left
        // or .Right next, not .Down).
        
        let oldDir = directionBuffer.count > 0 ? directionBuffer.last : direction
        if  state  != .playing ||
            newDir == oldDir ||
            newDir == .up    && oldDir == .down ||
            newDir == .down  && oldDir == .up   ||
            newDir == .right && oldDir == .left ||
            newDir == .left  && oldDir == .right {
            return
        }
        directionBuffer.append(newDir)
    }
    
    // MARK: - Update
    
    func updateGame() {
        // This method is called by the timer.
        
        if state == .crashed || state == .victorious {
            gameOver()
            return
        }
        if state != .playing {
            return
        }
        
        if directionBuffer.count > 0 {
            direction = directionBuffer.remove(at: 0)
        }
        
        // Calculate where the snake's head will
        // be next. Wrap around if necessary if 
        // walls are not enabled.
        
        var newHeadPoint = snakePoints.last!
        switch direction {
        case .up:    newHeadPoint.y += 1
        case .down:  newHeadPoint.y -= 1
        case .left:  newHeadPoint.x -= 1
        case .right: newHeadPoint.x += 1
        }
        if wallsEnabled == false {
            newHeadPoint.y = newHeadPoint.y > kRows-1 ? 0 : newHeadPoint.y
            newHeadPoint.y = newHeadPoint.y < 0 ? kRows-1 : newHeadPoint.y
            newHeadPoint.x = newHeadPoint.x > kCols-1 ? 0 : newHeadPoint.x
            newHeadPoint.x = newHeadPoint.x < 0 ? kCols-1 : newHeadPoint.x
        }
        
        // The snake got the food.
        
        if newHeadPoint == foodPoint {
            // We must add newHeadPoint to the snake before
            // placing food because food placement needs to
            // know where all the snake points are so it can
            // choose an empty cell.
            advanceScore()
            snakePoints.append(newHeadPoint)
            explodeFood()
            // Did we win? Check if the snake covers the board.
            if snakePoints.count >= kCols * kRows {
                state = .victorious
            }
            else {
                placeFood()
                animateBoard()
            }
        }
            
        // The snake didn't get the food.
        
        else {
            // We must remove the old tail but NOT add the
            // new head before checking for collisions.
            // Otherwise we'd wrongly collide with a
            // phantom tail or the new head.
            tickScore()
            snakePoints.remove(at: 0)
            if (wallsEnabled &&
                (newHeadPoint.x <= 0 || newHeadPoint.x >= kCols-1 ||
                 newHeadPoint.y <= 0 || newHeadPoint.y >= kRows-1)) ||
                snakePoints.contains(newHeadPoint) {
                state = .crashed
            }
            snakePoints.append(newHeadPoint)
        }

        snakeLayer.setNeedsDisplay()
    }
    
    // MARK: - Game over
    
    func gameOver() {
        let reasonForGameOver = state
        state = .gameOver
        SharedAudio.stopMusic()
        timer.cancel()
        
        if reasonForGameOver == .crashed {
            // We crashed! Rattle the board. The animation is 20 random
            // translations about the view's center.
            
            SharedAudio.play(sound: kSoundCrash)
            
            let anim = CAKeyframeAnimation(keyPath: "position")
            let delta = UInt32(12 * kScale)
            anim.duration = 0.3
            anim.calculationMode = "discrete"
            anim.values = (1...20).map { _ in
                let x = self.view.layer!.position.x + CGFloat(arc4random_uniform(delta)) - CGFloat(delta/2)
                let y = self.view.layer!.position.y + CGFloat(arc4random_uniform(delta)) - CGFloat(delta/2)
                return NSValue(point: CGPoint(x: x, y: y))
            }
            view.layer!.add(anim, forKey: "rattle")
        }
        else { // reasonForGameOver == .victorious
            // We won! Remove the food layer, revert the board to the inital
            // 2D orientation, and blow up the snake.
            
            SharedAudio.play(sound: kSoundVictory)
            
            // Remove food and stop board from spinning.
            foodLayer.removeFromSuperlayer()
            replLayer.removeAllAnimations()
            
            // Revert to 2D.
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            CATransaction.setCompletionBlock {

                // Cover the snake with segments which we will individually
                // animate in a celebratory explosion.
                var segments = [CALayer]()
                for pt in self.snakePoints.reversed() {
                    let segment = CALayer()
                    segment.frame = CGRect(x: pt.x * kStep, y: pt.y * kStep, width: kStep, height: kStep)
                    segment.backgroundColor = SharedTheme.color(.snake).cgColor
                    self.replLayer.addSublayer(segment)
                    segments.append(segment)
                }
                
                // We've covered the board with segment layers which we
                // can animate, so now we can remove the snake layer.
                self.snakeLayer.removeFromSuperlayer()

                // After the board is back to 2D, wait 0.5 seconds and then
                // "explode" the snake one segment at a time from head to
                // tail. The animation just moves each segment along a curve.
                moDispatch(after: 0.5) {
                    let boardHeight = CGFloat(kRows * kStep)
                    for (index, segment) in segments.enumerated() {
                        moDispatch(after: TimeInterval(index) * 0.1) {
                            let animPath = CGMutablePath()
                            animPath.move(to: segment.position)
                            let midX = NSMidX(self.snakeLayer.frame)
                            let deltaX = 2 * (segment.position.x - midX)
                            let deltaY = CGFloat(arc4random_uniform(UInt32(15 * kStep)))
                            let endPt  = CGPoint(x: segment.position.x + deltaX, y: segment.position.y - boardHeight)
                            let ctrlPt = CGPoint(x: segment.position.x + deltaX/2, y: segment.position.y + deltaY)
                            animPath.addCurve(to: endPt, control1: ctrlPt, control2: ctrlPt)
                            
                            let moveAnim = CAKeyframeAnimation(keyPath: "position")
                            moveAnim.path = animPath
                            moveAnim.duration = 0.5
                            moveAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                            moveAnim.delegate = self
                            moveAnim.setValue(segment, forKey: "segmentLayer")
                            segment.add(moveAnim, forKey: nil)
                        }
                    }
                }
            }
            replLayer.transform = CATransform3DIdentity
            CATransaction.commit()
        }
        
        // After a brief delay, dim the board and show an
        // ok button centered in the view.
        
        let okButtonAppearanceDelay = (reasonForGameOver == .crashed) ? 0.5 : 4
        
        moDispatch(after: okButtonAppearanceDelay) {
            if reasonForGameOver == .crashed {
                SharedAudio.play(sound: kSoundGameOver)
            }
            self.replLayer.opacity = 0.5
            let ok = SnkHoverButton(imageName: "ok", tint: SharedTheme.color(.logo), scale: 6)
            ok.dimmedAlpha = 1
            ok.borderWidth = 6
            ok.borderHighlightColor = SharedTheme.color(.wall)
            ok.keyEquivalent = " "
            ok.target = self
            ok.action = #selector(GameVC.goToMenu)
            self.view.addSubview(ok)
            ok.centerX(with: self.view)
            ok.centerY(with: self.view)
        }
    }
    
    func goToMenu() {
        // User pressed the OK button after a game.
        // Go back to the main menu.
        
        SharedAudio.stopEverything()
        SharedAudio.play(sound: kSoundOk)
        let mainVC = self.parent as! MainVC
        mainVC.transition(to: MenuVC(), options: .slideRight)
    }
    
    private func play(level: SnkLevel) {
        guard state == .gameOver else { return }
        SharedAudio.stopEverything()
        let mainVC = self.parent as! MainVC
        mainVC.transition(to: GameVC(level: level), options: .slideLeft)
        SharedAudio.play(sound: kSoundStartGame)
    }
    
    // MARK: - Snake drawing
    
    func draw(_ layer: CALayer, in context: CGContext) {
        context.setFillColor(SharedTheme.color(.snake).cgColor)
        for p in snakePoints {
            context.fill(CGRect(x: p.x * kStep, y: p.y * kStep, width: kStep, height: kStep))
        }
    }

    // MARK: - Score
    
    func advanceScore() {
        // Advance score by scoreIncrement and reset
        // scoreIncrement to its max value. Save the
        // score if it's a high score for this level.
        
        scoreLabel.score += scoreIncrement
        scoreIncrement = kMaxScoreIncrement

        let defaults = UserDefaults.standard
        let key: String
        switch level {
        case .slow:   key = kHiScoreSlowKey
        case .medium: key = kHiScoreMediumKey
        case .fast:   key = kHiScoreFastKey
        }
        if scoreLabel.score > defaults.integer(forKey: key) {
            defaults.set(scoreLabel.score, forKey: key)
        }
    }
    
    func tickScore() {
        // On each timer tick, we decrement the amount by which
        // we'll increment the score when the snake gets the food.
        // The smallest possible scoreIncrement is 1.
        
        scoreIncrement = max(1, scoreIncrement - 1)
    }

    // MARK: - Food
    
    func setupFood() {
        // Set up a perpetual animation on the food
        // which pulses its bounds and then place
        // the food randomly on the board.
        
        let anim = CAKeyframeAnimation(keyPath: "bounds.size")
        anim.duration = 0.25
        anim.repeatCount = Float.infinity
        anim.autoreverses = true
        anim.calculationMode = "discrete"
        // stride by 2 ensures sides are even and fall on pixel boundaries (not blurry)
        anim.values = stride(from: 4, through: kStep, by: 2).map {
            NSValue(size: NSSize(width: $0, height: $0))
        }
        foodLayer.add(anim, forKey: "pulseFood")
        
        placeFood()
    }
    
    func explodeFood() {
        SharedAudio.play(sound: kSoundFoodExplosion)
        
        // Create an explosion animation when the snake
        // gets the food. The explosion is a layer that
        // is placed at the food location, animates, and
        // is then removed. The animation is actually 2
        // animations: an expansion and a fade out.
        
        // Set up the explosion layer at the food location.
        
        let explosion = CALayer()
        explosion.frame = foodLayer.frame
        explosion.borderColor = SharedTheme.color(.explosion).cgColor
        explosion.borderWidth = CGFloat(kStep)
        explosion.opacity = 0
        
        // Set up the expansion animation.
        
        let animExpand = CAKeyframeAnimation(keyPath: "bounds.size")
        animExpand.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animExpand.calculationMode = "discrete"
        // stride by 2 ensures sides are even and fall on pixel boundaries (not blurry)
        animExpand.values = stride(from: (3 * kStep), through: 6 * kStep, by: 2).map {
            NSValue(size: NSSize(width: $0, height: $0))
        }
        
        // Set up the fade out animtaion.
        
        let animFadeOut = CABasicAnimation(keyPath: "opacity")
        animFadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animFadeOut.fromValue = 1
        animFadeOut.toValue   = 0
        
        // Add the explosion layer, animate, and then
        // remove the explosion layer.
        
        replLayer.addSublayer(explosion)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setCompletionBlock({
            explosion.removeFromSuperlayer()
        })
        explosion.add(animExpand,  forKey: "expand")
        explosion.add(animFadeOut, forKey: "fadeout")
        CATransaction.commit()
    }
    
    func placeFood() {
        var frame = foodLayer.frame
        
        // Place the food randomly on the board.
        // First, choose a random location that isn't
        // on the walls if they are enabled.
        
        let xMin = wallsEnabled ? 1 : 0
        let yMin = wallsEnabled ? 1 : 0
        let xMax = wallsEnabled ? kCols-2 : kCols-1
        let yMax = wallsEnabled ? kRows-2 : kRows-1
        
        var x = Int(arc4random_uniform( UInt32(xMax) )) + xMin
        var y = Int(arc4random_uniform( UInt32(yMax) )) + yMin
        
        // Next, make sure the random location isn't on
        // on the snake. If it is, choose the next
        // available cell.
        
        while snakePoints.contains(SnkPoint(x: x, y: y)) {
            x = x + 1
            if x > xMax {
                x = xMin
                y = y + 1
                if y > yMax {
                    y = yMin
                }
            }
        }
        
        // Update the food with the new location.
        
        frame.origin = CGPoint(x: x * kStep, y: y * kStep)
        foodPoint = SnkPoint(x: x, y: y)
        foodLayer.frame = frame
    }
    
    // MARK: - Animate board
    
    func animateBoard() {
        // The board animates when certain score
        // thresholds are exceeded.
        
        if scoreLabel.score > kScoreSpin && wallsEnabled {

            // Spin around the z-axis perpetually. This is
            // done with a series of key frame rotations
            // because a single 360 rotation is the same as 0.
            // Also reduce the wall border width and color in
            // the floor (wallLayer.backgroundColor).

            wallLayer.borderWidth = 2
            wallLayer.backgroundColor = NSColor(white: 1, alpha: 0.1).cgColor
            wallsEnabled = false
            let spinAnim = CAKeyframeAnimation(keyPath: "transform")
            spinAnim.values = (0...4).map {
                let angle = CGFloat($0) * CGFloat(-M_PI/2)
                return NSValue(caTransform3D: CATransform3DRotate(self.replLayer.transform, angle, 0, 0, 1))
            }
            spinAnim.duration = 25
            spinAnim.repeatCount = Float.infinity
            replLayer.add(spinAnim, forKey: "spin")
            SharedAudio.play(sound: kSoundSpinBoard)
        }
            
        else if scoreLabel.score > kScoreRotate && wallsEnabled {
            
            // Rotate 15 degrees.
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.3)
            replLayer.transform = CATransform3DRotate(replLayer.transform, -15 * CGFloat(M_PI/180), 0, 0, 1)
            CATransaction.commit()
            SharedAudio.play(sound: kSoundRotateBoard)
        }
        
        else if scoreLabel.score > kScore3D && CATransform3DEqualToTransform(replLayer.transform, CATransform3DIdentity) {
            
            // Transform to 3D.
            
            var t = CATransform3DIdentity
            t.m34 = -1/400
            t = CATransform3DTranslate(t, 0, 10, -75);
            t = CATransform3DRotate(t, -30 * CGFloat(M_PI)/180, 1, 0, 0.2)
            CATransaction.begin()
            CATransaction.setAnimationDuration(1)
            replLayer.transform = t
            CATransaction.commit()
            SharedAudio.play(sound: kSoundAnimateTo3D)
        }
    }
    
    // MARK: - Timer
    
    func startTimer() {
        let delta: Int // nanoseconds between timer ticks
        switch level {
        case .slow:   delta = Int( kLevel1SecPerFrame * Double(NSEC_PER_SEC) )
        case .medium: delta = Int( kLevel2SecPerFrame * Double(NSEC_PER_SEC) )
        case .fast:   delta = Int( kLevel3SecPerFrame * Double(NSEC_PER_SEC) )
        }
        timer.scheduleRepeating(deadline: .now() + .nanoseconds(delta), interval: .nanoseconds(delta))
        timer.setEventHandler { [unowned self] in
            DispatchQueue.main.async {
                self.updateGame()
            }
        }
        timer.resume()
    }
    
    // MARK: - Snake-segment explosion animation did stop
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // Remove the segment layer when its animation is done. See
        // the .victorious section of gameOver() for animation code.
        if let layer = anim.value(forKey: "segmentLayer") as? CALayer {
            layer.removeFromSuperlayer()
        }
    }
    
    // MARK: - Unused
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
