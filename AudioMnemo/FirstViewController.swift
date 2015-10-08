//
//  FirstViewController.swift
//  SQLiteTest
//
//  Created by yong gu on 10/4/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit
import AVFoundation

class FirstViewController: UIViewController {

    
    @IBOutlet weak var wordLabel: UILabel!
    
    
    var db:DB!
    var audio:AudioManager!
    var name:String!
    var t1:Double!
    var t2:Double!
    var t3:Double!
    var t4:Double!
    var wordRow:(String?,Double?,Double?,Double?,Double?)
    var wordID:Int64=1
    var autoSpeak:Bool=true
    let myDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        db=DB()
        
        audio = AudioManager(file: "WordList32")
        
//        let _ = DBImporter()
        wordRow=db.readData(wordID)
        name=wordRow.0
        t1=wordRow.1
        t2=wordRow.2
        t3=wordRow.3
        t4=wordRow.4
        
        wordLabel.text=name
        
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func speakerButton(sender: UIButton) {
        if(wordRow.1 == nil || wordRow.2 == nil){
            return
        }
        audio.playTime(wordRow.1!, endTime: wordRow.2!, file: nil);
        
    }
    
    func nextWord() {
        wordID++
        let row=db.readData(wordID)
        if(row.0 != nil){
            wordRow=row
        }else
        {
            wordID--
        }
        name=wordRow.0
        t1=wordRow.1
        t2=wordRow.2
        t3=wordRow.3
        t4=wordRow.4
        updateView()
    }
 
    func lastWord() {
        wordID--
        let row=db.readData(wordID)
        if(row.0 != nil)
        {
            wordRow=row
        }else{
            wordID++
        }
        print("lastWord: wordID=\(wordID)")
        name=wordRow.0
        t1=wordRow.1
        t2=wordRow.2
        t3=wordRow.3
        t4=wordRow.4
        updateView()
    }
    
    func updateView(){
        wordLabel.text=wordRow.0;
        autoSpeak=myDelegate.audioWords.settingRootVC.isAutoVoice()
        if(autoSpeak && wordRow.1 != nil && wordRow.2 != nil){
            audio.playTime(wordRow.1!,endTime:wordRow.2!,file:nil)
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
        if(loc.x>=160){
            nextWord()
        }else{
            lastWord()
        }
    }
}

