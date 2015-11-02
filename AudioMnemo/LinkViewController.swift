//
//  LinkViewController.swift
//  AudioMnemo
//
//  Created by yong gu on 10/20/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit

class LinkViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate {
    
    
    
    @IBOutlet var tableView: UITableView!
    
    var word: Word!
    var am: AudioMnemo!
    var wordsID: [Int]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        am=(UIApplication.sharedApplication().delegate as! AppDelegate).am
        wordsID = Array(word.linksID)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsID.count
    }
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let wordID = wordsID[indexPath.row]
        let cell =  tableView.dequeueReusableCellWithIdentifier("searchWordCell")!
        cell.textLabel?.text = am.db.readWord(wordID)?.name
        if word.linksID.contains(wordID) {
            cell.accessoryType = .Checkmark
        }else{
            cell.accessoryType = .None
        }
        return cell
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
            word.linksID.insert(wordsID[indexPath.row])
            am.db.addLink(word.id, with: wordsID[indexPath.row])
        }else{
            cell.accessoryType = .None
            word.linksID.remove(wordsID[indexPath.row])
            am.db.cutLink(word.id, with: wordsID[indexPath.row])
        }
    }
    
     func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        wordsID.removeAll()
        wordsID = am.db.searchWordsMatchPattern("\(searchText)%", exceptFor: word.name)
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
//        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
}
