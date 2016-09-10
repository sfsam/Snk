
//  Created by Sanjay Madan on June 16, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// SnkScoreLabel draws a score with foreground and
// background colors. The background forms a border
// (stroke) around the digits. See digitsfg.png and
// digitsbg.png to see what the digits look like.
// 
// Example: 21 
// X: digitFg, -: digitBg, .: viewBg
//
// ------------.
// -XXXXX--XXX-.
// -----X---XX-.
// -XXXXX-.-XX-.
// -X-----.-XX-.
// -XXXXX-.-XX-.
// -------.----.
//
// When drawn on screen, digits are scaled up 2x.

final class SnkScoreLabel: MoView {
    
    // Only draw foreground digits when false.
    
    var drawsDigitsBackground = true
    
    // Validate score, set view size, and draw it.
    
    var score: Int = 0 {
        didSet {
            self.score = max(0, self.score) // enforce score >= 0
            self.invalidateIntrinsicContentSize()
            self.needsDisplay = true
        }
    }
    
    // View size changes to fit digits in score.
    
    override var intrinsicContentSize: CGSize {
        let numberOfDigits = CGFloat(String(score).characters.count)
        // Each digit is 12x14 points + 1 on each side for margin
        let width = numberOfDigits * (12 * kScale) + (2 * kScale)
        return CGSize(width: width, height: 14 * kScale)
    }
    
    let digitsFg: NSImage!
    let digitsBg: NSImage!
    
    // Create a score label with a digit background.

    init(fgColor: NSColor, bgColor: NSColor) {
        self.digitsFg = NSImage(named: "digitsfg")?.tint(color: fgColor)
        self.digitsBg = NSImage(named: "digitsbg")?.tint(color: bgColor)
        
        super.init(frame: NSZeroRect)
        
        self.drawBlock = { (context, bounds) in
            
            if self.score == 0 { return }
            
            // No anti-aliasing so pixels are sharp when scaled.
            context.interpolationQuality = .none

            // Convert the score to a string so we can enumerate its
            // digits. First draw the digit background and then draw 
            // the digit foreground on top of it.
            
            let scoreString = String(self.score)
            for (index, digitCharacter) in scoreString.characters.enumerated() {
                let digit  = Int( String(digitCharacter) )!
                let toOffset   = 12 * kScale * CGFloat(index)
                let toWidth    = 14 * kScale
                let fromOffset =  7 * digit
                let toRect   = NSRect(x: toOffset, y: 0, width: toWidth, height: toWidth)
                let fromRect = NSRect(x: fromOffset, y: 0, width: 7, height: 7)
                if self.drawsDigitsBackground {
                    self.digitsBg.draw(in: toRect, from: fromRect, operation: .sourceOver, fraction: 1)
                }
                self.digitsFg.draw(in: toRect, from: fromRect, operation: .sourceOver, fraction: 1)
            }
        }
    }
    
    // Create a score label without a digit background.
    
    convenience init(fgColor: NSColor) {
        self.init(fgColor: fgColor, bgColor: fgColor)
        self.drawsDigitsBackground = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
