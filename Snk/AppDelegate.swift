
//  Created Sanjay Madan on May 26, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// MARK: Main window

final class MainWindow: NSWindow {
    
    // The app terminates when the main window is closed.

    override func close() {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    // The window's background color depends on Main status.
    // Also, when the window isn't Main, the content view is
    // slightly faded.

    override func becomeMainWindow() {
        super.becomeMainWindow()
        backgroundColor = kBgColor
        contentView?.alphaValue = 1
    }
    override func resignMainWindow() {
        super.resignMainWindow()
        backgroundColor = kBgColor.blendedColorWithFraction(0.3, ofColor: NSColor.whiteColor())
        contentView?.alphaValue = 0.8
    }
}

// MARK: - App delegate
//
// AppDelegate handles the main window (it owns the main
// window controller), clears the high scores, and toggles
// the board size.

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    // The main window is non-resizable and non-zoomable. Its fixed
    // size is determined by the MainVC's view. The window uses the
    // NSFullSizeContentViewWindowMask so that we can draw our own
    // title bar.
    
    let mainWC = NSWindowController(window: MainWindow(contentRect: NSZeroRect, styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSFullSizeContentViewWindowMask, backing: .Buffered, defer: false))

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Register defaults.
        
        let defaultOptions: [String: AnyObject] = [
            kHiScoreSlowKey:   0,
            kHiScoreMediumKey: 0,
            kHiScoreFastKey:   0,
            kEnableSoundsKey:  1,
            kEnableMusicKey:   1,
            kBigBoardKey:      0
        ]
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultOptions)

        showMainWindow()
    }
    
    func showMainWindow() {
        
        mainWC.contentViewController = MainVC()
        
        // Set the window background color.
        // Hide the titlebar so we can draw our own in MainVC.
        // Hide the unused zoom button.
        
        mainWC.window?.backgroundColor = kBgColor
        mainWC.window?.titlebarAppearsTransparent = true
        mainWC.window?.standardWindowButton(.ZoomButton)?.alphaValue = 0
        
        // Fade the window in.
        
        mainWC.window?.alphaValue = 0
        mainWC.showWindow(self)
        mainWC.window?.center()
        mo_dispatch_after(0.1) {
            self.mainWC.window?.animator().alphaValue = 1
        }
    }

    @IBAction func clearScores(sender: AnyObject) {
        
        // Called from the Clear Scores... menu item.
        // Show an alert to confirm the user really
        // wants to erase their saved high scores.
        
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Clear scores?", comment: "")
        alert.informativeText = NSLocalizedString("Do you really want to clear your best scores?", comment: "")
        alert.addButtonWithTitle(NSLocalizedString("No", comment: ""))
        alert.addButtonWithTitle(NSLocalizedString("Yes", comment: ""))
        if alert.runModal() == NSAlertSecondButtonReturn {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(0, forKey: kHiScoreSlowKey)
            defaults.setInteger(0, forKey: kHiScoreMediumKey)
            defaults.setInteger(0, forKey: kHiScoreFastKey)
        }
    }
    
    @IBAction func toggleSize(sender: AnyObject) {

        // Called from Toggle Size menu item.
        // Toggle between standard and big board size.
        // Set the user default to the new value, set
        // kScale and kStep to their new values, hide
        // the main window and then re-show it.
        // Re-showing the window will re-instantiate
        // MainVC with the new sizes.
        
        SharedAudio.stopEverything()
        
        let bigBoard = kScale == 1 ? true : false
        NSUserDefaults.standardUserDefaults().setBool(bigBoard, forKey: kBigBoardKey)
        
        kScale = bigBoard ? 2 : 1
        kStep = kBaseStep * Int(kScale)
        
        if mainWC.window?.miniaturized == true {
            mainWC.window?.deminiaturize(nil)
        }
        
        mainWC.window?.orderOut(nil)

        showMainWindow()
    }
}

