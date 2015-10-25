//
//  WordsViewController.swift
//  AudioMnemo
//
//  Created by yong gu on 10/14/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit

class WordViewController: UIViewController{
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var contentText: UITextView!
    var am: AudioMnemo!
    var word:Word!
    var audio:Audio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        am = (UIApplication.sharedApplication().delegate as! AppDelegate).am
        audio = am.audio
        if word != nil{
            if am.db.readConfig("scan_autoWordDisplay")! == 1{
                nameLabel.text = word.name
            }else{
                nameLabel.text = "Tap me"
            }
            contentText.text = ""
            for id in word.linksID {
                contentText.text.appendContentsOf("\(am.db.readWordName(id)!)   ")
            }
            audio.clearSounds()
            if(am.db.readConfig("scan_autoSpeak")! == 1){
                let sound1 = Sound(startTime: word.audioTime1, endTime: word.audioTime2, audioFile: word.audioFile)
                audio.addSounds([sound1], clear: false)
            }
            if(am.db.readConfig("scan_autoTransSpeak")! == 1){
                let sound2 = Sound(startTime: word.audioTime3, endTime: word.audioTime4, audioFile: word.audioFile)
                audio.addSounds([sound2], clear: false)
            }
        }
    }
    
    @IBAction func didSpeak(sender: UIButton) {
        if word == nil {
            return
        }
        let sound = Sound(startTime: word.audioTime1, endTime: word.audioTime2, audioFile: word.audioFile)
        audio.addSounds([sound], clear: true)
    }
    
    @IBAction func didSpeakTrans(sender: UIButton) {
        if word == nil {
            return
        }
        let sound = Sound(startTime: word.audioTime3, endTime: word.audioTime4, audioFile: word.audioFile)
        audio.addSounds([sound], clear: true)
    }
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
