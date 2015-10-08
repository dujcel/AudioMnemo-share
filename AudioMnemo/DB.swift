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
    
    var db:Connection!
    var textpath:String = NSBundle.mainBundle().pathForResource("GRE32", ofType: "TXT")!
    
    let Dic=Table("Dictionary")
    let id=Expression<Int64>("id")
    let wordName=Expression<String>("wordName")
    let startTimeOfWord=Expression<Double>("startTimeOfWord")
    let endTimeOfWord=Expression<Double>("endTimeOfWord")
    let startTimeOfTrans=Expression<Double>("startTimeOfTrans")
    let endTimeOfTrans=Expression<Double>("endTimeOfTrans")
    
    let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
    let dicPath = NSBundle.mainBundle().pathForResource("Dict", ofType: "sqlite3")!
    
    init(){
        do {
//            db = try Connection("\(dir)/Dict.sqlite3")   //write dababase from txt 
//            importFromFile(textpath)
              db = try Connection(dicPath)
           
            
        } catch {
            print("database connection failed: \(error)")
        }
        
        
    }
    
    func readData(wordID:Int64) ->(String?,Double?,Double?,Double?,Double?) {
        let users=Dic.filter(wordID==id)
        if let user = db.pluck(users){
        return (user.get(wordName),user.get(startTimeOfWord),user.get(endTimeOfWord),user.get(startTimeOfTrans),user.get(endTimeOfTrans))
        }
        else{
            return (nil, nil, nil, nil, nil)
        }
        }
    
    func importFromFile(textPath: String){
        do{
        try db.run(Dic.create { t in
            t.column(id, primaryKey: true)
            t.column(wordName,unique:true)
            t.column(startTimeOfWord, unique: false)
            t.column(endTimeOfWord, unique: false)
            t.column(startTimeOfTrans, unique: false)
            t.column(endTimeOfTrans, unique: false)
            })
        }catch{
            print("create table failed")
        }
        
        let separators = NSCharacterSet(charactersInString: "\t\r")
        var t1,t2,t3,t4:Double
        var name:String
        var i:Int=0
        //reading
        do {
            let data = try NSString(contentsOfFile: textpath, encoding: NSUTF8StringEncoding)
            let words = data.componentsSeparatedByCharactersInSet(separators)
            while(i+5<words.count){
                t1=(words[i++] as NSString).doubleValue
                t2=(words[i++] as NSString).doubleValue
                name=words[i++]
                t3=(words[i++] as NSString).doubleValue
                t4=(words[i++] as NSString).doubleValue
                i++
                print("t1:\(t1), t2:\(t2), name:\(name), t3:\(t3), t4:\(t4)")
                try db.run(Dic.insert(wordName <- name, startTimeOfWord <- t1, endTimeOfWord <- t2, startTimeOfTrans <- t3, endTimeOfTrans <- t4))
            }
            
        }
        catch {
            print("file read error")
        }

    }
}