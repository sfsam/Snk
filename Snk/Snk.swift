
//  Created by Sanjay Madan on May 26, 2015
//  Copyright (c) 2015 mowglii.com

import Cocoa

// MARK: NSUserDefaults keys

let kHiScoreSlowKey   = "HiScoreSlow"
let kHiScoreMediumKey = "HiScoreMedium"
let kHiScoreFastKey   = "HiScoreFast"
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

// MARK: - Music

// 1: 8-bit Melody http://www.looperman.com/loops/detail/68575/8-bit-melody-by-kinggjmaytryx-free-156bpm-electro-sh-loop
// 2: Bibo by https://soundcloud.com/lv-7
// 3: Flight of the Bumblebee https://www.youtube.com/watch?v=wOFgh2IdnZI
let kSong1 = "loop.aiff"
let kSong2 = "bibo.mp3"
let kSong3 = "fotbb.mp3"

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
// toggle the size. See AppDelegate toggleBoardSize().
var kScale: CGFloat = UserDefaults.standard.bool(forKey: kBigBoardKey) ? 2 : 1
var kStep = kBaseStep * Int(kScale)

// MARK: - Game settings

enum SnkLevel: Int {
    case slow = 1, medium, fast
}

let kMaxScoreIncrement = 55

// Seconds per frame
let kLevel1SecPerFrame = 0.140
let kLevel2SecPerFrame = 0.085
let kLevel3SecPerFrame = 0.045

// Scores which trigger the board to animate
let kScoreSpin   = 800
let kScoreRotate = 720
let kScore3D     = 450
