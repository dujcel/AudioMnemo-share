//
//  SettingRootViewController.swift
//  SQLiteTest
//
//  Created by yong gu on 10/7/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit

class SettingRootViewController: UITableViewController{
    
    var naviController: UINavigationController!    
    
    @IBOutlet var autoVoiceSW: UISwitch!
    @IBOutlet var tableOfRootView: UITableView!
    let textCellIdentifier = "TextCell"
    
    let swiftBlogs = ["Ray Wenderlich", "NSHipster", "iOS Developer Tips", "Jameson Quave", "Natasha The Robot", "Coding Explorer", "That Thing In Swift", "Andrew Bancroft", "iAchieved.it", "Airspeed Velocity"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableOfRootView.delegate = self
        tableOfRootView.dataSource = self
        
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "Segue1" {
//            if let destination = segue.destinationViewController as? SettingS2R1ViewController {
//                if let blogIndex = tableOfRootView.indexPathForSelectedRow?.row {
////                    destination.blogName = swiftBlogs[blogIndex]
//                }
//            }
//        }
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
        tableOfRootView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let sec = indexPath.section
        let row = indexPath.row
        
        print("Sec:\(sec) Row:\(row) selected")
        
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
    func setAutoVoice(auto: Bool){
        autoVoiceSW?.setOn(auto,animated: true)
    }
    func isAutoVoice() -> Bool {
        if(autoVoiceSW != nil){
            return autoVoiceSW.on
        }else{
        return false;
        }
    }
    
}