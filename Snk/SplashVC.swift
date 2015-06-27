
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
        
        let logoView = SnkImageView(named: "mowglii", tint: kLogoColor, scale: 3)

        // Center logo in view. Set alphaValue = 0 so we can 
        // fade in in viewDidAppear().
        
        view.addSubview(logoView)
        view.centerXWithView(logoView)
        view.centerYWithView(logoView)
        view.alphaValue = 0
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Fade-in view, load sounds, wait 0.5s, transition to MenuVC.
        
        view.fadeInAfterDelay(0.2, duration: 0.5) {
            SharedAudio.loadSounds()
            mo_dispatch_after(0.5) {
                SharedAudio.playSound(kSoundStartup)
                let mainVC = self.parentViewController as! MainVC
                mainVC.transitionToViewController(MenuVC(), options: [.SlideUp, .Crossfade])
            }
        }
    }
}
