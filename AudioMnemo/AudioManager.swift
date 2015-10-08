//
//  AudioManager.swift
//  SQLiteTest
//
//  Created by yong gu on 10/4/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import Foundation
import AVFoundation

class AudioManager{
    
    var player:AVAudioPlayer!
    var timer:NSTimer!
    var audioFile:String!
    let timerInterval:Double=0.5
    
    init(file:String){
        audioFile=file;
        do {
            try player = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: NSBundle.mainBundle().pathForResource(audioFile, ofType: "mp3")!), fileTypeHint:nil)
            player.prepareToPlay()
            
        }catch{
            print("\(audioFile).mp3 open failed")
        }
    }
    @objc func checkTime() {
        if let timerDic = timer.userInfo as? NSMutableDictionary {
            if player.currentTime >= timerDic["endTime"] as? Double{
                player.pause()
                timer.invalidate()
            }
        }
    }
    func playTime(startTime: Double, endTime: Double, file: String?){
        if(file != nil){
            if(file != audioFile){
                player?.stop()
                audioFile=file
                do {
                    try player = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: NSBundle.mainBundle().pathForResource(audioFile, ofType: "mp3")!), fileTypeHint:nil)
                    player.prepareToPlay()
                    
                }catch{
                    print("\(audioFile).mp3 open failed")
                }
            }
        }
        if(player==nil){
            print("player doesn't exist")
            return
        }
        if(player.playing){
            player.pause()
        }
        if(timer != nil){
            if(timer.valid){
                timer.invalidate()
            }
        }
        player.currentTime=startTime;
        player.play()
        
        let timerDic:NSMutableDictionary = ["endTime": endTime]
        timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "checkTime", userInfo: timerDic, repeats: true)
    }
    
}
