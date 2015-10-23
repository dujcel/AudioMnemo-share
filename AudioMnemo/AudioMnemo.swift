//
//  AudioWords.swift
//  SQLiteTest
//
//  Created by yong gu on 10/7/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit
import AVFoundation


class Word{
    var id: Int!
    var name: String!
    var phonogram: String!
    var translation: String!
    var audioTime1: Double!
    var audioTime2: Double!
    var audioTime3: Double!
    var audioTime4: Double!
    var audioFile: String!
    var level: Int = 0
    var linksID:Set<Int>!
    
    init(){
        linksID = Set<Int>()
    }
    
    func incLevel() -> Int{
        if level < 5 {
            level++
            return level
        }else{
            return -1
        }
    }
    func decLevel() -> Int{
        if level > 0{
            level--
            return level
        }else{
            return -1
        }
    }
}

class List{
    var id: Int!                     
    var name: String!
    var wordsCount: Int = 0
    var scanCheck: Bool = false
    var scanCount: Int = 0
    var wordsID: [Int]!
    init(){
            wordsID = [Int]()
    }
}

class AudioMnemo{
    
    //viewControllers
    
    var scanVCs : UINavigationController!
    var scanVC : ScanViewController!
    var listenVCs: UINavigationController!
    var listenVC : ListenViewController!
    var listVCs: UINavigationController!
    var settingVCs: UINavigationController!
    
    var settingVC0: SettingViewController!
    
    //models
    var db: DB!
    var audio: Audio!
    var config: [String: Int]!
    var lists: [List]!     // lists[0] is ScanList, which is stored in BookTable, but not in ListsTable
    var words: [Word]!     // words[0] is null
    
    
    
    
    init(mainVCs: [UIViewController]){
        scanVCs = mainVCs[0] as! UINavigationController
        scanVC = scanVCs.viewControllers[0] as! ScanViewController
        listenVCs = mainVCs[1] as! UINavigationController
        listenVC = listenVCs.viewControllers[0] as! ListenViewController
        listVCs = mainVCs[2] as! UINavigationController
        settingVCs  = mainVCs[3] as! UINavigationController
        settingVC0 = settingVCs.viewControllers[0] as! SettingViewController
        audio = Audio()
        
        db = DB(am: self)
        loadDB()
//        lists[1].scanCheck = true
//        updateListsForLevels()
//        updateScanList()
    }
    
    func exportAudioForList(comletion:() -> ()){
        let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
        let emptyTime = (Double)(config["listen_interval"]!)/1000.0
        let composition = composeScanList(config["listen_reverse"]! == 1, emptyTime: emptyTime)
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
        exporter.outputFileType = AVFileTypeAppleM4A
        exporter.outputURL = NSURL(fileURLWithPath:dir.stringByAppendingPathComponent("Scan List"))
        do{try NSFileManager.defaultManager().removeItemAtURL(exporter.outputURL!) }catch{}
        exporter.exportAsynchronouslyWithCompletionHandler(comletion)
    }

    
    func composeScanList(reverse: Bool, emptyTime: Double) -> AVComposition{
        var t1 = [Double]()
        var t2 = [Double]()
        var files = [String]()
        for id in lists[0].wordsID {
            if reverse {
                t1.append(words[id].audioTime3)
                t1.append(words[id].audioTime1)
                t2.append(words[id].audioTime4)
                t2.append(words[id].audioTime2)
            }else{
                t1.append(words[id].audioTime1)
                t1.append(words[id].audioTime3)
                t2.append(words[id].audioTime2)
                t2.append(words[id].audioTime4)
            }
                files.append(words[id].audioFile)
            files.append(words[id].audioFile)
        }
            return audio.concatList(t1, times2: t2, files: files, emptyTime: emptyTime)
    }
    
    
    
    
//    func createList(name: String){
//        let list = List()
//        list.wordsCount = 0
//        for list in lists {
//            if list.scanCheck && list.id != 0{
//                for wordID in list.wordsID {
//                    
//                    if words[wordID].level >= config["scan_minLevel"] && words[wordID].level <= config["scan_maxLevel"] {
//                        list.wordsID.append(wordID)
//                        list.wordsCount++
//                    }
//                }
//            }
//        }
//        list.scanCount = list.wordsCount
//        list.scanCheck = true
//        list.id = lists.count + 1
//        list.name = name
//        lists.append(list)
//    }
    
    
    
    
    func loadDB(){
        db.loadWords()
        db.loadBookAndLists()
        db.loadLevels()
        db.loadConfig()
        db.loadLinks()
    }
    
    func incLevel(word:Word){
        let level = word.incLevel()
        if level >= 0 {
            db.updateLevel(word.id, to: level)
        }
    }
    func decLevel(word:Word){
        let level = word.decLevel()
        if level >= 0 {
            db.updateLevel(word.id, to: level)
        }
    }
    func addlink(id1:Int, with id2:Int){
        words[id1].linksID.insert(id2)
        words[id2].linksID.insert(id1)
        db.addLink(id1, with: id2)
    }
    func cutLink(id1:Int, with id2:Int){
        words[id1].linksID.remove(id2)
        words[id2].linksID.remove(id1)
        db.cutLink(id1, with: id2)
    }
    
    func scanNextWord(){
        let index:Int = lists[0].scanCount
        if index < lists[0].wordsCount - 1 {
            lists[0].scanCount = index + 1
            db.updateScanList(scanCount: index + 1)
        }
    }
    
    func scanLastWord(){
        let index:Int = lists[0].scanCount
        if index > 0 {
            lists[0].scanCount = index - 1
            db.updateScanList(scanCount: index - 1)
        }
    }
//    func saveDB(){
//        db.saveConfig()
//        db.saveBookAndLists()
//        db.saveLevels()
//        db.saveLinks()
//    }
    
    func updateScanList(){        // update words in ScanList
        lists[0].wordsCount = 0
        lists[0].wordsID.removeAll()
        for list in lists {
            if list.scanCheck && list.id != 1{
                for wordID in list.wordsID {
                    
                    if words[wordID].level >= config["scan_minLevel"] && words[wordID].level <= config["scan_maxLevel"] {
                        lists[0].wordsID.append(wordID)
                        lists[0].wordsCount++
                    }
                }
            }
        }
        lists[0].scanCount = 0
        lists[0].scanCheck = false
        db.updateScanList()
        db.updateScanList(scanCount: 0)
        db.updateBook()
    }
    
    func updateListsForLevels(){   // for ScanList, only wordsCount is updated
        lists[0].wordsCount = 0
        for list in lists {
            if list.id == 1 {      //exclude ScanList
                continue
            }
            list.scanCount = 0
            for wordID in list.wordsID {
                if words[wordID].level >= config["scan_minLevel"] && words[wordID].level <= config["scan_maxLevel"] {
                    list.scanCount++
                }
            }
            if list.scanCheck {
            lists[0].wordsCount += list.scanCount
            }
        }
    }
}