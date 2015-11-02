//
//  SecondViewController.swift
//  SQLiteTest
//
//  Created by yong gu on 10/4/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit
import AVFoundation

class ListenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var playBtn: UIButton!
    
    
    @IBOutlet var actIndicator: UIActivityIndicatorView!
    
    @IBOutlet var stopBtn: UIButton!
    
    @IBOutlet var speedBtn: UIButton!
    
    var am: AudioMnemo!
    var isPlaying:Bool = false
    var readyToPlay = false
    var speedArray = [Float](arrayLiteral: 0.75, 1, 1.25, 1.5, 2)
    var speedIndex:Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }catch{}
        
        am = (UIApplication.sharedApplication().delegate as! AppDelegate).am
        
        tableView.dataSource = self
        tableView.delegate = self
        
        actIndicator.hidden = true
        actIndicator.hidesWhenStopped = true
        
        speedIndex = am.db.readConfig("listen_speed")!
        
    }

    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
        speedBtn.setTitle("Speed: \(speedArray[speedIndex])", forState: UIControlState.Normal)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func didPlay(sender: UIButton) {
        if isPlaying {
            am.audio.listPlayer?.pause()
            isPlaying = false
            sender.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
        }else{
            if !readyToPlay {
                actIndicator.hidden = false
                actIndicator.startAnimating()
                playBtn.hidden = true
                stopBtn.hidden = true
                
                 dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                    self.am.exportAudioForList({
                    self.am.audio.playScanList(self.speedArray[self.speedIndex], delegate: self)
                    self.isPlaying = true
                    self.readyToPlay = true
                    dispatch_async(dispatch_get_main_queue(), {
                        self.actIndicator.stopAnimating()
                        self.playBtn.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
                        self.playBtn.hidden = false
                        self.stopBtn.hidden = false
                    })
                    })
                })
                
            }else{
                am.audio.listPlayer?.rate = speedArray[speedIndex]
                am.audio.listPlayer?.play()
                isPlaying = true
                playBtn.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
            }
        }
    }

    @IBAction func didStopBtnDown(sender: AnyObject) {
        stopBtn.imageView?.alpha = 0.5
    }
    
    @IBAction func didStopBtnUpOutside(sender: AnyObject) {
        stopBtn.imageView?.alpha = 1.0
    }
    @IBAction func didStop(sender: AnyObject) {
        stopBtn.imageView?.alpha = 1.0
            am.audio.listPlayer?.pause()
            isPlaying = false
            readyToPlay = false
            playBtn.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "speedSegue" {
           let vc = segue.destinationViewController as! SpeedViewController
            vc.listenVC = self
            let backItem:UIBarButtonItem = UIBarButtonItem()
            backItem.title = "Back"
            self.navigationItem.backBarButtonItem = backItem
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return am.db.readConfig("scan_num")!
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let word = am.db.readScanWord(sort:indexPath.row + 1)!
        let cell =  tableView.dequeueReusableCellWithIdentifier("listenWordCell")!
        cell.textLabel?.text = word.name
        cell.detailTextLabel?.text = "\(word.level)"
        return cell
    }
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        playBtn.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
    }
     
}

