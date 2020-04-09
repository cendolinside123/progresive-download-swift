//
//  MusicPlayer.swift
//  test progresive download
//
//  Created by Mac on 06/04/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import AVFoundation

class MusicPlayer:NSObject{
    static let sharedInstance = MusicPlayer()
    
    private var player: SuperpoweredBridge!
    
    private var mediaCommandCenter:MediaCommandCenter!
    
    var updateSlider : ((Float,Float) -> ())?
    
    var updateBuffer: ((Float,Float) -> ())?
    
    var updateState: ((PlayerState) -> ())?
    
    var indexListOfSonglistener: ((Int) -> ())?
    
    var listOfSong = [SongInfo]()
    
    private var progress: Float?
    
    var playerState: PlayerState = .none{
        didSet{
            if oldValue != playerState {
                print("Player state \(playerState)")
                didPlayerStateChange()
            }
        }
    }
    
    var currentListOfSongIndex:Int = 0{
        didSet{
            indexListOfSonglistener?(currentListOfSongIndex)
        }
    }
    
    var isPlayerReady:Bool = false
    
    override init() {
        super.init()
        initialPlayer()
        //setSession()
    }
    
    
    private func setSession(){
        do{
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .allowBluetooth)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch let error{
            print("sessio error cause : \(error)")
        }
    }
    
    private func initialPlayer(){
        player = SuperpoweredBridge()
        player.setTempFolder()
        player.delegate = self
        mediaCommandCenter = MediaCommandCenter()
        mediaCommandCenter.delegate = self
    }
    
    
    func prepareSong(){
        stop()
    }
    
    func stop(){
        player.stopSong()
    }
    
    func pause(){
        player.pauseSong()
    }
    
    func play(_ url:String){
        player.setSong(url)
        isPlayerReady = true
        player.playSong()
    }
    
    func resume(){
        player.playSong()
    }
    
    func play(){
        if playerState == .none ||
            playerState == .stopped ||
            playerState == .error
        {
            playSong(listOfSong[currentListOfSongIndex])
        } else if playerState == .paused {
            if isPlayerReady == true{
                resume()
            }
            else if isPlayerReady == false{
                playSong(listOfSong[currentListOfSongIndex])
            }
        } else if playerState == .ended {
            
            playSong(listOfSong[currentListOfSongIndex])
        } else {
            pause()
        }
    }
    
    func playSong(_ song:SongInfo){
        isPlayerReady = false
        stop()
        guard let url = song.url else{
            return
        }
        mediaCommandCenter.setMediaPlayerInfo(song: song)
        play(url)
    }
    
    func fowardQueue(){
        if currentListOfSongIndex == listOfSong.count - 1{
            return
        }
        currentListOfSongIndex = currentListOfSongIndex + 1
        playSong(listOfSong[currentListOfSongIndex])
    }
    
    func backwardQueue(){
        if currentListOfSongIndex == 0{
            return
        }
        
        currentListOfSongIndex = currentListOfSongIndex - 1
        
        playSong(listOfSong[currentListOfSongIndex])
    }
    
    fileprivate func checkIfCurrentSongShouldEnd() {
//        var musicProgress = self.musicProgress
//        guard let progress = musicProgress?.currentProgress,
//            let duration = musicProgress?.expectedDuration else {
//                return
//        }
//
//        guard duration > 0, Int(progress) >= Int(duration * 0.99)  else {
//            return
//        }
        
        guard let songProgress = self.progress else{
            return
        }
        
        let progress = songProgress
        let duration = player.getDurationS()
        
        guard duration > 0, Int(progress) >= Int(Double(duration) * 0.99)  else{
            return
        }
        
        playerState = .ended
    }
    
    fileprivate func didPlayerStateChange() {
            switch playerState {
            case .buffering:
                 break
            case .ended:
                fowardQueue()
                //didPlaybackEnd()
            case .error:
                break
                //stop()
            case .opening:
                break
            case .esAdded:
                break
            case .paused:
                checkIfCurrentSongShouldEnd()
                break
            case .stopped:
                break
            case .playing:
                break
            case .none:
                break
            case .seeking:
                break
            }
            updateState?(playerState)
//            DispatchQueue.main.async {
//                self.playerDelegate?.didPlayerStateChange(state: self.playerState)
//            }
            
        }
}

extension MusicPlayer:SuperpowerDelegate{
    func getTimeRemaining(_ time: UInt32) {
        print(time)
        
        self.progress = Float(player.getPositionSecond())
        guard let progressSong = self.progress else{
            return
        }
        updateSlider?(progressSong,Float(player.getDurationS()))
        updateBuffer?(player.getBufferedStart_inPercent(),player.getBufferedEnd_inPercent())
        mediaCommandCenter.updatePlayback(currentProgress: Float(player.getPositionSecond()), expectedDuration: Float(player.getDurationS()))
    }
    
    func getMusicPlayerEvent(_ state: eventPlayer) {
        switch state {
        case .PlayerEvent_Opening:
            playerState = .opening
        case .PlayerEvent_Opened:
            playerState = .playing
        case .PlayerEvent_OpenFailed:
            break
        case .PlayerEvent_None:
            break
        case .PlayerEvent_ConnectionLost:
            break
        case .PlayerEvent_ProgressiveDownloadFinished:
            break
        default:
            break
        }
    }
    
    func getPlayerState(_ state: SuperPoweredStatePlayer) {
        switch state {
        case .none:
            break
        case .playing:
            playerState = .playing
        case .paused:
            playerState = .paused
        case .stopped:
            playerState = .stopped
        case .buffering:
            playerState = .buffering
        default:
            break
        }
    }
    
    
}
extension MusicPlayer:MediaCommandCenterDelegate{
    func didNextTrack() {
        fowardQueue()
    }
    
    func didPreviousTrack() {
        backwardQueue()
    }
    
    func didPause() {
        pause()
    }
    
    func didPlay() {
        resume()
    }
    
    func didTogglePlayPause() {
        if player.isPlaying(){
            pause()
        } else {
            resume()
        }
    }
    
    
}
