//
//  FirstViewController.swift
//  SQLiteTest
//
//  Created by yong gu on 10/4/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController {
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet var contentText: UITextView!
    
    var db:DB!
    var audio:Audio!
    var word: Word!
    var wordRow:(String?,Double?,Double?,Double?,Double?,String?)
    var wordID:Int64=1
    var autoSpeak:Bool=true
    var am: AudioMnemo!
    var index: Int = 0
    var num: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        am=(UIApplication.sharedApplication().delegate as! AppDelegate).am
        db=am.db;
        audio = am.audio
        
        contentText.editable = false
        contentText.textAlignment = NSTextAlignment.Center
        contentText.selectable = false
    }
    
    override func viewWillAppear(animated: Bool) {
        updateView()
        self.navigationItem.rightBarButtonItem?.enabled = (word != nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func speakerButton(sender: UIButton) {
        if word == nil {
            return
        }
        let sound = Sound(startTime: word.audioTime1, endTime: word.audioTime2, audioFile: word.audioFile)
        audio.addSounds([sound], clear: true)
    }
    
    
    @IBAction func sepakerButton2(sender: UIButton) {
        if word == nil {
            return
        }
        let sound = Sound(startTime: word.audioTime3, endTime: word.audioTime4, audioFile: word.audioFile)
        audio.addSounds([sound], clear: true)
    }
    
    func nextWord() {
        am.scanNextWord()
        updateView()
    }
    
    func lastWord() {
        am.scanLastWord()
        updateView()
    }
    
    func updateView(){
        
        
        num = am.lists[0].wordsCount
        index = am.lists[0].scanCount
        
        if num > 0 && index >= 0 && index < num{
            let wordID = am.lists[0].wordsID[index]
            word = am.words[wordID]
            if am.config["scan_autoWordDisplay"]! == 1{
            wordLabel.text = word.name
            }else{
                wordLabel.text = "Tap me"
            }
            contentText.text = ""
        }else{
            word = nil
            wordLabel.text = ""
            contentText.text = "Empty list, Please add words to ScanList in Setting View"
        }
        self.navigationItem.title = "\(index + 1)/\(num)"
        
        if word == nil{
            return
        }
        for id in word.linksID {
        contentText.text.appendContentsOf("\(am.words[id].name)   ")
        }
        audio.clearSounds()
        if(am.config["scan_autoSpeak"] == 1){
            let sound1 = Sound(startTime: word.audioTime1, endTime: word.audioTime2, audioFile: word.audioFile)
            audio.addSounds([sound1], clear: false)
        }
        if(am.config["scan_autoTransSpeak"] == 1){
            let sound2 = Sound(startTime: word.audioTime3, endTime: word.audioTime4, audioFile: word.audioFile)
            audio.addSounds([sound2], clear: false)
        }
        
    }
    @IBAction func didSwipeRight(sender: UISwipeGestureRecognizer) {
        lastWord()
    }
    
    @IBAction func didSwipeLeft(sender: UISwipeGestureRecognizer) {
        nextWord()
    }
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        let loc=sender.locationInView(self.view)
        
        if wordLabel.frame.contains(loc) && word != nil{
            wordLabel.text = word.name
        }else{
            if(loc.x >= 160){
                if word != nil{
                    am.decLevel(word)
                }
                nextWord()
            }else{
                if word != nil {
                    am.incLevel(word)
                }
                nextWord()
            }
        }
    }

    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "linkSegue" {
            let linkVC = segue.destinationViewController as! LinkViewController
            linkVC.word = word
            linkVC.title = word.name
            let backItem:UIBarButtonItem = UIBarButtonItem()
            backItem.title = "Back"
            self.navigationItem.backBarButtonItem = backItem
        }
    }
}
