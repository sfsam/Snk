
//  Created by Sanjay Madan on May 26, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// MARK: NSUserDefaults keys
// (High score keys are per level. See SnkLevel.)

let kEnableSoundsKey  = "EnableSounds"
let kEnableMusicKey   = "EnableMusic"
let kBigBoardKey      = "BigBoard"
let kThemeNameKey     = "ThemeName"

// MARK: - Sounds

let kSoundStartup       = "splash.mp3"
let kSoundHover         = "tick.mp3"
let kSoundStartGame     = "lance.mp3"
let kSoundFoodExplosion = "boop.mp3"
let kSoundAnimateTo3D   = "3d.mp3"
let kSoundRotateBoard   = "tick.mp3"
let kSoundSpinBoard     = "spin.mp3"
let kSoundCrash         = "explosion.mp3"
let kSoundGameOver      = "gameover.mp3"
let kSoundOk            = "woosh.mp3"
let kSoundVictory       = "tada.mp3"

// MARK: - Dimensions

// Board dimensions. Includes the wall.
let kCols = 15,
    kRows = 14

let kBaseStep = 12

// If kScale is 2, the game is scaled up by 2,
// otherwise kScale is 1.
// kStep is the step size in points.
// Both kScale and kStep are var instead of let
// because they can be reset if the user decides to
// toggle the size. See AppDelegate toggleSize(_:).
// They are only used from the main actor.
@MainActor var kScale: CGFloat = UserDefaults.standard.bool(forKey: kBigBoardKey) ? 2 : 1
@MainActor var kStep = kBaseStep * Int(kScale)

// MARK: - Game settings

// Each level has its own speed, high score and music.

enum SnkLevel: Int, CaseIterable {
    case slow = 1, medium, fast
    
    // Seconds per frame
    var secondsPerFrame: TimeInterval {
        switch self {
        case .slow:   0.140
        case .medium: 0.085
        case .fast:   0.045
        }
    }
    
    // NSUserDefaults key for the level's high score
    var hiScoreKey: String {
        switch self {
        case .slow:   "HiScoreSlow"
        case .medium: "HiScoreMedium"
        case .fast:   "HiScoreFast"
        }
    }
    
    // Music
    // 1: 8-bit Melody http://www.looperman.com/loops/detail/68575/8-bit-melody-by-kinggjmaytryx-free-156bpm-electro-sh-loop
    // 2: Bibo by https://soundcloud.com/lv-7
    // 3: Flight of the Bumblebee https://www.youtube.com/watch?v=wOFgh2IdnZI
    var song: String {
        switch self {
        case .slow:   "loop.mp3"
        case .medium: "bibo.mp3"
        case .fast:   "fotbb.mp3"
        }
    }
}

let kMaxScoreIncrement = 55

// Max directional keypresses buffered between frames
let kMaxBufferedDirections = 2

// Scores which trigger the board to animate
let kScoreSpin   = 800
let kScoreRotate = 720
let kScore3D     = 450
