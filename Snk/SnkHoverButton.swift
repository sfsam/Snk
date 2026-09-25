
//  Created by Sanjay Madan on June 14, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// SnkHoverButton can notify a delegate that
// its hover state has changed.

@MainActor
protocol SnkHoverButtonDelegate: AnyObject {
    func hoverChanged(for button: SnkHoverButton)
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
    var borderHighlightColor = NSColor.clear
    var borderWidth: CGFloat = 4
    var dimmedAlpha: CGFloat = 0.4
    
    var hovering = false {
        didSet {
            delegate?.hoverChanged(for: self)
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.title = ""
        self.isBordered = false
        self.bezelStyle = .regularSquare
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Track the mouse entering and exiting the button.
        // Because of .inVisibleRect, AppKit keeps the tracking
        // rect in sync with the button's visible area, so the
        // tracking area never needs to be replaced.
        
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect, .enabledDuringMouseDrag], owner: self, userInfo: nil))
    }
    
    convenience init(imageName: String, tint: NSColor?, scale: CGFloat) {
        self.init()
        let imageView = SnkImageView(named: imageName, tint: tint, scale: scale)
        self.addSubview(imageView)
        self.alignFrame(with: imageView)
    }
    
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        hovering = true
        needsDisplay = true
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        hovering = false
        needsDisplay = true
    }
    
    override func updateLayer() {
        // Set the button's alphaValue, border color, and
        // background color depending on its highlight and
        // hovering state.
        
        let alpha  = isHighlighted || hovering ? 1 : dimmedAlpha
        let border = isHighlighted || hovering ? borderHighlightColor : NSColor.clear
        let bg     = isHighlighted ? bgHighlightColor : NSColor.clear
        
        self.alphaValue = alpha
        self.layer?.borderWidth = borderWidth * kScale
        self.layer?.borderColor = border.cgColor
        self.layer?.backgroundColor = bg.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
