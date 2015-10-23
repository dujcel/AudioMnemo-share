//
//  LinkViewController.swift
//  AudioMnemo
//
//  Created by yong gu on 10/20/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit

class LinkViewController: UITableViewController,UISearchBarDelegate, UISearchDisplayDelegate {
    var word: Word!
    var am: AudioMnemo!
    var words: [Word]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        am=(UIApplication.sharedApplication().delegate as! AppDelegate).am
        words = [Word]()
        for id in word.linksID {
            words.append(am.words[id])
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let wordID = indexPath.row
        let cell =  tableView.dequeueReusableCellWithIdentifier("searchWordCell")!
        cell.textLabel?.text = words[wordID].name
        if word.linksID.contains(words[wordID].id) {
        cell.accessoryType = .Checkmark
        }else{
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
            am.addlink(word.id, with: words[indexPath.row].id)
        }else{
            cell.accessoryType = .None
            am.cutLink(word.id, with: words[indexPath.row].id)
        }
    }
    
     func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        words.removeAll()
        for linkWord in am.words {
            if linkWord.name == nil {
                continue
            }
            if linkWord.name.hasPrefix(searchText) && linkWord.name != word.name {
                words.append(linkWord)
            }
        }
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
}
