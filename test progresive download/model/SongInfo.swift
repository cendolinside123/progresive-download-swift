//
//  SongInfo.swift
//  test progresive download
//
//  Created by Mac on 06/04/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
struct SongInfo {
    var namaLagu:String?
    var url:String?
    var artist:String?
}
extension SongInfo{
    init(_ nama:String,_ url:String,_ artist:String) {
        self.namaLagu = nama
        self.url = url
        self.artist = artist
    }
}
