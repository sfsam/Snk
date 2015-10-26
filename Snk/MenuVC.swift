
//  Created by Sanjay Madan on June 13, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

final class MenuVC: NSViewController {
    
    override func loadView() {
        view = MoView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SNK logo. Draw so each pixel in the source image
        // is 7x7 points (scale = 7) on screen.
        
        let snkLogo = SnkImageView(named: "snk", tint: kLogoColor, scale: 7)

        let button1 = SnkLevelButton(level: .Slow,   target: self, action: "playLevel:")
        let button2 = SnkLevelButton(level: .Medium, target: self, action: "playLevel:")
        let button3 = SnkLevelButton(level: .Fast,   target: self, action: "playLevel:")
        
        // Layout logo and level buttons.
        //
        // +-view---+--------+
        // |        |a       |
        // |      [SNK]      |
        // |        |b       |
        // | [1]-b-[2]-b-[3] |
        // |                 |
        // +-----------------+
        
        view.addSubview(snkLogo)
        view.addSubview(button1)
        view.addSubview(button2)
        view.addSubview(button3)
        
        snkLogo.centerXWithView(view)

        let metrics = ["a": Int(24 * kScale), "b": kStep]
        let makeConstraints = view.constraintMakerWithMetrics(metrics, views: ["snkLogo": snkLogo, "button1": button1, "button2": button2, "button3": button3])
        
        makeConstraints("V:|-a-[snkLogo]-b-[button2]", .AlignAllCenterX)
        makeConstraints("H:[button1]-b-[button2]-b-[button3]", .AlignAllCenterY)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(self)
    }
    
    func playLevel(button: SnkHoverButton) {
        // The min/max dance guarantees rawValue = 1 or 2 or 3 only
        let level  = SnkLevel(rawValue: min(max(button.tag, 1), 3))!
        let mainVC = self.parentViewController as! MainVC
        mainVC.transitionToViewController(GameVC(level: level), options: .SlideLeft)
        SharedAudio.playSound(kSoundStartGame)
    }
}
