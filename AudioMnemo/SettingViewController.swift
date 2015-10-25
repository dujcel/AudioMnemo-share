//
//  SettingRootViewController.swift
//  SQLiteTest
//
//  Created by yong gu on 10/7/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController{
    
    @IBOutlet var autoSpeakSW: UISwitch!
    
    @IBOutlet var autoTransSpeakSW: UISwitch!
    
    @IBOutlet var autoWordDisplaySW: UISwitch!    
    
    @IBOutlet var autoTransDisplaySW: UISwitch!
    
    @IBOutlet var reverseSW: UISwitch!
    
    @IBOutlet var scanNumLabel: UILabel!
    
    
    
    var am: AudioMnemo!
    var db: DB!
    
//    @IBOutlet var tableOfRootView: UITableView!
//    let textCellIdentifier = "TextCell"
//    
//    let swiftBlogs = ["Ray Wenderlich", "NSHipster", "iOS Developer Tips", "Jameson Quave", "Natasha The Robot", "Coding Explorer", "That Thing In Swift", "Andrew Bancroft", "iAchieved.it", "Airspeed Velocity"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        am = (UIApplication.sharedApplication().delegate as! AppDelegate).am
        db = am.db
        autoSpeakSW.setOn(am.db.readConfig("scan_autoSpeak")! == 1, animated: false)
        autoTransSpeakSW.setOn(am.db.readConfig("scan_autoTransSpeak")! == 1, animated: false)
        autoWordDisplaySW.setOn(am.db.readConfig("scan_autoWordDisplay")! == 1, animated: false)
        autoTransDisplaySW.setOn(am.db.readConfig("scan_autoTransDisplay")! == 1, animated: false)
        reverseSW.setOn(am.db.readConfig("listen_reverse")! == 1, animated: false)
        
        self.navigationController?.navigationBar.translucent = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let scanNum = am.db.readConfig("scan_num")!
        scanNumLabel.text = "\(scanNum)"
        
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scanFilterSegue" {
            segue.destinationViewController.hidesBottomBarWhenPushed = true
            }
        }
//    }
    // MARK:  UITextFieldDelegate Methods
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 3
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
//    }
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Sec:\(section)"
//    }
    
    // 5.该方法是用来设置 TableView 每一行 Cell 的页尾内容
//    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return "我是页尾"
//    }
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell =  UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil)
//        
//        let row = indexPath.row
//        cell.textLabel?.text = swiftBlogs[row]
//        
//        
////        cell.accessoryType = .DetailDisclosureButton
//        
//        return cell
//    }
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        print("button pressed")
    }
    // MARK:  UITableViewDelegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
//        if indexPath.row == 0
//        {
//            print("Segue1")
//            self.performSegueWithIdentifier("Segue1", sender: self)
//        }
//        else if indexPath.row == 1
//        {
//            print("Segue2")
//            self.performSegueWithIdentifier("Segue2", sender: self)
//        }
//        else if indexPath.row == 2
//        {
//            print("Segue3")
//            self.performSegueWithIdentifier("Segue3", sender: self)
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if( segue.identifier == "listSelection"){
//            let helpView = segue.destinationViewController.view!
//            
//        }
//    }
    
    @IBAction func didSwitchAutoSpeak(sender: UISwitch) {
        if autoSpeakSW.on {
            am.db.updateConfig("scan_autoSpeak",with: 1)
        }else{
            am.db.updateConfig("scan_autoSpeak",with: 0)
        }
    }
    @IBAction func didSwitchAutoTransSpeak(sender: UISwitch) {
        if autoTransSpeakSW.on {
            am.db.updateConfig("scan_autoTransSpeak",with: 1)
        }else{
            am.db.updateConfig("scan_autoTransSpeak",with: 0)
        }
    }
    
    @IBAction func disSwitchAutoDisplayWord(sender: UISwitch) {
        if autoWordDisplaySW.on {
            am.db.updateConfig("scan_autoWordDisplay",with: 1)
        }else{
            am.db.updateConfig("scan_autoWordDisplay",with: 0)
        }
    }
    
    @IBAction func didSwitchAutoDisplayTrans(sender: UISwitch) {
        if autoTransDisplaySW.on {
            am.db.updateConfig("scan_autoTransDisplay", with: 1)
        }else{
            am.db.updateConfig("scan_autoTransDisplay", with: 0)
        }
    }
    
  
    @IBAction func intervalSet(sender: UITextField) {
        var interval:Int? = (Int)(sender.text!)
        if  interval != nil{
            am.db.updateConfig("listen_interval", with: interval!)
        }else{
            interval = am.db.readConfig("listen_interval")!
            sender.text = "\(interval)"
        }
        
    }
    
    @IBAction func didSwitchReverse(sender: UISwitch) {
        if reverseSW.on {
            am.db.updateConfig("listen_reverse", with: 1)
        }else{
            am.db.updateConfig("listen_reverse", with: 1)
        }
    }
    
}