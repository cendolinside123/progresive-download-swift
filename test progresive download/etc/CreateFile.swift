//
//  CreateFile.swift
//  test progresive download
//
//  Created by Mac on 06/04/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
struct directory{
    static var main: URL {
        let urlString = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Gapless")
            .relativePath
        return URL(fileURLWithPath: urlString)
    }
    
    static var stream: URL {
        return main.appendingPathComponent("Stream")
    }
    
}

struct SetNewDir{
    
    func setFile(fileName:String,url:String){
        let fileManager = FileManager.default
        let streamDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Gap-less").appendingPathComponent("Stream")
        let streamingFilePath = streamDirectory.appendingPathComponent(fileName)
        if !fileManager.fileExists(atPath: streamDirectory.absoluteString){
            do{
                try fileManager.createDirectory(at: streamDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch let error{
                print("error create folder : \(error)")
            }
        }
        let urlFile = URL(fileURLWithPath: url)
        print("is \(url) exist at path \(fileManager.fileExists(atPath: url))\n")
        print("is \(streamDirectory) exist at path \(fileManager.fileExists(atPath: streamDirectory.absoluteString))\n")
        print("url destination : \(streamingFilePath)")
        
        
        //let newFileUrl = URL(fileURLWithPath: streamingFilePath)
        
        do{
            //try fileManager.moveItem(at: urlFile, to: streamingFilePath)
            try fileManager.copyItem(at: urlFile, to: streamingFilePath)
        } catch let error {
            print("error create file : \(error)")
        }
        
        print("is \(streamingFilePath) exist at path \(fileManager.fileExists(atPath: streamingFilePath.absoluteString))\n")
    }
    
    func getFile(fileName:String) -> String{
        let fileManager = FileManager.default
        let streamDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Gap-less").appendingPathComponent("Stream")
        let streamingFilePath = streamDirectory.appendingPathComponent(fileName)
        return streamingFilePath.absoluteString
    }
}
