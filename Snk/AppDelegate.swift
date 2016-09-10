
//  Created Sanjay Madan on May 26, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// MARK: Main window

final class MainWindow: NSWindow {
    
    // The main window is non-resizable and non-zoomable.
    // Its fixed size is determined by the MainVC's view.
    // The window uses the NSFullSizeContentViewWindowMask
    // so that we can draw our own custom title bar.

    convenience init() {
        self.init(contentRect: NSZeroRect, styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView], backing: .buffered, defer: false)
        self.titlebarAppearsTransparent = true
        self.standardWindowButton(.zoomButton)?.alphaValue = 0
    }
    
    // The app terminates when the main window is closed.

    override func close() {
        NSApplication.shared().terminate(nil)
    }
    
    // The window's background color depends on Main status.
    // Also, when the window isn't Main, the content view is
    // slightly faded.

    override func becomeMain() {
        super.becomeMain()
        backgroundColor = kBgColor
        contentView?.alphaValue = 1
    }
    override func resignMain() {
        super.resignMain()
        backgroundColor = kBgColor.blended(withFraction: 0.3, of: NSColor.white)
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
    
    let mainWC = NSWindowController(window: MainWindow())

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        UserDefaults.standard.register(defaults: [
            kHiScoreSlowKey:   0 as AnyObject,
            kHiScoreMediumKey: 0 as AnyObject,
            kHiScoreFastKey:   0 as AnyObject,
            kEnableSoundsKey:  1 as AnyObject,
            kEnableMusicKey:   1 as AnyObject,
            kBigBoardKey:      0 as AnyObject
        ])

        showMainWindow()
    }
    
    func showMainWindow() {
        mainWC.contentViewController = MainVC()
        
        // Set the window background color.
        
        mainWC.window?.backgroundColor = kBgColor
        
        // Fade the window in.
        mainWC.window?.alphaValue = 0
        mainWC.showWindow(self)
        mainWC.window?.center()
        moDispatch(after: 0.1) {
            self.mainWC.window?.animator().alphaValue = 1
        }
    }

    @IBAction func clearScores(_ sender: AnyObject) {
        // Called from the Clear Scores... menu item.
        // Show an alert to confirm the user really
        // wants to erase their saved high scores.
        
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Clear scores?", comment: "")
        alert.informativeText = NSLocalizedString("Do you really want to clear your best scores?", comment: "")
        alert.addButton(withTitle: NSLocalizedString("No", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Yes", comment: ""))
        if alert.runModal() == NSAlertSecondButtonReturn {
            UserDefaults.standard.set(0, forKey: kHiScoreSlowKey)
            UserDefaults.standard.set(0, forKey: kHiScoreMediumKey)
            UserDefaults.standard.set(0, forKey: kHiScoreFastKey)
        }
    }
    
    @IBAction func toggleSize(_ sender: AnyObject) {
        // Called from Toggle Size menu item.
        // Toggle between standard and big board size.
        // Set the user default to the new value, set
        // kScale and kStep to their new values, hide
        // the main window and then re-show it.
        // Re-showing the window will re-instantiate
        // MainVC with the new sizes.
        
        SharedAudio.stopEverything()
        
        let bigBoard = kScale == 1 ? true : false
        UserDefaults.standard.set(bigBoard, forKey: kBigBoardKey)
        
        kScale = bigBoard ? 2 : 1
        kStep = kBaseStep * Int(kScale)
        
        if mainWC.window?.isMiniaturized == true {
            mainWC.window?.deminiaturize(nil)
        }
        
        mainWC.window?.orderOut(nil)

        showMainWindow()
    }
}

