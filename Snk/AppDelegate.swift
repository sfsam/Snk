
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
    
    // Fade the contentView when the window resigns Main.

    override func becomeMain() {
        super.becomeMain()
        contentView?.alphaValue = 1
    }
    override func resignMain() {
        super.resignMain()
        contentView?.alphaValue = 0.6
    }
}

// MARK: - App delegate
//
// AppDelegate handles the main window (it owns the main
// window controller), clears the high scores, and toggles
// the board size.

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var themesMenu: NSMenu?
    
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
        
        setupThemesMenu()

        showMainWindow()
    }
    
    func showMainWindow() {
        // If we are re-showing the window (because the
        // user toggled its size or changed its theme),
        // first make sure it is not miniturized and
        // not showing.
        if mainWC.window?.isMiniaturized == true {
            mainWC.window?.deminiaturize(nil)
        }
        mainWC.window?.orderOut(nil)
        
        mainWC.contentViewController = MainVC()
        
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
        
        showMainWindow()
    }

    func selectTheme(_ sender: NSMenuItem) {
        let newIndex = sender.tag
        let oldIndex = SharedTheme.themeIndex
        guard newIndex != oldIndex else {
            return
        }
        
        // Uncheck old theme menu item, check new one.
        themesMenu?.item(at: oldIndex)?.state = 0
        themesMenu?.item(at: newIndex)?.state = 1
        
        // Save the theme name and set the theme manager
        // to use the new one.
        let savedName = SharedTheme.themes[newIndex].name.rawValue
        UserDefaults.standard.set(savedName, forKey: kThemeNameKey)
        SharedTheme.setTheme(savedName: savedName)
        
        showMainWindow()
    }
    
    func setupThemesMenu() {
        // Set the theme manager to use the saved theme.
        SharedTheme.setTheme(savedName: UserDefaults.standard.string(forKey: kThemeNameKey))
        
        // Create menu items for the themes in the theme
        // manager's 'themes' array.
        for (index, theme) in SharedTheme.themes.enumerated() {
            let item = NSMenuItem()
            item.title = theme.name.rawValue
            item.state = index == SharedTheme.themeIndex ? 1 : 0
            item.tag = index
            item.action = #selector(selectTheme(_:))
            themesMenu?.addItem(item)
        }
    }
}

