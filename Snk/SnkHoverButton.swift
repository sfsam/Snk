
//  Created by Sanjay Madan on June 14, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// SnkHoverButton can notify a delegate that
// its hover state has changed.

protocol SnkHoverButtonDelegate: class {
    func hoverChangedForButton(button: SnkHoverButton)
}

// SnkHoverButton shows its content in a dimmed state
// by default. On hover, content is shown with
// alphaValue = 1. Optionally, the button will also
// draw a border on hover. You can add subviews or
// provide an image for the button's content.

class SnkHoverButton: NSButton {
    
    weak var delegate: SnkHoverButtonDelegate?
    
    // Appearance customization.
    
    var bgHighlightColor = NSColor(white: 1, alpha: 0.4)
    var borderHighlightColor = NSColor.clearColor()
    var borderWidth: CGFloat = 4
    var dimmedAlpha: CGFloat = 0.4
    
    var hovering = false {
        didSet {
            delegate?.hoverChangedForButton(self)
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.title = ""
        self.bordered = false
        self.bezelStyle = .RegularSquareBezelStyle
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(imageName: String, tint: NSColor?, scale: CGFloat) {
        self.init()
        let imageView = SnkImageView(named: imageName, tint: tint, scale: scale)
        self.addSubview(imageView)
        self.alignFrameWithView(imageView)
    }
    
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    override func updateTrackingAreas() {
        for trackingArea in self.trackingAreas {
            removeTrackingArea(trackingArea as NSTrackingArea)
        }
        let ta = NSTrackingArea(rect: NSZeroRect, options: ([.MouseEnteredAndExited, .ActiveAlways, .InVisibleRect, .EnabledDuringMouseDrag]), owner: self, userInfo: nil)
        addTrackingArea(ta)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        hovering = true
        needsDisplay = true
    }
    
    override func mouseExited(theEvent: NSEvent) {
        hovering = false
        needsDisplay = true
    }
    
    override func updateLayer() {
        
        // Set the button's alphaValue, border color, and
        // background color depending on its highlight and
        // hovering state.
        
        let alpha  = highlighted || hovering ? 1 : dimmedAlpha
        let border = highlighted || hovering ? borderHighlightColor : NSColor.clearColor()
        let bg     = highlighted ? bgHighlightColor : NSColor.clearColor()
        
        self.alphaValue = alpha
        self.layer?.borderWidth = borderWidth * kScale
        self.layer?.borderColor = border.CGColor
        self.layer?.backgroundColor = bg.CGColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
