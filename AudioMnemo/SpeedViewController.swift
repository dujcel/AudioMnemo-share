//
//  SpeedViewController.swift
//  AudioMnemo
//
//  Created by yong gu on 10/23/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit

class SpeedViewController: UITableViewController{
    var listenVC: ListenViewController!
    override func viewDidLoad() {

    }

    override func viewDidAppear(animated: Bool) {
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: listenVC.speedIndex, inSection: 0))?.accessoryType = .Checkmark
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.cellForRowAtIndexPath(indexPath)!
//        if indexPath.row == listenVC.speedIndex {
//        cell.accessoryType = .Checkmark
//        }
//        return cell
//    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: listenVC.speedIndex, inSection: 0))?.accessoryType = .None
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        listenVC.speedIndex = indexPath.row
        listenVC.am.db.updateConfig("listen_speed", with: indexPath.row)
        
    }
}
