
//  Created by Sanjay Madan on June 7, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// SplashVC shows a MOWGLII logo centered in the view.
// The logo fades in when the view appears. Resources
// are loaded and then the VC transitions to MenuVC.

final class SplashVC: NSViewController {

    override func loadView() {
        view = MoView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pixel art MOWGLII logo. Draw so each pixel in the
        // source image is 3x3 points (scale = 3) on screen.
        
        let logoView = SnkImageView(named: "mowglii", tint: SharedTheme.color(.logo), scale: 3)

        // Center logo in view. Set alphaValue = 0 so we can 
        // fade in in viewDidAppear().
        
        view.addSubview(logoView)
        view.centerX(with: logoView)
        view.centerY(with: logoView)
        view.alphaValue = 0
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Fade-in view, load sounds, wait 0.5s, transition to MenuVC.
        
        view.fadeIn(after: 0.2, duration: 0.5) {
            SharedAudio.loadSounds()
            moDispatch(after: 0.5) {
                SharedAudio.play(sound: kSoundStartup)
                let mainVC = self.parent as! MainVC
                mainVC.transition(to: MenuVC(), options: [.slideUp, .crossfade])
            }
        }
    }
}
