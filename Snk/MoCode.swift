
//  Created by Sanjay Madan on May 26, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// MARK: - MoView

// MoView is an Auto Layout-ready view that makes custom
// drawing possible without the need to subclass.

class MoView: NSView {
    
    // Optional background color.
    
    var bgColor: NSColor?
    
    // Optional draw block allows custom drawing without subclassing.
    // The block is passed the current context and the view bounds.
    
    var drawBlock: ((ctx: CGContextRef, bounds: NSRect) -> ())?
    
    // By default, do not translate autoresizing mask into constraints
    // so doing Auto Layout in code is a little more efficient.
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
        // Fill with optional background color.
        
        if let color = bgColor {
            color.set()
            NSRectFillUsingOperation(bounds, .CompositeSourceOver)
        }
        
        // Draw with optional draw block.
        
        if let block = drawBlock {
            let ctx = NSGraphicsContext.currentContext()!.CGContext
            block(ctx: ctx, bounds: bounds)
        }
        
        super.drawRect(dirtyRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
