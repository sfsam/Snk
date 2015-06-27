
//  Created by Sanjay Madan on June 14, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// Dimmed high score label alphaValue
let kScoreDimmedAlpha: CGFloat = 0.2

// SnkLevelButton is a bit of a misnomer. It is actually a
// container for a level button and a high score label.
// Both the button and the label highlight when the user
// mouses over the button.

final class SnkLevelButton: MoView, SnkHoverButtonDelegate {
    
    let scoreLabel = SnkScoreLabel(fgColor: kLogoColor)
    
    init(level: SnkLevel, target: AnyObject?, action: Selector) {
        
        super.init(frame: NSZeroRect)
        
        // There are 2 parts: the level button and the high
        // score label.
        
        // Let's build a level button. It's an SnkHoverButton
        // with 2 additional subviews: the level number and
        // an animated snake. The level number is just an
        // SnkImageView centered in the button. The animated
        // snake is a layer-hosting view which hosts a layer
        // that runs a key-frame animation.
        
        let button = SnkHoverButton()
        
        // First, do basic button setup.

        button.target = target
        button.action = action
        button.tag = level.rawValue
        button.keyEquivalent = String(level.rawValue)
        button.keyEquivalentModifierMask = 0 // No modifier
        button.delegate = self

        // Button dimensions. Button shows a border.
        
        button.makeWidth(48 * kScale, height: 48 * kScale)
        button.borderHighlightColor = kLevelButtonBorderColor
        button.dimmedAlpha = 1
        
        // Set up the view that shows the level number.
        
        let numberView = SnkImageView(named: String(level.rawValue), tint: kLevelButtonNumberColor, scale: 5)
        button.addSubview(numberView)
        numberView.alphaValue = 0.3
        numberView.centerXWithView(button)
        numberView.centerYWithView(button)
        
        // Set up a key-frame animation for the snake. 
        // There are 24 frames in the animation and the
        // animation duration matches the level speed.
        
        let snakeAnim  = CAKeyframeAnimation(keyPath: "contentsRect")
        snakeAnim.calculationMode = "discrete"
        snakeAnim.repeatCount = Float.infinity
        snakeAnim.values = (0...23).map {
            NSValue(rect: NSRect(x: CGFloat($0)/24, y: 0, width: 1/24, height: 1))
        }
        switch level { // anim duration matches level speed
        case .Slow:   snakeAnim.duration = 24 * kLevel1SecPerFrame
        case .Medium: snakeAnim.duration = 24 * kLevel2SecPerFrame
        default:      snakeAnim.duration = 24 * kLevel3SecPerFrame
        }
        
        // Set up the layer that shows the animated snake.
        
        let snakeLayer = CALayer()
        
        // The animated snake for level 2 is rotated 90 degrees
        // because the alternating orientation looks better.
        
        if level == .Medium {
            snakeLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 0, 1)
        }
        
        snakeLayer.autoresizingMask = [.LayerWidthSizable, .LayerHeightSizable]
        snakeLayer.magnificationFilter = kCAFilterNearest
        snakeLayer.contents = NSImage(named: "frames")?.tint(kSnakeColor)
        snakeLayer.addAnimation(snakeAnim, forKey: "snakeAnim")
        
        // Create a view to host the snake layer and center it
        // within the button.
        
        let snakeLayerHostingView = MoView()
        snakeLayerHostingView.wantsLayer = true
        snakeLayerHostingView.layer = CALayer()
        snakeLayerHostingView.layer?.addSublayer(snakeLayer)
        snakeLayerHostingView.makeWidth(32 * kScale, height: 32 * kScale)

        button.addSubview(snakeLayerHostingView)
        snakeLayerHostingView.centerXWithView(button)
        snakeLayerHostingView.centerYWithView(button)

        // Ok, the level button is done!
        
        // Set up the score label. Bind its score property to
        // the hi score stored in NSUserDefaults for `level`.
        
        var keyPath = "values."
        switch level {
        case .Slow:   keyPath += kHiScoreSlowKey
        case .Medium: keyPath += kHiScoreMediumKey
        default:      keyPath += kHiScoreFastKey
        }
        scoreLabel.bind("score", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: keyPath, options: nil)
        scoreLabel.alphaValue = kScoreDimmedAlpha

        // Ok, the score label is done!
        
        // Finally, layout the button and score.
        //
        // +-self---+
        // |[button]|
        // |   |a   |
        // |[scoreL]|
        // +--------+
        
        self.addSubview(button)
        self.addSubview(scoreLabel)
        
        let makeConstraints = self.constraintMakerWithMetrics(["a": 4 * kScale], views: ["button": button, "score": scoreLabel])
        
        makeConstraints("V:|[button]-a-[score]|", .AlignAllCenterX)
        makeConstraints("H:|[button]|", [])
    }
    
    // When the hover state of the button changes, change
    // the alphaValue of the score label.
    
    func hoverChangedForButton(button: SnkHoverButton) {
        scoreLabel.alphaValue = button.hovering ? 1 : kScoreDimmedAlpha
        if button.hovering {
            SharedAudio.playSound(kSoundHover, volume: 0.3)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
