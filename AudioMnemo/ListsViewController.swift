//
//  ListSelectionViewController.swift
//  AudioMnemo
//
//  Created by yong gu on 10/10/15.
//  Copyright © 2015 Thu. All rights reserved.
//


import UIKit
import SQLite

class ListsViewController: UITableViewController{
    
    var am: AudioMnemo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        am = (UIApplication.sharedApplication().delegate as! AppDelegate).am
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {

    }
   
     // UITextFieldDelegate Methods
        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
    
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return am.lists.count - 1
        }

//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Lists"
//    }
    
    //    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    //        return "我是页尾"
    //    }
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
                let listID :Int = indexPath.row + 1
                let cell =  tableView.dequeueReusableCellWithIdentifier("list")! 
                cell.textLabel?.text = am.lists[listID].name
                return cell
            }
//    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
//        print("button pressed")
//    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

            }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "wordsSegue" {
            segue.destinationViewController.hidesBottomBarWhenPushed = true
            let cell = sender as! UITableViewCell
            let id = tableView.indexPathForCell(cell)!.row + 1
            let listName = cell.textLabel?.text
            let vc = segue.destinationViewController as! WordsViewController
            vc.navigationItem.title = listName
            vc.list = am.lists[id]
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateAggregates(){

    }
    
    
}
