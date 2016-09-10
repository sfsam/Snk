
//  Created by Sanjay Madan on 6/27/16.
//  Copyright © 2016 mowglii.com. All rights reserved.

import Cocoa

enum SnkThemeName: String {
    case standard = "Standard"
    case grayscale = "Grayscale"
    case spacecadet = "Space Cadet"
    case oldphone = "Old Phone"
}

enum SnkColorName {
    case background, logo, snake, wall, food, explosion, buttonBorder, buttonNumber
}

typealias SnkTheme = (name: SnkThemeName, colors: [SnkColorName: NSColor])

let SharedTheme = SnkThemeManager()

final class SnkThemeManager {

    let themes: [SnkTheme] = [
        (.standard, [
            .background:   NSColor(red: 0.45, green: 0.73, blue: 1, alpha: 1),
            .logo:         NSColor.white,
            .snake:        NSColor.white,
            .wall:         NSColor(red: 1, green: 0.95, blue: 0.4, alpha:1),
            .food:         NSColor.white,
            .explosion:    NSColor.white,
            .buttonBorder: NSColor(red: 1, green: 0.95, blue: 0.4, alpha:1),
            .buttonNumber: NSColor.white
            ]),
        (.grayscale, [
            .background:   NSColor(white: 0.4, alpha: 1),
            .logo:         NSColor(white: 0.9, alpha: 1),
            .snake:        NSColor(white: 0.9, alpha: 1),
            .wall:         NSColor(white: 0.7, alpha: 1),
            .food:         NSColor(white: 0.9, alpha: 1),
            .explosion:    NSColor(white: 1.0, alpha: 1),
            .buttonBorder: NSColor(white: 0.8, alpha: 1),
            .buttonNumber: NSColor(white: 0.7, alpha: 1),
            ]),
        (.spacecadet, [
            .background:   NSColor(red: 0.09, green: 0.13, blue: 0.20, alpha: 1),
            .logo:         NSColor(red: 0.13, green: 0.36, blue: 0.52, alpha: 1),
            .snake:        NSColor(red: 0.96, green: 0.70, blue: 0.44, alpha: 1),
            .wall:         NSColor(red: 0.13, green: 0.36, blue: 0.52, alpha: 1),
            .food:         NSColor(red: 0.95, green: 0.38, blue: 0.40, alpha: 1),
            .explosion:    NSColor(red: 0.80, green: 0.80, blue: 0.75, alpha: 1),
            .buttonBorder: NSColor(red: 0.95, green: 0.38, blue: 0.40, alpha: 1),
            .buttonNumber: NSColor(red: 0.60, green: 0.60, blue: 0.50, alpha: 1),
            ]),
        (.oldphone, [
            .background:   NSColor(red: 0.73, green: 0.86, blue: 0.60, alpha: 1),
            .logo:         NSColor(red: 0.21, green: 0.25, blue: 0.20, alpha: 1),
            .snake:        NSColor(red: 0.21, green: 0.25, blue: 0.20, alpha: 1),
            .wall:         NSColor(red: 0.39, green: 0.46, blue: 0.37, alpha: 1),
            .food:         NSColor(red: 0.21, green: 0.25, blue: 0.20, alpha: 1),
            .explosion:    NSColor(red: 0.21, green: 0.25, blue: 0.20, alpha: 1),
            .buttonBorder: NSColor(red: 0.21, green: 0.25, blue: 0.20, alpha: 1),
            .buttonNumber: NSColor(red: 0.36, green: 0.48, blue: 0.35, alpha: 1),
            ]),
        ]
    
    private(set) var themeIndex = 0 // Standard theme

    func color(_ colorName: SnkColorName) -> NSColor {
        // Return the .standard color (themeIndex 0) if themeIndex 
        // is out of bounds or colorName isn't defined on the 
        // selected theme.
        let index = 0..<themes.count ~= themeIndex ? themeIndex : 0
        guard let color = themes[index].colors[colorName] else {
            return themes[0].colors[colorName]!
        }
        return color
    }
    
    func setTheme(savedName: String?) {
        // Convert a saved name from UserDefaults to an index in
        // the array of themes. Default to 0 (.standard theme) if
        // no theme name matches defaultsKey.
        var index = 0
        if  let savedName = savedName,
            let themeName = SnkThemeName(rawValue: savedName) {
            for (i, theme) in themes.enumerated() {
                if themeName == theme.name {
                    index = i
                    break
                }
            }
        }
        themeIndex = index
    }
}
