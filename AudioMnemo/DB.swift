//
//  ImportToDB.swift
//  SQLiteTest
//
//  Created by yong gu on 10/5/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import Foundation
import SQLite




class DB{
    
    var am: AudioMnemo!
    
    var dict:Connection!         //dictionary db
    var db:Connection!        //main db
    
    //Tables
    let WordsTable = Table("Words")

    
    let LinkTable = Table("Link")
    
    let BookTable = Table("Book")
    let ListsTable = Table("Lists")
    let LevelTable = Table("Level")
    let ConfigTable = Table("Config")
    
    
    //Columns
    let id_c = Expression <Int>("id")
    let name_c = Expression<String>("name")
    
    //Dict
    
    let phono_c = Expression<String>("phonogram")
    let trans_c = Expression<String>("translation")
    let t1_c = Expression<Double>("audio_time1")   //start time of word (seconds)
    let t2_c = Expression<Double>("audio_time2")   //end time of word
    let t3_c = Expression<Double>("audio_time3")   //start time of translation
    let t4_c = Expression<Double>("audio_time4")   //end time of translation
    let audio_c = Expression<String>("audio_file")
    
    //Book
    let listID_c = Expression<Int>("list_id")
    let wordsCount_c = Expression<Int>("words_count")
    let scanCheck_c = Expression<Bool>("scan_check")
    let scanCount_c = Expression<Int>("scan_check_count")
    
    //ListTable and LevelTable
    let wordID_c = Expression<Int>("word_id")
    let level_c = Expression<Int>("level")
    
    //ConfigTable
    let key_c = Expression<String>("key")
    let value_c = Expression<Int>("value")
    
    //LinkTable
    let linkID_c = Expression<Int>("link_id")

    //id counter
    var id1: Int = 0   //for WordsTable
    var id2: Int = 0   //for BookTable
    
    
    let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
    let externalDictPath = NSBundle.mainBundle().pathForResource("Dict", ofType: "sqlite3")!
    
    init(am: AudioMnemo){
        self.am = am
        let isDBsExist = NSFileManager.defaultManager().fileExistsAtPath("\(dir)/Dict.sqlite3")
        print(Int.max)
        do {
            dict = try Connection("\(dir)/Dict.sqlite3")   //create dababase if not exist
            db = try Connection("\(dir)/db.sqlite3")
            if !isDBsExist {
                initTables()
                let count = updateDBWithFiles()
                print("Fill in database with \(count) files")
            }
//            db = try Connection(externalDictPath)
        } catch {
            print("database connection failed: \(error)")
        }
    }
    
    
    
//    func save() throws{
//        saveBookAndLists()
//        saveConfig()
//        saveLevels()
//        saveLinks()
//    }
    
    
    func loadLinks(){
        for link_r in db.prepare(LinkTable) {
            am.words[link_r[wordID_c]].linksID.insert(link_r[linkID_c])
            am.words[link_r[linkID_c]].linksID.insert(link_r[wordID_c])
        }
    }
    
    func addLink(id1:Int, with id2:Int){
        do{
            if id1 < id2 {
                try db.run(LinkTable.insert(or: .Ignore, wordID_c <- id1, linkID_c <- id2))
            }else{
                try db.run(LinkTable.insert(or: .Ignore, wordID_c <- id2, linkID_c <- id1))
            }
        }catch{
            print(" link \(id1) and \(id2) error")
        }
    }
    
    func cutLink(id1:Int, with id2:Int){
        do{
            if id1 < id2 {
                try db.run(LinkTable.filter(wordID_c == id1 && linkID_c == id2).delete())
            }else{
                try db.run(LinkTable.filter(wordID_c == id2 && linkID_c == id1).delete())
            }
        }catch{
            print("cut link \(id1) and \(id2) error")
        }
    }
    
//    func saveLinks(){
//        do{
//            try db.run(LinkTable.delete())
//            for word in am.words {
//                for linkID in word.linksID {
//                    if linkID > word.id {
//                        try db.run(LinkTable.insert(or: .Ignore, wordID_c <- word.id, linkID_c <- linkID))
//                    }
//                }
//            }
//        }catch{
//            print("save LevelTable error")
//        }
//    }
    
    func loadWords(){
        am.words = [Word]()
        am.words.append(Word())
        for word_r in dict.prepare(WordsTable) {
            let word = Word()
            word.id = word_r[id_c]
            word.name = word_r[name_c]
            word.phonogram = word_r[phono_c]
            word.audioFile = word_r[audio_c]
            word.audioTime1 = word_r[t1_c]
            word.audioTime2 = word_r[t2_c]
            word.audioTime3 = word_r[t3_c]
            word.audioTime4 = word_r[t4_c]
            am.words.append(word)
        }
    }
    
    func loadBookAndLists(){
        am.lists = [List]()
        for list_r in db.prepare(BookTable) {
            let list = List()
            let rows = ListsTable.filter(listID_c == list_r[id_c])
            
            for row in db.prepare(rows) {
                list.wordsID.append(row[wordID_c])
            }
            list.id = list_r[id_c]
            list.name = list_r[name_c]
            list.wordsCount = list_r[wordsCount_c]
            list.scanCheck = list_r[scanCheck_c]
            list.scanCount = list_r[scanCount_c]
            am.lists.append(list)
        }
    }
    
    func updateBook(){
        do{
            try db.transaction{
                for list in self.am.lists{
                    try self.db.run(self.BookTable.filter(self.id_c == list.id).update(self.scanCheck_c <- list.scanCheck, self.scanCount_c <- list.scanCount))
                }
                try self.db.run(self.BookTable.filter(self.id_c == 1).update(self.wordsCount_c <- self.am.lists[0].wordsCount))
            }
        }catch{
            print("transction update BookTable error")
        }
    }
    
    
    func updateScanList(){
        do{
            try db.transaction{
                try self.db.run(self.ListsTable.filter(self.listID_c == 1).delete())
                for wordID in self.am.lists[0].wordsID {
                    try self.db.run(self.ListsTable.insert(or: .Ignore, self.wordID_c <- wordID, self.listID_c <- 1))
                }
            }
        }catch{
            print("transction update ScanList error")
        }
    }
    
    func updateScanList(scanCount count:Int){
        do{
            try db.run(BookTable.filter(id_c == 1).update(scanCount_c <- count))
        }catch{
            print("update scanCount error")
        }
    }
    
    func loadLevels(){
            for level_r in db.prepare(LevelTable) {
                am.words[level_r[wordID_c]].level = level_r[level_c]
            }
    }
    
    func updateLevel(wordID:Int, to level:Int){
        do{
            if level > 0 {
                 try db.run(LevelTable.filter(wordID_c == wordID).update(level_c <- level))
            }else{
                try db.run(LevelTable.filter(wordID_c == wordID).delete())
            }
        }catch{
            print("update \(wordID) level to \(level) error")
        }
    }
    
//    func saveLevels(){
//        do{
//            try db.run(LevelTable.delete())
//            for word in am.words {
//                if word.level > 0 {
//                    try db.run(LevelTable.insert(or: .Replace, wordID_c <- word.id, level_c <- word.level))
//                }
//            }
//        }catch{
//            print("save LevelTable error")
//        }
//    }
    
    func loadConfig(){
        am.config = [String : Int]()
        for row in db.prepare(ConfigTable) {
            am.config[row[key_c]] = row[value_c]
        }
    }
    func updateConfig(key: String, with value: Int){
        do{
            try db.run(ConfigTable.filter(key_c == key).update(value_c <- am.config[key]!))
        }catch{}
    }
//    func saveConfig(){
//        do{
//        for key in am.config.keys{
//        try db.run(ConfigTable.filter(key_c == key).update(value_c <- am.config[key]!))
//        }
//        }catch{
//            print("save ConfigTable error")
//        }
//        
//    }
    
    
    
    func updateDBWithFiles() -> Int{
        var count:Int = 0
        let urls = NSBundle.mainBundle().URLsForResourcesWithExtension("TXT", subdirectory: nil)!
        var fileName: String!
        for url in urls {
            fileName = url.URLByDeletingPathExtension?.lastPathComponent
            if fileName != nil {
                updateDBWithFile(fileName, audioFileName: fileName)
                count++
            }
        }
        return count
    }
    private func updateDBWithFile(textFile: String, audioFileName: String){
//        print("update with file:\(textFile), audioFile:\(audioFileName)")
        let separators = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        var t1,t2,t3,t4:Double
        var name:String
        var i:Int=0
        
        //reading
        do {
            let textPath = NSBundle.mainBundle().pathForResource(textFile, ofType:"TXT")!
            let data = try NSString(contentsOfFile: textPath, encoding: NSUTF8StringEncoding)
            let words = data.componentsSeparatedByCharactersInSet(separators)
            
            
            var num:Int=0
            
            id2++
            try db.run(BookTable.insert(or: .Abort, id_c <- id2, name_c <- textFile, wordsCount_c <- num, scanCheck_c <- false, scanCount_c <- 0))
            
            while(i+5<words.count){
                t1=(words[i++] as NSString).doubleValue
                t2=(words[i++] as NSString).doubleValue
                name=words[i++]
                t3=(words[i++] as NSString).doubleValue
                t4=(words[i++] as NSString).doubleValue
                i++
                num++
                id1++
                
                try dict.run(WordsTable.insert(or: .Abort, id_c <- id1, name_c <- name, phono_c <- "a", trans_c <- "b", t1_c <- t1, t2_c <- t2, t3_c <- t3, t4_c <- t4, audio_c <- audioFileName ))
                try db.run(ListsTable.insert(or: .Abort, wordID_c <- id1, listID_c <- id2))
                try db.run(LevelTable.insert(or: .Replace, wordID_c <- id1, level_c <- 0))
            }
            
            try db.run(BookTable.filter(id_c == id2).update(wordsCount_c <- num))
            try db.run(BookTable.filter(id_c == id2).update(scanCount_c <- num))
        }
        catch {
            print("update Dict for \(textFile) error")
        }

    }
    
    func initTables(){
        createTableWords()
        createTableBook()
        createTableLists()
        createTableLevel()
        createTableConfig()
        createTableLink()
        do{
            id2++
            try db.run(BookTable.insert(or: .Abort, id_c <- id2, name_c <- "Scan List", wordsCount_c <- 0, scanCheck_c <- false, scanCount_c <- 0))
            try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_minLevel", value_c <- 0 ))
            try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_maxLevel", value_c <- 5 ))
            try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_autoSpeak", value_c <- 0 ))
            try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_autoTransSpeak", value_c <- 0 ))
            try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_autoWordDisplay", value_c <- 1 ))
            try db.run(ConfigTable.insert(or: .Abort, key_c <- "scan_autoTransDisplay", value_c <- 0 ))
            try db.run(ConfigTable.insert(or: .Abort, key_c <- "listen_reverse", value_c <- 0 ))
            try db.run(ConfigTable.insert(or: .Abort, key_c <- "listen_speed", value_c <- 1 ))
            try db.run(ConfigTable.insert(or: .Abort, key_c <- "listen_interval", value_c <- 500 ))
        }catch{
            print("tables init error")
        }
    }
    func createTableWords(){
        do{
            try dict.run(WordsTable.create(ifNotExists:true) { t in
                t.column(id_c, primaryKey: true)
                t.column(name_c,unique:false)
                t.column(phono_c, unique: false)
                t.column(trans_c, unique: false)
                t.column(t1_c, unique: false)
                t.column(t2_c, unique: false)
                t.column(t3_c, unique: false)
                t.column(t4_c, unique: false)
                t.column(audio_c, unique: false)
                t.unique(name_c, t1_c, t2_c, trans_c)
                })
        }catch{
            print("create table:Dict failed")
        }
    }

    // the first list should be "scan"
    func createTableBook(){
        do{
            try db.run(BookTable.create(ifNotExists:true) { t in
                t.column(id_c, primaryKey: true)
                t.column(name_c,unique:true)
                t.column(wordsCount_c, unique: false)
                t.column(scanCheck_c, unique: false)
                t.column(scanCount_c, unique:false)
                })
        }catch{
            print("create table: Book failed")
        }
    }
    
    
    func createTableLists(){
        do{
            try db.run(ListsTable.create(ifNotExists:true) { t in
                t.column(id_c, primaryKey: true)
                t.column(wordID_c,unique:false)
                t.column(listID_c, unique: false)
                t.unique(wordID_c, listID_c)
                })
        }catch{
            print("create table: Lists failed")
        }
    }
    

    func createTableLevel(){
        do{
            try db.run(LevelTable.create(ifNotExists:true) { t in
                t.column(wordID_c, primaryKey: true)
                t.column(level_c, unique: false)
                })
        }catch{
            print("create table: Level failed")
        }
    }
    
    func createTableConfig(){
        do{
            try db.run(ConfigTable.create(ifNotExists:true) { t in
                t.column(key_c, primaryKey: true)
                t.column(value_c, unique:false)
                })
        }catch{
            print("create table: Config failed")
        }
    }
    func createTableLink(){
        do{
            try db.run(LinkTable.create(ifNotExists:true) { t in
                t.column(id_c, primaryKey: true)
                t.column(wordID_c, unique:false)
                t.column(linkID_c, unique:false)
                t.unique(wordID_c,linkID_c)
                })
        }catch{
            print("create table: Link failed")
        }

    }
}