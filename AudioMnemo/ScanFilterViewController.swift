//
//  ListSelectionViewController.swift
//  AudioMnemo
//
//  Created by yong gu on 10/10/15.
//  Copyright © 2015 Thu. All rights reserved.
//


import UIKit
import SQLite
import AVFoundation

class ScanFilterViewController: UITableViewController{
    
    var am: AudioMnemo!
    
    var levelPicker: UIPickerView!
    
    let pickerValues = ["0", "1", "2", "3", "4", "5"]
    
    var lists:[List]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        am = (UIApplication.sharedApplication().delegate as! AppDelegate).am
        lists = am.db.readLists()
    }
    
    override func viewWillDisappear(animated: Bool) {
        am.db.updateScanList(am.db.readConfig("scan_minLevel")!, maxLevel: am.db.readConfig("scan_maxLevel")!)
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
        
    }
   
     // UITextFieldDelegate Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }
        else if(section == 1){
            return lists.count
        }else{
            return 0
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "Filters"
        }else if section == 2{
            return "Lists"
        }else{
            return nil
        }
    }

    //    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    //        return "我是页尾"
    //    }
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            if(indexPath.section == 0){
                let cell =  tableView.dequeueReusableCellWithIdentifier("filterCell") as! PickerCell
                cell.textLabel?.enabled = false
                cell.vc = self
                if(indexPath.row == 0 ){
                    cell.level.text = "Min Level"
                    let minLevel = am.db.readConfig("scan_minLevel")!
                    cell.value.text = "\(minLevel)"
                    cell.stepper.value = (Double)(minLevel)
                }else{
                    cell.level.text = "Max Level"
                    let maxLevel = am.db.readConfig("scan_maxLevel")!
                    cell.value.text = "\(maxLevel)"
                    cell.stepper.value = (Double)(maxLevel)
                }
                return cell
            }else{
                let id :Int = indexPath.row
                let cell =  tableView.dequeueReusableCellWithIdentifier("twoLabelsCell") as! TwoLabelsCell
                cell.nameLabel.text = lists[id].name
                cell.valueLabel.text = "\(lists[id].wordsCount)"
                if lists[id].check == true {
                    cell.accessoryType = .Checkmark
                }else{
                    cell.accessoryType = .None
                }
                return cell
            }
        }
//    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
//        print("button pressed")
//    }
    // UITableViewDelegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == 1 {
            let row = indexPath.row
            if let cell = tableView.cellForRowAtIndexPath(indexPath)  {
                if cell.accessoryType == .Checkmark
                {
                    cell.accessoryType = .None
                    lists[indexPath.row].check = false
                    am.db.updateListCheck(lists[row].id, check: false)
                }
                else
                {
                    cell.accessoryType = .Checkmark
                    lists[indexPath.row].check = true
                    am.db.updateListCheck(lists[row].id, check: true)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
class TwoLabelsCell: UITableViewCell{
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var valueLabel: UILabel!
}

class PickerCell: UITableViewCell{
    
    
    @IBOutlet var level: UILabel!
    @IBOutlet var value: UITextField!
    @IBOutlet var stepper: UIStepper!
    
    var vc: ScanFilterViewController!
    
    @IBAction func didClick(sender: UIStepper) {
        value.text = "\((Int)(sender.value))"
        valueChanged(value)
    }
    
    @IBAction func valueChanged(sender: UITextField) {
        if let l = (Int)(value.text!) {
            if( level.text == "Min Level"){
                vc.am.db.updateConfig("scan_minLevel", with:l)
                print("minLevel is changed to \(l)")
            }else{
                vc.am.db.updateConfig("scan_maxLevel", with:l)
                print("maxLevel is changed to \(l)")
            }
        }
    }
}
