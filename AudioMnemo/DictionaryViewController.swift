//
//  ListSelectionViewController.swift
//  AudioMnemo
//
//  Created by yong gu on 10/10/15.
//  Copyright © 2015 Thu. All rights reserved.
//


import UIKit
import SQLite

class DictionaryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate{
    
    @IBOutlet var tableView: UITableView!
    var am: AudioMnemo!
    var wordsID: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        am = (UIApplication.sharedApplication().delegate as! AppDelegate).am
        wordsID = [Int]()
        
        tableView.dataSource = self
        tableView.delegate = self
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
        cell.textLabel?.text = am.db.readWordName(wordID)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "wordSegue" {
            let wordVC = segue.destinationViewController as! WordViewController
            let cellID = tableView.indexPathForCell(sender as! UITableViewCell)!.row
            wordVC.word = am.db.readWord(wordsID[cellID])
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        wordsID.removeAll()
        wordsID = am.db.searchWordsMatchPattern("\(searchText)%", exceptFor: nil)
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
//        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
