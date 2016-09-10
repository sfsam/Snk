
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
        
        let logo = SnkImageView(named: "snk", tint: SharedTheme.color(.logo), scale: 7)

        let button1 = SnkLevelButton(level: .slow,   target: self, action: #selector(MenuVC.activate(button:)))
        let button2 = SnkLevelButton(level: .medium, target: self, action: #selector(MenuVC.activate(button:)))
        let button3 = SnkLevelButton(level: .fast,   target: self, action: #selector(MenuVC.activate(button:)))
        
        // Layout logo and level buttons.
        //
        // +-view---+--------+
        // |        |a       |
        // |      [SNK]      |
        // |        |b       |
        // | [1]-b-[2]-b-[3] |
        // |                 |
        // +-----------------+
        
        view.addSubview(logo)
        view.addSubview(button1)
        view.addSubview(button2)
        view.addSubview(button3)
        
        logo.centerX(with: view)

        let metrics = ["a": Int(24 * kScale), "b": kStep]
        let views = ["logo": logo, "button1": button1, "button2": button2, "button3": button3]
        
        view.makeConstraints(metrics: metrics as [String : NSNumber]?, views: views, formatsAndOptions: [
            ("V:|-a-[logo]-b-[button2]", .alignAllCenterX),
            ("H:[button1]-b-[button2]-b-[button3]", .alignAllCenterY)
        ])
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(self)
    }
    
    func activate(button: SnkHoverButton) {
        // The min/max dance guarantees rawValue = 1 or 2 or 3 only
        let level  = SnkLevel(rawValue: min(max(button.tag, 1), 3))!
        let mainVC = self.parent as! MainVC
        mainVC.transition(to: GameVC(level: level), options: .slideLeft)
        SharedAudio.play(sound: kSoundStartGame)
    }
}
