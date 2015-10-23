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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        am = (UIApplication.sharedApplication().delegate as! AppDelegate).am
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
        am.updateScanList()
    }
   
     // UITextFieldDelegate Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }else if section == 1{
            return 1
        }
        else if(section == 2){
            return am.lists.count - 1
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
                cell.vc = self
                if(indexPath.row == 0 ){
                    cell.level.text = "Min Level"
                    let minLevel = am.config["scan_minLevel"]!
                    cell.value.text = "\(minLevel)"
                    cell.stepper.value = (Double)(minLevel)
                }else{
                    cell.level.text = "Max Level"
                    let maxLevel = am.config["scan_maxLevel"]!
                    cell.value.text = "\(maxLevel)"
                    cell.stepper.value = (Double)(maxLevel)
                }
                return cell
            }else{
                let id :Int = indexPath.row + indexPath.section - 1
                let cell =  tableView.dequeueReusableCellWithIdentifier("listCell")!
                cell.textLabel!.text = am.lists[id].name
                
                if indexPath.section == 1 {
                    cell.detailTextLabel!.text = "\(am.lists[0].wordsCount)"
                }else{
                
                if am.lists[id].scanCheck == true {
                    cell.accessoryType = .Checkmark
                    cell.detailTextLabel!.text = "\(am.lists[id].scanCount)"
                }else{
                    cell.accessoryType = .None
                    cell.detailTextLabel!.text = ""
                }
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

        if indexPath.section == 2 {
            let id = indexPath.row + 1
            if let cell = tableView.cellForRowAtIndexPath(indexPath)  {
                if cell.accessoryType == .Checkmark
                {
                    am.lists[0].wordsCount -= am.lists[id].scanCount
                    am.lists[id].scanCheck = false
                    cell.accessoryType = .None
                    cell.detailTextLabel!.text = ""
                }
                else
                {
                    am.lists[0].wordsCount += am.lists[id].scanCount
                    am.lists[id].scanCheck = true
                    cell.accessoryType = .Checkmark
                    cell.detailTextLabel!.text = "\(am.lists[id].scanCount)"
                }
                tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.None)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateAggregates(){
        am.updateListsForLevels()
        tableView.reloadData()
    }
    
    
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
                vc.am.config["scan_minLevel"] = l
                print("minLevel is changed to \(l)")
            }else{
                vc.am.config["scan_maxLevel"] = l
                print("maxLevel is changed to \(l)")
            }
            vc.updateAggregates()
        }
    }
}
