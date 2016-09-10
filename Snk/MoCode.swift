
//  Created by Sanjay Madan on May 26, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// MARK: - MoView

// MoView is an Auto Layout-ready view that makes custom
// drawing possible without the need to subclass.

class MoView: NSView {
    
    // Optional background color.
    
    var bgColor: NSColor? {
        didSet {
            needsDisplay = true
        }
    }
    
    // Optional draw block allows custom drawing without subclassing.
    // The block is passed the current context and the view bounds.
    
    var drawBlock: ((_ context: CGContext, _ bounds: NSRect) -> Void)? {
        didSet {
            needsDisplay = true
        }
    }
    
    // By default, do not translate autoresizing mask into constraints
    // so doing Auto Layout in code is a little more efficient.
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        // Fill with optional background color.
        
        if let color = bgColor {
            color.set()
            NSRectFillUsingOperation(bounds, .sourceOver)
        }
        
        // Draw with optional draw block.
        
        if let block = drawBlock {
            let context = NSGraphicsContext.current()!.cgContext
            block(context, bounds)
        }
        
        super.draw(dirtyRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
