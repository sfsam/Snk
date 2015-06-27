
//  Created by Sanjay Madan on June 12, 2015
//  Copyright (c) 2015 mowglii.com

// Mowglii's extensions to Cocoa to make life a little easier.

import Cocoa

// MARK: GCD

// Dispatch `block` on the main queue after `delay` seconds.

func mo_dispatch_after(delay: NSTimeInterval, block: dispatch_block_t) {
    let delta = Int64(delay * NSTimeInterval(NSEC_PER_SEC))
    dispatch_after(dispatch_time(0, delta), dispatch_get_main_queue(), block)
}

// MARK: - NSView Auto Layout

extension NSView {
    
    // Set the receiver's width or height.
    
    func makeWidth(width: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: width)
        constraint.active = true
        return constraint
    }
    
    func makeHeight(height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height)
        constraint.active = true
        return constraint
    }
    
    func makeWidth(width: CGFloat, height: CGFloat) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append( self.makeWidth(width) )
        constraints.append( self.makeHeight(height) )
        return constraints
    }
    
    // Make an arbitrary fixed (.Equal) constraint between the
    // receiver and `view`. Specify `attribute` and `constant`.
    
    func makeConstraintWithView(view: NSView, attribute: NSLayoutAttribute, constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: 1, constant: constant)
        constraint.active = true
        return constraint
    }
    
    // Convenience methods to make particular kinds of fixed
    // (.Equal) constraints between receiver and `view`. The
    // constant defaults to 0 so common calls are succinct.
    
    func centerXWithView(view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraintWithView(view, attribute: .CenterX, constant: constant)
    }
    
    func centerYWithView(view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraintWithView(view, attribute: .CenterY, constant: constant)
    }
    
    func alignTopWithView(view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraintWithView(view, attribute: .Top, constant: constant)
    }
    
    func alignBottomWithView(view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraintWithView(view, attribute: .Bottom, constant: -constant)
    }
    
    func alignLeadingWithView(view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraintWithView(view, attribute: .Leading, constant: constant)
    }
    
    func alignTrailingWithView(view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraintWithView(view, attribute: .Trailing, constant: -constant)
    }
    
    func alignTopToBottomOfView(view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: constant)
        constraint.active = true
        return constraint
    }
    
    func alignBottomToTopOfView(view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: -constant)
        constraint.active = true
        return constraint
    }
    
    func alignLeadingToTrailingOfView(view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: constant)
        constraint.active = true
        return constraint
    }
    
    func alignTrailingToLeadingOfView(view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: -constant)
        constraint.active = true
        return constraint
    }
    
    // Make constraints for the common case where you want
    // receiver's frame to match that of `view`.
    
    func alignFrameWithView(view: NSView) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append( self.alignTopWithView(view)      )
        constraints.append( self.alignBottomWithView(view)   )
        constraints.append( self.alignLeadingWithView(view)  )
        constraints.append( self.alignTrailingWithView(view) )
        return constraints
    }
    
    // Doing Auto Layout in code can be verbose. This method helps to make
    // Auto Layout code more concise and readable by avoiding the unnecessary
    // repitition of metrics and views while bringing visual format strings to
    // the fore.
    //
    // This method takes a dictionary of metrics and a dictionary of views and
    // returns a function to make easy-to-read visual constraints on the
    // receiver. The returned function takes two parameters: the visual format
    // string and the NSLayoutFormatOptions and returns the resulting constraints.
    //
    // Example:
    //
    // let makeConstraints = view.constraintMakerWithMetrics(["metric": m], views: ["v1": v1, "v2": v2])
    //
    // makeConstraints("H:|-m-[v1][v2]-m-|", .AlignAllCenterY)
    // makeConstraints("V:|-m-[v1]", [])
    
    func constraintMakerWithMetrics(metrics: [String: NSNumber]?, views: [String: AnyObject]) -> ((String, NSLayoutFormatOptions) -> [NSLayoutConstraint]) {
        return { (format: String, options: NSLayoutFormatOptions) -> [NSLayoutConstraint] in
            let constraints = NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: metrics, views: views)
            NSLayoutConstraint.activateConstraints(constraints)
            return constraints
        }
    }
}

// MARK: - NSView Animation

extension NSView {

    // Fade receiver in or out. Timing is in seconds.
    
    func fadeInAfterDelay(delay: NSTimeInterval, duration: NSTimeInterval, completionHandler: (() -> Void)?) {
        
        mo_dispatch_after(delay) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = duration
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                self.animator().alphaValue = 1
            }, completionHandler: completionHandler)
        }
    }
    
    func fadeOutAfterDelay(delay: NSTimeInterval, duration: NSTimeInterval, completionHandler: (() -> Void)?) {
        
        mo_dispatch_after(delay) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = duration
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                self.animator().alphaValue = 0
            }, completionHandler: completionHandler)
        }
    }
}

// MARK: - NSViewController

extension NSViewController {
    
    // Add a `duration` parameter to transitionFromViewController(...).
    
    func transitionFromViewController(fromViewController: NSViewController, toViewController: NSViewController, options: NSViewControllerTransitionOptions, duration: NSTimeInterval, completionHandler completion: (() -> Void)?) {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = duration
            ctx.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            self.transitionFromViewController(fromViewController, toViewController: toViewController, options: options, completionHandler: completion)
        }, completionHandler: nil)
    }
}

// MARK: - NSImage

extension NSImage {
    
    // Tint receiver with `color` and return as new image.
    
    func tint(color: NSColor) -> NSImage? {
        return NSImage(size: self.size, flipped: false, drawingHandler: { rect -> Bool in
            let ctx = NSGraphicsContext.currentContext()?.CGContext
            CGContextSetInterpolationQuality(ctx, .None)
            self.drawInRect(NSRect(origin: CGPointZero, size: self.size))
            CGContextSetFillColorWithColor(ctx, color.CGColor)
            CGContextSetBlendMode(ctx, .SourceAtop)
            CGContextFillRect(ctx, rect)
            return true
        })
    }
}
