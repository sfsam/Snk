
//  Created by Sanjay Madan on June 13, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// SnkImageView is a view with an image drawn into it.
// It is meant to be used with pixel art where the 
// source image is very small and is to be scaled up,
// typically by an integral amount, to a viewable size.

class SnkImageView: MoView {

    // Create a view with `image` drawn into it.
    // The size (in points, not pixels) of the view is the
    // original image size scaled by `scale`. For example,
    // if `image` has size (100, 22) and `scale` is 4, the
    // resuling SnkImageView will have size (400, 88) and
    // the image will be drawn scaled to fill that size.
    
    init(image: NSImage?, scale: CGFloat = 1) {
        // If `image` is nil, return an empty view
        guard let image = image else {
            super.init(frame: NSZeroRect)
            return
        }
        let width  = scale * image.size.width * kScale
        let height = scale * image.size.height * kScale
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: height))
        self.makeConstraints(width: width, height: height)
        self.drawBlock = { (context, bounds) in
            image.draw(in: bounds)
        }
    }
    
    // Create a view with image named `named` drawn into it.
    // Tint it with `tint` and scale it by `scale`. If `tint`
    // is nil, don't tint the image.
    
    convenience init(named name: String, tint: NSColor?, scale: CGFloat = 1) {
        let image = (tint == nil) ? NSImage(named: name)
                                  : NSImage(named: name)?.tint(color: tint!)
        self.init(image: image, scale: scale)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
