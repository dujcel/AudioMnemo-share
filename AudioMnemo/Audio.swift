//
//  AudioManager.swift
//  SQLiteTest
//
//  Created by yong gu on 10/4/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import Foundation
import AVFoundation

struct Sound{
    var startTime: Double?
    var endTime: Double?
    var audioFile: String?
}

let audioOffsetTime = 0.0               //extend audio 0.05 seconds both before and after
class Audio{
    
    var player: AVAudioPlayer!
    var listPlayer: AVAudioPlayer!
    var timer:NSTimer!
    var audioFile:String!
    
    var timerDict: NSMutableDictionary!
    var soundsQueue: [Sound]!
    
    let timerInterval:Double=0.1        // audio labels gap should be greater than (timerInterval + audioOffsetTime)
    
    
    init(){
        soundsQueue=[Sound]()
    }
    
    func addSounds(sounds: [Sound], clear: Bool){
        if clear {
            clearSounds()
        }
        for sound in sounds {
            soundsQueue.append(sound)
        }
        if(timer == nil){
            processSounds()
        }else if(!timer.valid){
            processSounds()
        }
    }
    
    func clearSounds(){
        timer?.invalidate()
        player?.stop()
        soundsQueue.removeAll()
    }
    
    @objc func checkTime() {
        if let timerDic = timer.userInfo as? NSMutableDictionary {
            let endTime = timerDic["endTime"] as! Double
            if player.currentTime >= endTime {
                player.pause()
                timer.invalidate()
                processSounds()
            }
        }else{
            timer.invalidate()
            processSounds()
        }
    }
    
    
    private func processSounds(){
        if(soundsQueue.count <= 0){
            return
        }
        timer?.invalidate()
        let sound = soundsQueue.removeAtIndex(0)
        if(sound.startTime == nil || sound.endTime == nil )
        {
            return
        }
        playSound(sound.startTime!, endTime: sound.endTime!, fileName: sound.audioFile)
    }
    
    
    private func playSounds(startTime: [Double], endTime: [Double], fileName: [String?])
    {
        let count = fileName.count
        if(startTime.count != count || endTime.count != count){
            return
        }
        clearSounds()
        for var i:Int = 0; i < count; i++ {
            soundsQueue.append(Sound(startTime: startTime[i], endTime: endTime[i], audioFile: fileName[i]))
        }
        processSounds()
    }
    private func playSound(startTime: Double, endTime: Double, fileName: String?){
        if(startTime >= endTime){
            return
        }
        if(fileName == nil){
            timer.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(endTime - startTime, target: self, selector: "checkTime", userInfo: nil, repeats: false)
            return
        }
        if(fileName != audioFile || player == nil){
            player?.stop()
            audioFile = fileName!
            do {
                if let filePath = NSBundle.mainBundle().pathForResource(audioFile, ofType: "mp3") {
                    try player = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: filePath), fileTypeHint:nil)
                    player.prepareToPlay()
                }
                else{
                    return
                }
            }catch{
                print("\(audioFile) open failed")
            }
        }
        if(player.playing){
            player.pause()
        }
        timer?.invalidate()
        player.currentTime = startTime
        player.play()
        let timerDic:NSMutableDictionary = ["endTime": endTime]
        timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "checkTime", userInfo: timerDic, repeats: true)
    }

    func playScanList(speed: Float, delegate: AVAudioPlayerDelegate){
        listPlayer?.stop()
        do{
            let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
            try listPlayer = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: "\(dir)/Scan List"), fileTypeHint:nil)
            listPlayer.enableRate = true
            listPlayer.rate = speed
            listPlayer.delegate = delegate
            listPlayer.prepareToPlay()
            listPlayer.play()
        }catch{
            print("lisPlayer created failed")
        }
    }
    
        
    func concatList(times1: [Double], times2: [Double], files: [String], emptyTime: Double) -> AVMutableComposition{
        let composition = AVMutableComposition()
        let compoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        var currentTime = kCMTimeZero
        let interval = CMTimeMake((Int64)(emptyTime * 100), 100)
        do{
            for var i = 0; i < files.count; i++ {
                
                let t1 = (Int64)((times1[i] - audioOffsetTime) * 100)
                let t2 = (Int64)((times2[i] + audioOffsetTime) * 100)
                let range = CMTimeRange(start: CMTimeMake(t1,100), end: CMTimeMake(t2,100))
                let asset = AVURLAsset(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(files[i], ofType: "mp3")!), options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
                let track = asset.tracksWithMediaType(AVMediaTypeAudio).first!
                try compoTrack.insertTimeRange(range, ofTrack: track, atTime: currentTime)
                compoTrack.insertEmptyTimeRange(CMTimeRangeMake(currentTime, interval))
                let tmp = CMTimeAdd(currentTime, range.duration)
                currentTime = CMTimeAdd(tmp, interval)
            }
        }catch{}
        return composition
    }

}
