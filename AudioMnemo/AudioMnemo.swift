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
    var check: Bool = false
}

let MAXLEVEL:Int = 5
let MINLEVEL:Int = 0

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
//    var config: [String: Int]!
    var scanWords:[(Int,Int)]!    // (wordID, level)

    
    
    
    
    init(mainVCs: [UIViewController]){
        scanVCs = mainVCs[0] as! UINavigationController
        scanVC = scanVCs.viewControllers[0] as! ScanViewController
        listenVCs = mainVCs[1] as! UINavigationController
        listenVC = listenVCs.viewControllers[0] as! ListenViewController
        listVCs = mainVCs[2] as! UINavigationController
        settingVCs  = mainVCs[3] as! UINavigationController
        settingVC0 = settingVCs.viewControllers[0] as! SettingViewController
        audio = Audio()
        scanWords = [(Int, Int)]()
        db = DB(am: self,mode: 0)
    }
    
    func exportAudioForList(comletion:() -> ()){
        let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
        let emptyTime = (Double)(db.readConfig("listen_interval")!)/1000.0
        let composition = composeScanList(emptyTime)
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
        exporter.outputFileType = AVFileTypeAppleM4A
        exporter.outputURL = NSURL(fileURLWithPath:dir.stringByAppendingPathComponent("Scan List"))
        do{try NSFileManager.defaultManager().removeItemAtURL(exporter.outputURL!) }catch{}
        exporter.exportAsynchronouslyWithCompletionHandler(comletion)
    }

    
    func composeScanList(emptyTime:Double) -> AVMutableComposition{
        let (t1,t2,files) = db.getScanListAudio()
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
    

    
    func incLevel(word:Word){
        if word.level < MAXLEVEL {
            word.level++
            db.updateLevel(word.id, to: word.level)
        }
    }
    func decLevel(word:Word){
        if word.level > MINLEVEL {
            word.level--
            db.updateLevel(word.id, to: word.level)
        }
    }
    
}