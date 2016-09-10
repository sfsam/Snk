
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
    
    let scoreLabel = SnkScoreLabel(fgColor: SharedTheme.color(.logo))
    
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
        button.keyEquivalentModifierMask = NSEventModifierFlags(rawValue: 0) // No modifier
        button.delegate = self

        // Button dimensions. Button shows a border.
        
        button.makeConstraints(width: 48 * kScale, height: 48 * kScale)
        button.borderHighlightColor = SharedTheme.color(.buttonBorder)
        button.dimmedAlpha = 1
        
        // Set up the view that shows the level number.
        
        let numberView = SnkImageView(named: String(level.rawValue), tint: SharedTheme.color(.buttonNumber), scale: 5)
        button.addSubview(numberView)
        numberView.alphaValue = 0.3
        numberView.centerX(with: button)
        numberView.centerY(with: button)
        
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
        case .slow:   snakeAnim.duration = 24 * kLevel1SecPerFrame
        case .medium: snakeAnim.duration = 24 * kLevel2SecPerFrame
        default:      snakeAnim.duration = 24 * kLevel3SecPerFrame
        }
        
        // Set up the layer that shows the animated snake.
        
        let snakeLayer = CALayer()
        
        // The animated snake for level 2 is rotated 90 degrees
        // because the alternating orientation looks better.
        
        if level == .medium {
            snakeLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 0, 1)
        }
        
        snakeLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        snakeLayer.magnificationFilter = kCAFilterNearest
        snakeLayer.contents = NSImage(named: "frames")?.tint(color: SharedTheme.color(.snake))
        snakeLayer.add(snakeAnim, forKey: "snakeAnim")
        
        // Create a view to host the snake layer and center it
        // within the button.
        
        let snakeLayerHostingView = MoView()
        snakeLayerHostingView.wantsLayer = true
        snakeLayerHostingView.layer = CALayer()
        snakeLayerHostingView.layer?.addSublayer(snakeLayer)
        snakeLayerHostingView.makeConstraints(width: 32 * kScale, height: 32 * kScale)

        button.addSubview(snakeLayerHostingView)
        snakeLayerHostingView.centerX(with: button)
        snakeLayerHostingView.centerY(with: button)

        // Ok, the level button is done!
        
        // Set up the score label. Bind its score property to
        // the hi score stored in NSUserDefaults for `level`.
        
        var keyPath = "values."
        switch level {
        case .slow:   keyPath += kHiScoreSlowKey
        case .medium: keyPath += kHiScoreMediumKey
        default:      keyPath += kHiScoreFastKey
        }
        scoreLabel.bind("score", to: NSUserDefaultsController.shared(), withKeyPath: keyPath, options: nil)
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
        
        let metrics = ["a": 4 * kScale]
        let views = ["button": button, "score": scoreLabel] as [String : Any]
        
        self.makeConstraints(metrics: metrics as [String : NSNumber], views: views, formatsAndOptions: [
            ("V:|[button]-a-[score]|", .alignAllCenterX),
            ("H:|[button]|", [])
        ])
    }
    
    // When the hover state of the button changes, change
    // the alphaValue of the score label.
    
    func hoverChanged(for button: SnkHoverButton) {
        scoreLabel.alphaValue = button.hovering ? 1 : kScoreDimmedAlpha
        if button.hovering {
            SharedAudio.play(sound: kSoundHover, volume: 0.3)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
