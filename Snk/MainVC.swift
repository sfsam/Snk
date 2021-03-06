
//  Created by Sanjay Madan on May 26, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

final class MainVC: NSViewController {
    
    // Child view controller views are subviews of contentView.
    // It sits just below the toolbar drawn by our main view.
    
    let contentView = MoView()
    
    // The main view draws the titlebar and hosts the views of
    // child view controllers. The titlebar is drawn as a semi-
    // transparent gradient that allows the window's background
    // color to show through.
    //
    // This view's dimensions determine the size of the window.
    
    override func loadView() {
        let v = MoView()
        
        // Calculate the titlebar height of a normal window so we
        // have this dimension for our custom drawing and layout.
        
        let contentRect = NSRect(x: 0, y: 0, width: 200, height: 200)
        let frameRect = NSWindow.frameRect(forContentRect: contentRect, styleMask: [.titled])
        let titlebarHeight = frameRect.height - contentRect.height

        // Fill background and draw title bar.
        
        v.bgColor = SharedTheme.color(.background)
        v.drawBlock = { (context, bounds) in
            // Title bar gradient.
            var rect = bounds
            rect.origin.y = bounds.height - titlebarHeight
            rect.size.height = titlebarHeight
            let c1 = NSColor(white: 1, alpha: 0.8)
            let c2 = NSColor(white: 1, alpha: 0.4)
            NSGradient(starting: c1, ending: c2)?.draw(in: rect, angle: -90)
            // Title bar top highlight.
            rect.origin.y = bounds.height - 1
            rect.size.height = 1
            NSColor(white: 1, alpha: 0.5).set()
            rect.fill(using: .sourceOver)
            // Shadow under title bar.
            rect.origin.y = bounds.height - titlebarHeight - 2
            rect.size.height = 2;
            NSColor(white: 0, alpha: 0.1).set()
            rect.fill(using: .sourceOver)
        }

        v.addSubview(contentView)
        
        // The view dimensions are fixed and determine the size of
        // the main window. They must accomodate the board as well
        // as the title bar. The board is kCols x kRows and has a
        // kStep wide margin on all sides.
        //
        // The contentView sits just below our drawn titlebar and
        // hugs the sides and bottom of our view.
        //
        // +--self.view--+
        // |      |tb    |
        // |[contentView]|
        // +-------------+
        
        let contentViewWidth  = CGFloat( (1 + kCols + 1) * kStep ),
            contentViewHeight = CGFloat( (1 + kRows + 1) * kStep )
        let metrics = ["tb": titlebarHeight, "w": contentViewWidth, "h": contentViewHeight]
        let views = ["contentView": contentView]
        
        v.makeConstraints(metrics: metrics as [String : NSNumber]?, views: views, formatsAndOptions: [
            ("V:|-tb-[contentView(h)]|", []),
            ("H:|[contentView(w)]|", [])
        ])
        
        view = v
    }

    // Add SplashVC as initial child.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let splashVC = SplashVC()
        addChild(splashVC)
        contentView.addSubview(splashVC.view)
        splashVC.view.alignFrame(with: contentView)
    }
    
    // Transition to a new childVC. This method is called
    // by childVCs to transition to a new child.
    
    func transition(to newVC: NSViewController, options: NSViewController.TransitionOptions) {
        // oldVC: Deactivate the constraints that bind oldVC's
        // view to self.contentView so that oldVC's view can
        // animate out.
        
        let oldVC = children[0] // There is only ever 1 child.
        oldVC.view.translatesAutoresizingMaskIntoConstraints = true
        NSLayoutConstraint.deactivate(contentView.constraints)

        // newVC: Add newVC as a child and set up its view. Don't
        // set up the newVC's view's constraints yet so it can
        // animate in. We'll set constraints after animating.
        
        addChild(newVC)
        newVC.view.translatesAutoresizingMaskIntoConstraints = true
        
        // Animate.
        
        transition(from: oldVC, to: newVC, options: options, duration: 0.25) {
            // Remove oldVC as a child and set up newVC's view's constraints.
            oldVC.removeFromParent()
            newVC.view.translatesAutoresizingMaskIntoConstraints = false
            newVC.view.alignFrame(with: self.contentView)
        }
    }
}
