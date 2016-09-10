
//  Created by Sanjay Madan on June 12, 2015
//  Copyright (c) 2015 mowglii.com

// Mowglii's extensions to Cocoa to make life a little easier.

import Cocoa

// MARK: GCD

// Dispatch `work` on the main queue after `delay` seconds.

func moDispatch(after delay: TimeInterval, execute work: @escaping () -> Void) {
    let milliseconds = Int(delay * 1000)
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds), execute: work)
}

// MARK: - NSView Auto Layout

// These Auto Layout convenience functions are marked with
// @discardableResult because the most common case is
// to use them to set fixed constraints. However, they do
// return the constraints they create in case you need to
// update them later.

extension NSView {
    
    // Set the receiver's width or height.
    
    @discardableResult
    func makeConstraint(width: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func makeConstraint(height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func makeConstraints(width: CGFloat, height: CGFloat) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append( makeConstraint(width: width) )
        constraints.append( makeConstraint(height: height) )
        return constraints
    }
    
    // Make an arbitrary fixed (.equal) constraint between the
    // receiver and `view`. Specify `attribute` and `constant`.
    
    @discardableResult
    func makeConstraint(with view: NSView, attribute: NSLayoutAttribute, constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    // Convenience methods to make particular kinds of fixed
    // (.equal) constraints between receiver and `view`. The
    // constant defaults to 0 so common calls are succinct.
    
    @discardableResult
    func centerX(with view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraint(with: view, attribute: .centerX, constant: constant)
    }
    
    @discardableResult
    func centerY(with view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraint(with: view, attribute: .centerY, constant: constant)
    }
    
    @discardableResult
    func alignTop(with view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraint(with: view, attribute: .top, constant: constant)
    }
    
    @discardableResult
    func alignBottom(with view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraint(with: view, attribute: .bottom, constant: -constant)
    }
    
    @discardableResult
    func alignLeading(with view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraint(with: view, attribute: .leading, constant: constant)
    }
    
    @discardableResult
    func alignTrailing(with view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return makeConstraint(with: view, attribute: .trailing, constant: -constant)
    }
    
    @discardableResult
    func alignTopToBottom(of view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func alignBottomToTop(of view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: -constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func alignLeadingToTrailing(of view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func alignTrailingToLeading(of view: NSView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: -constant)
        constraint.isActive = true
        return constraint
    }
    
    // Make constraints for the common case where you want
    // receiver's frame to match that of `view`.
    
    @discardableResult
    func alignFrame(with view: NSView) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append( alignTop(with: view)      )
        constraints.append( alignBottom(with: view)   )
        constraints.append( alignLeading(with: view)  )
        constraints.append( alignTrailing(with: view) )
        return constraints
    }
    
    // Auto Layout's visual format language (VFL) is great, but using it
    // can lead to verbose and unwieldy code. This method helps to make
    // using VFL more concise and readable by avoiding the repetition of
    // metrics and views while consolidating visual format strings.
    //
    // This method takes a dictionary of metrics, a dictionary of views,
    // and an array of (formatString, NSLayoutFormatOptions) tuples and
    // creates (and optionally returns) the necessary constraints.
    //
    // Example:
    //
    // let metrics = ["m1": metric1, "m2", metric2]
    // let views = ["v1": view1, "v2": view2]
    //
    // view.makeConstraints(metrics: metrics, views: views, formatsAndOptions: [
    //     ("H:|-m1-[v1]-[v2]-m2-|", .AlignAllCenterY),
    //     ("V:|-m1-[v1]", [])
    // ])
    
    @discardableResult
    func makeConstraints(metrics: [String: NSNumber]?, views: [String: Any], formatsAndOptions: [(format: String, options: NSLayoutFormatOptions)]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        for (format, options) in formatsAndOptions {
            constraints += NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: metrics, views: views)
        }
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}

// MARK: - NSView Animation

extension NSView {

    // Fade receiver in or out. Timing is in seconds.
    
    func fadeIn(after delay: TimeInterval, duration: TimeInterval, completionHandler: (() -> Void)?) {
        moDispatch(after: delay) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = duration
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                self.animator().alphaValue = 1
            }, completionHandler: completionHandler)
        }
    }
    
    func fadeOut(after delay: TimeInterval, duration: TimeInterval, completionHandler: (() -> Void)?) {
        moDispatch(after: delay) {
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
    
    func transition(from fromViewController: NSViewController, to toViewController: NSViewController, options: NSViewControllerTransitionOptions, duration: TimeInterval, completionHandler completion: (() -> Void)?) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            self.transition(from: fromViewController, to: toViewController, options: options, completionHandler: completion)
        }, completionHandler: nil)
    }
}

// MARK: - NSImage

extension NSImage {
    
    // Tint receiver with `color` and return as new image.
    
    func tint(color: NSColor) -> NSImage? {
        return NSImage(size: self.size, flipped: false, drawingHandler: { rect -> Bool in
            let context = NSGraphicsContext.current()?.cgContext
            context?.interpolationQuality = .none
            self.draw(in: NSRect(origin: CGPoint.zero, size: self.size))
            context?.setFillColor(color.cgColor)
            context?.setBlendMode(.sourceAtop)
            context?.fill(rect)
            return true
        })
    }
}
