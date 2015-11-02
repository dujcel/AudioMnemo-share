//
//  ImportToDB.swift
//  SQLiteTest
//
//  Created by yong gu on 10/5/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import Foundation
import SQLite

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}
extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}


class DB{
    
    var am: AudioMnemo!
    
    var dict:Connection!         //dictionary db
    var db:Connection!        //main db
    
    //Tables
    let DictTable = Table("dict")
    let ListTable = Table("list")
    let WordInfoTable = Table("word_info")
    let LinkTable = Table("link")
    let ConfigTable = Table("config")
    
    let ScanListTable = Table("scan_list")
    //    let ListenTable = Table("listen_list")
    
    
    
    //Dict
    let wordID_c = Expression<Int>("word_id")
    let wordName_c = Expression<String>("word_name")
    let phono_c = Expression<String>("phonogram")
    let trans_c = Expression<String>("translation")
    let t1_c = Expression<Double>("audio_time1")   //start time of word (seconds)
    let t2_c = Expression<Double>("audio_time2")   //end time of word
    let t3_c = Expression<Double>("audio_time3")   //start time of translation
    let t4_c = Expression<Double>("audio_time4")   //end time of translation
    let audioFile_c = Expression<String>("audio_file")
    
    //List
    let listID_c = Expression<Int>("list_id")
    let listName_c = Expression<String>("list_name")
    let wordsCount_c = Expression<Int>("words_count")
    let check_c = Expression<Bool>("check")
    
    
    //WordInfo: wordID_c   listID_c
    let level_c = Expression<Int>("level")
    
    //LinkTable
    let linkID_c = Expression<Int>("link_id")
    let linkWordID_c = Expression<Int>("link_word_id")
    
    //ConfigTable
    let key_c = Expression<String>("key")
    let value_c = Expression<Int>("value")
    
    //ScanListTable
    let scanID_c = Expression<Int>("scan_id")
    let sort_c = Expression<Int>("sort")
    
    //id counter
    var wordCount: Int = 0   //for DictTable
    var listCount: Int = 0   //for ListTable
    
    
    let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
    
    init(am: AudioMnemo, mode:Int){ // 0: distribute   1: import db
        self.am = am
        var dictPath:String!
        let dbPath:String = "\(dir)/db.sqlite3"
        
        if mode == 0 {
            dictPath = NSBundle.mainBundle().pathForResource("Dict", ofType: "sqlite3")!
            let originalDBPath = NSBundle.mainBundle().pathForResource("db", ofType: "sqlite3")!
            
            let filemgr = NSFileManager.defaultManager()
            if !filemgr.fileExistsAtPath(dbPath){
            do{
                try filemgr.copyItemAtPath(originalDBPath, toPath: dbPath)
                print("copy success")
            }
            catch{
                print("Copy failed")
            }
            }
            
        }else if mode == 1 {
            dictPath = "\(dir)/Dict.sqlite3"
        }
        do {
            dict = try Connection(dictPath)   //create dababase if not exist
            db = try Connection(dbPath)
            if mode == 1 {
                initTables()
                let count = updateDBWithFiles()
                print("Fill in database with \(count) files")
            }
        } catch {
            print("database connection failed: \(error)")
        }
    }
    
    func searchWordsMatchPattern(pattern:String, exceptFor exceptionWordName:String?) -> [Int]{
        var wordsID = [Int]()
        for word_row in dict.prepare(DictTable.filter(wordName_c.like(pattern))){
            if word_row[wordName_c] != exceptionWordName{
                wordsID.append(word_row[wordID_c])
            }
        }
        return wordsID
    }
    
    func getScanListAudio() -> ([Double],[Double],[String]){
        var t1 = [Double]()
        var t2 = [Double]()
        var files = [String]()
        
        let reverse = (readConfig("listen_reverse")! == 1)
        for row in db.prepare(ScanListTable.order(sort_c)){
            if let word = readWord(row[wordID_c]) {
                if reverse {
                    t1.append(word.audioTime3)
                    t1.append(word.audioTime1)
                    t2.append(word.audioTime4)
                    t2.append(word.audioTime2)
                }else{
                    t1.append(word.audioTime1)
                    t1.append(word.audioTime3)
                    t2.append(word.audioTime2)
                    t2.append(word.audioTime4)
                }
                files.append(word.audioFile)
                files.append(word.audioFile)
            }
        }
        return (t1,t2,files)
    }
    
    func readScanWord(sort id:Int) ->Word?{
        if let scan_row = db.pluck(ScanListTable.filter(sort_c == id)){
            let word = readWord(scan_row[wordID_c])
            word?.level = scan_row[level_c]
            return word
        }else{
            return nil
        }
    }
    func readScanWord(scanID id:Int) ->Word?{
        if let scan_row = db.pluck(ScanListTable.filter(scanID_c == id)){
            let word = readWord(scan_row[wordID_c])
            word?.level = scan_row[level_c]
            return word
        }else{
            return nil
        }
    }
    
    //    func readWordName(wordID:Int) -> String?{
    //        if let word_r = dict.pluck(DictTable.filter(wordID_c == wordID)) {
    //            return word_r[wordName_c]
    //        }else{
    //            return nil
    //        }
    //    }
    
    func readWord(wordID:Int) -> Word?{
        let word = Word()
        if let word_r = dict.pluck(DictTable.filter(wordID_c == wordID)) {
            
            word.id = word_r[wordID_c]
            word.name = word_r[wordName_c]
            word.phonogram = word_r[phono_c]
            word.audioFile = word_r[audioFile_c]
            word.audioTime1 = word_r[t1_c]
            word.audioTime2 = word_r[t2_c]
            word.audioTime3 = word_r[t3_c]
            word.audioTime4 = word_r[t4_c]
            word.linksID = readLinks(wordID)
            return word
        }else{
            return nil
        }
    }
    
    func updateScanList(minLevel:Int, maxLevel:Int, shuffle: Bool){
        
        let query = WordInfoTable.filter(level_c >= minLevel && level_c <= maxLevel).join(ListTable.filter(check_c == true), on: ListTable[listID_c] == WordInfoTable[listID_c]).select(WordInfoTable[wordID_c], level_c.max).group(WordInfoTable[wordID_c])
        
        do {
            try db.transaction{
                try self.db.run(self.ScanListTable.delete())
                var i:Int = 0
                for row in self.db.prepare(query){
                    try self.db.run(self.ScanListTable.insert(or:.Abort, self.wordID_c <- row[self.wordID_c], self.level_c <- row[self.level_c.max]!, self.sort_c <- ++i))
                }
                if shuffle {
                    let num = self.db.scalar(self.ScanListTable.count)
                    let sort = Array(1.stride(through: num, by: 1)).shuffle()
                    for i = 1; i <= num; i++ {
                        try self.db.run(self.ScanListTable.filter(self.scanID_c == i).update(self.sort_c <- sort[i-1]))
                    }
                }
            }
            
            
        } catch{
            print("update ScanList error")
        }
        
        
        updateConfig("scan_index", with: 1)
        updateConfig("scan_num", with: db.scalar(ScanListTable.count))
    }
    
    func readLists() -> [List]{
        var lists = [List]()
        for list_row in db.prepare(ListTable){
            let list = List()
            list.id = list_row[listID_c]
            list.name = list_row[listName_c]
            list.check = list_row[check_c]
            list.wordsCount = list_row[wordsCount_c]
            lists.append(list)
        }
        return lists
    }
    
    func updateListCheck(listID:Int, check:Bool){
        do{
            try db.run(ListTable.filter(listID_c == listID).update(check_c <- check))
        }catch{
            print("update list check error")
        }
    }
    
    func readLinks(wordID:Int) -> Set<Int>{
        var linkWordIDs = Set<Int>()
        for link_row in db.prepare(LinkTable.filter(linkWordID_c == wordID)){
            linkWordIDs.insert(link_row[wordID_c])
        }
        for link_row in db.prepare(LinkTable.filter(wordID_c == wordID)){
            linkWordIDs.insert(link_row[linkWordID_c])
        }
        return linkWordIDs
    }
    
    func addLink(id1:Int, with id2:Int){
        do{
            if id1 < id2 {
                try db.run(LinkTable.insert(or: .Abort, wordID_c <- id1, linkWordID_c <- id2))
            }else{
                try db.run(LinkTable.insert(or: .Abort, wordID_c <- id2, linkWordID_c <- id1))
            }
        }catch{
            print(" link \(id1) and \(id2) error")
        }
    }
    
    func cutLink(id1:Int, with id2:Int){
        do{
            if id1 < id2 {
                try db.run(LinkTable.filter(wordID_c == id1 && linkWordID_c == id2).delete())
            }else{
                try db.run(LinkTable.filter(wordID_c == id2 && linkWordID_c == id1).delete())
            }
        }catch{
            print("cut link \(id1) and \(id2) error")
        }
    }
    
    func readLevel(wordID:Int) -> Int{
        if let level_row = db.pluck(WordInfoTable.filter(wordID_c == wordID)){
            return level_row[level_c]
        }else{
            return 0
        }
    }
    
    func updateLevel(wordID:Int, to level:Int) -> Bool{
        do{
            if level >= MINLEVEL && level <= MAXLEVEL{
                try db.run(WordInfoTable.filter(wordID_c == wordID).update(level_c <- level))
            }
        }catch{
            print("update \(wordID) level to \(level) error")
            return false
        }
        return true
    }
    
    
    
    func readConfig(key:String) -> Int?{
        if let config_row = db.pluck(ConfigTable.filter(key_c == key)){
            return config_row[value_c]
        }else{
            return nil
        }
    }
    func updateConfig(key: String, with value: Int) -> Bool{
        do{
            try db.run(ConfigTable.filter(key_c == key).update(value_c <- value))
        }catch{
            print("update config[\(key)] error")
            return false
        }
        return true
    }
    
    
    
    
    private func updateDBWithFiles() -> Int{
        var count:Int = 0
        let urls = NSBundle.mainBundle().URLsForResourcesWithExtension("txt", subdirectory: nil)!
        var fileName: String!
        for url in urls {
            fileName = url.URLByDeletingPathExtension?.lastPathComponent
            if fileName != nil {
                let rows = db.scalar(ListTable.filter(listName_c == fileName).count)
                if rows == 0 {
                    updateDBWithFile(fileName, audioFileName: fileName)
                    count++
                }
            }
        }
        return count
    }
    private func updateDBWithFile(textFileName: String, audioFileName: String){
        
        print("update db with file \(textFileName)")
        
        let s1 = NSCharacterSet.newlineCharacterSet()
        let s2 = NSCharacterSet.whitespaceCharacterSet()
        var t1:Double = 0.0
        var t2:Double = 0.0
        var t3:Double = 0.0
        var t4:Double = 0.0
        var wordName:String = String()
        var trans:String = String()
        let phono:String = "[]"
        var i:Int=0
        var num:Int=0
        var wordsID = [Int]()
        
        do {
            let textPath = NSBundle.mainBundle().pathForResource(textFileName, ofType:"txt")!
            let data = try NSString(contentsOfFile: textPath, encoding: NSUTF8StringEncoding).stringByTrimmingCharactersInSet(s1)
            let words = data.componentsSeparatedByCharactersInSet(s1)
            listCount++
            try db.run(ListTable.insert(or: .Abort, listID_c <- listCount, listName_c <- textFileName, wordsCount_c <- num, check_c <- false))
            try dict.transaction{
                while(i < words.count){
                    let word = words[i].stringByTrimmingCharactersInSet(s2).componentsSeparatedByCharactersInSet(s2)
                    if word.count != 6 {
                        continue
                    }
                    wordName = word[0]
                    t1=(word[1] as NSString).doubleValue
                    t2=(word[2] as NSString).doubleValue
                    trans = word[3]
                    t3=(word[4] as NSString).doubleValue
                    t4=(word[5] as NSString).doubleValue
                    i++
                    num++
                    self.wordCount++
                    
                    try self.dict.run(self.DictTable.insert(or: .Abort, self.wordID_c <- self.wordCount, self.wordName_c <- wordName, self.phono_c <- phono, self.trans_c <- trans, self.t1_c <- t1, self.t2_c <- t2, self.t3_c <- t3, self.t4_c <- t4, self.audioFile_c <- audioFileName ))
                    wordsID.append(self.wordCount)
                }
            }
            try db.run(ListTable.filter(listID_c == listCount).update(wordsCount_c <- num))
        }catch{
            print("update DictTable and ListTable for \(textFileName) error")
        }
        do{
            try db.transaction{
                for id in wordsID {
                    try self.db.run(self.WordInfoTable.insert(or: .Abort, self.wordID_c <- id, self.listID_c <- self.listCount, self.level_c <- 0))
                }
            }
            
        }
        catch {
            print("update WordsInfoTable for \(textFileName) error")
        }
        
    }
    
    private func initTables(){
        createTableDict()
        createTableList()
        createTableWordInfo()
        createTableConfig()
        createTableLink()
        createTableScanList()
        do{
            try db.transaction{
                let db = self.db
                let ConfigTable = self.ConfigTable
                let key_c = self.key_c
                let value_c = self.value_c
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_minLevel", value_c <- 0 ))
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_maxLevel", value_c <- 5 ))
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_shuffle", value_c <- 0 ))
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_index", value_c <- 0 ))
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_num", value_c <- 0 ))
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_autoSpeak", value_c <- 0 ))
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_autoTransSpeak", value_c <- 0 ))
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_autoWordDisplay", value_c <- 1 ))
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_autoTransDisplay", value_c <- 0 ))
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "listen_reverse", value_c <- 0 ))
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "listen_speed", value_c <- 1 ))
                try db.run(ConfigTable.insert(or: .Abort, key_c <- "listen_interval", value_c <- 500 ))
            }
        }catch{
            print("ConfigTable init error")
        }
    }
    private func createTableDict(){
        do{
            try dict.run(DictTable.create(ifNotExists:true) { t in
                t.column(wordID_c, primaryKey: true)
                t.column(wordName_c,unique:false)
                t.column(phono_c, unique: false)
                t.column(trans_c, unique: false)
                t.column(t1_c, unique: false)
                t.column(t2_c, unique: false)
                t.column(t3_c, unique: false)
                t.column(t4_c, unique: false)
                t.column(audioFile_c, unique: false)
                t.unique(wordName_c, t1_c, t2_c, audioFile_c, trans_c)
                })
        }catch{
            print("create table:Dict failed")
        }
    }
    
    // the first list should be "scan"
    private func createTableList(){
        do{
            try db.run(ListTable.create(ifNotExists:true) { t in
                t.column(listID_c, primaryKey: true)
                t.column(listName_c,unique:true)
                t.column(wordsCount_c, unique: false)
                t.column(check_c, unique: false)
                })
        }catch{
            print("create table: List failed")
        }
    }
    
    
    private func createTableWordInfo(){
        do{
            try db.run(WordInfoTable.create(ifNotExists:true) { t in
                t.column(wordID_c, primaryKey: true)
                t.column(listID_c, unique: false)
                t.column(level_c,unique:false)
                t.unique(wordID_c, listID_c)
                })
        }catch{
            print("create table: Lists failed")
        }
    }
    
    private func createTableConfig(){
        do{
            try db.run(ConfigTable.create(ifNotExists:true) { t in
                t.column(key_c, primaryKey: true)
                t.column(value_c, unique:false)
                })
        }catch{
            print("create table: Config failed")
        }
    }
    private func createTableLink(){
        do{
            try db.run(LinkTable.create(ifNotExists:true) { t in
                t.column(linkID_c, primaryKey: true)
                t.column(wordID_c, unique: false)
                t.column(linkWordID_c, unique:false)
                })
        }catch{
            print("create table: Link failed")
        }
        
    }
    
    private func createTableScanList(){
        do{
            try db.run(ScanListTable.create(ifNotExists:true) { t in
                t.column(scanID_c, primaryKey: true)
                t.column(wordID_c, unique: true)
                t.column(level_c, unique:false, defaultValue:0)
                t.column(sort_c, unique:false)
                })
        }catch{
            print("create table: ScanList failed")
        }
    }
}