//
//  PlayerState.swift
//  test progresive download
//
//  Created by Mac on 06/04/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation

enum PlayerState: Int {
    case none = 0, playing, paused, stopped, esAdded, opening, ended, error, buffering, seeking
}
