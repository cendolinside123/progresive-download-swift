//
//  ViewController.swift
//  test progresive download
//
//  Created by Mac on 06/04/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

protocol MusicTimeFormatter {
    var timeFormat: String { get }
}

class ViewController: UIViewController {

    let setPlayer:MusicPlayer = MusicPlayer.sharedInstance.self
    
    var collectionOfSong = [SongInfo]()
    
    @IBOutlet weak var songProgress: UISlider!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var btnBackward: UIButton!
    @IBOutlet weak var progressTime: UILabel!
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var tblListSong: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setPlayer.updateSlider = { [weak self] (current,duration) in
            let progressValue = current / duration
            
            self?.progressTime.text = current.timeFormat
            
            self?.durationTime.text = duration.timeFormat
            self?.songProgress.setValue(progressValue, animated: true)
        }
        
        setPlayer.updateState = { [weak self] playerState in
            switch playerState{
            case .paused:
                self?.btnPlay.setTitle("play", for: .normal)
            case .buffering:
                self?.btnPlay.setTitle("pause", for: .normal)
            case .playing:
                self?.btnPlay.setTitle("pause", for: .normal)
            case .opening:
                self?.btnPlay.setTitle("pause", for: .normal)
            case .seeking:
                self?.btnPlay.setTitle("pause", for: .normal)
            case .esAdded:
                self?.btnPlay.setTitle("pause", for: .normal)
            case .none:
                self?.btnPlay.setTitle("play", for: .normal)
            case .ended:
                self?.btnPlay.setTitle("play", for: .normal)
            case .error:
                self?.btnPlay.setTitle("play", for: .normal)
            case .stopped:
                self?.btnPlay.setTitle("play", for: .normal)
            }
        }
        let initFileCreation = SetNewDir()
        initFileCreation.setFile(fileName: "track1.mp3", url: "\(Bundle.main.path(forResource: "track", ofType:"mp3")!)")
        initFileCreation.setFile(fileName: "track2.mp3", url: "\(Bundle.main.path(forResource: "track", ofType:"mp3")!)")
        
        collectionOfSong = [
            SongInfo("bensound-rumble", "https://cdn.fastlearner.media/bensound-rumble.mp3", "Unknow Artist"),SongInfo("____45_____", "https://p.scdn.co/mp3-preview/bf9bdd403c67fdbe06a582e7b292487c8cfd1f7e?cid=d8a5ed958d274c2e8ee717e6a4b0971d", "Bon Iver"),SongInfo("Track From File", initFileCreation.getFile(fileName: "track1.mp3").replacingOccurrences(of: "file://", with: "", options: .literal, range: nil), "Unknow Artist"),SongInfo("8 (circle)", "https://p.scdn.co/mp3-preview/081447adc23dad4f79ba4f1082615d1c56edf5e1?cid=d8a5ed958d274c2e8ee717e6a4b0971d", "Bon Iver"),SongInfo("Track From File 2", initFileCreation.getFile(fileName: "track2.mp3").replacingOccurrences(of: "file://", with: "", options: .literal, range: nil), "Unknow Artist")
        ]
        setPlayer.listOfSong = collectionOfSong
        
        tblListSong.register(UINib(nibName: "songCell", bundle: nil), forCellReuseIdentifier: "songCell")
        tblListSong.delegate = self
        tblListSong.dataSource = self
        
        songName.text = collectionOfSong[0].namaLagu
        songArtist.text = collectionOfSong[0].artist
        btnBackward.isEnabled = false
        tblListSong.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        
        setPlayer.indexListOfSonglistener = { [weak self] noIndex in
            self?.songName.text = self?.collectionOfSong[noIndex].namaLagu
            self?.songArtist.text = self?.collectionOfSong[noIndex].artist
            self?.tblListSong.selectRow(at: IndexPath(row: noIndex, section: 0), animated: false, scrollPosition: .none)
            if noIndex == 0{
                self?.btnBackward.isEnabled = false
                self?.btnForward.isEnabled = true
            }
            else if noIndex == (self?.collectionOfSong.count)! - 1{
                self?.btnBackward.isEnabled = true
                self?.btnForward.isEnabled = false
            }
            else{
                self?.btnBackward.isEnabled = true
                self?.btnForward.isEnabled = true
            }
        }
    }

    @IBAction func play_pause_action(_ sender: UIButton) {
        setPlayer.play()
    }
    
    @IBAction func forwardSong(_ sender: UIButton) {
        setPlayer.fowardQueue()
    }
    
    @IBAction func backwardSong(_ sender: UIButton) {
        setPlayer.backwardQueue()
    }
    
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionOfSong.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? songCell else{
            return UITableViewCell()
        }
        cell.setText(collectionOfSong[indexPath.row].namaLagu ?? "")
        return cell
    }
}

extension Float: MusicTimeFormatter {
    var timeFormat: String {
        let currentValue = self
        guard !currentValue.isNaN else {
            return "00:00"
        }
        
        let seconds = currentValue.truncatingRemainder(dividingBy: 60);
        let minutes = (currentValue / 60).truncatingRemainder(dividingBy: 60);
        return String(format: "%02d:%02d", Int(minutes), Int(seconds))
    }
    
}


