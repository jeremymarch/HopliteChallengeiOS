//
//  VocabListDataSourceSqlite.swift
//  HopliteChallenge
//
//  Created by Jeremy on 6/9/19.
//  Copyright © 2019 Jeremy March. All rights reserved.
//

import UIKit
import CoreData

struct Word {
    var hqid:Int32 = 0
    var unit:Int32 = 0
    var lemma:String = ""
}

protocol VocabDataSourceProtocol:UITableViewDataSource {
    var sortAlpha:Bool { get set }
    var predicate: String { get set }
    var unitSections:[Int] { get set }
    func filter()
    func resort()
    func getSelectedId(path:IndexPath) ->Int
    func getScrollSeq(searchText:String, seq: inout Int, unit: inout Int)
}

class VocabListDataSourceSqlite: NSObject, VocabDataSourceProtocol {
    // We keep this public and mutable, to enable our data
    // source to be updated as new data comes in.
    var sortAlpha = false
    var wordsPerUnit:[Int] = [] //[Int](repeating: 0, count: 20)
    var unitSections:[Int] = []
    var predicate = ""
    var db: OpaquePointer? = nil
    var wordsPerSection:[Int] = [Int](repeating: 0, count: 20)
    var words:[Word] = []
    
    let font = UIFont(name: "HelveticaNeue", size: 20.0)
    let greekFont = UIFont(name: "NewAthenaUnicode", size: 24.0)
    lazy var unitAttributes:[NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: font as Any]
    lazy var lemmaAttributes:[NSAttributedString.Key : Any] = [ NSAttributedString.Key.font: greekFont as Any]
    
    init(sortAlpha:Bool, predicate:String) {
        super.init()
        self.sortAlpha = sortAlpha
        self.predicate = predicate
        
        let dbpath = (UIApplication.shared.delegate as! AppDelegate).dbpath
        //https://www.raywenderlich.com/123579/sqlite-tutorial-swift
        db = openDatabase(dbpath: dbpath)
        print("get db")
        if db != nil
        {
            print("db ok")
            query(sortAlpha:self.sortAlpha, predicate:self.predicate)
        }
        
        self.setWordsPerUnit()
    }
    
    //https://www.raywenderlich.com/123579/sqlite-tutorial-swift
    func openDatabase(dbpath:String) -> OpaquePointer? {

        if sqlite3_open(dbpath, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(dbpath)")
        } else {
            print("Unable to open database. Verify that you created the directory described " +
                "in the Getting Started section.")
        }
        //to reset
        //sqlite3_exec(db, "UPDATE verbseq SET elapsedtime='1.23';", nil, nil, nil)
        return db
    }
    
    func query(sortAlpha:Bool, predicate:String)
    {
        //clear
        wordsPerSection = [Int](repeating: 0, count: 20)
        words.removeAll()
        var queryStatement: OpaquePointer? = nil
        
        var orderBy = ""
        if sortAlpha
        {
            orderBy = " ORDER BY seq ASC;"
        }
        else
        {
            orderBy = " ORDER BY unit ASC,seq ASC;"
        }
        var localPredicate = ""
        if predicate != ""
        {
            localPredicate = " WHERE " + predicate
        }
        
        let query = "SELECT hqid,unit,lemma FROM hqvocab" + localPredicate + orderBy
        //print(query)
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK
        {
            //print("query ok")
            while sqlite3_step(queryStatement) == SQLITE_ROW
            {
                let hqid = sqlite3_column_int(queryStatement, 0)
                let unit = sqlite3_column_int(queryStatement, 1)
                let lemma = sqlite3_column_text(queryStatement, 2)
                words.append( Word(hqid: hqid, unit: unit, lemma: String(cString: lemma!)) )
                wordsPerSection[ Int(unit) - 1 ] += 1
                //print("query: \(unit) \(String(cString: lemma!))")
            }
        }
        setWordsPerUnit()
        sqlite3_finalize(queryStatement)
        //sqlite3_close(db)
        
    }
    
    func filter()
    {
        query(sortAlpha: sortAlpha, predicate: predicate)
    }
    
    func resort()
    {
        query(sortAlpha: sortAlpha, predicate: predicate)
    }
    
    func getScrollSeq(searchText:String, seq: inout Int, unit: inout Int)
    {
        var queryStatement: OpaquePointer? = nil
        if sortAlpha
        {
            if predicate != ""
            {
                let query = "SELECT COUNT(*) FROM hqvocab WHERE sortkey < '\(searchText)' AND \(predicate) ORDER BY sortkey ASC;"
                print(query)
                if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK
                {
                    while sqlite3_step(queryStatement) == SQLITE_ROW
                    {
                        seq = Int(sqlite3_column_int(queryStatement, 0))
                    }
                }
                else
                {
                    print("query not ok")
                }
                sqlite3_finalize(queryStatement)
            }
            else
            {
                var foundOne = false
                let query = "SELECT seq FROM hqvocab WHERE sortkey >= '\(searchText)' ORDER BY sortkey ASC LIMIT 1;"
                if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK
                {
                    //print("query ok")
                    
                    while sqlite3_step(queryStatement) == SQLITE_ROW
                    {
                        foundOne = true
                        seq = Int(sqlite3_column_int(queryStatement, 0)) - 1
                        unit = 0
                    }
                }
                sqlite3_finalize(queryStatement)
                
                if !foundOne
                {
                    //selectedRow = -1
                    //selectedId = -1
                    seq = words.count
                    NSLog("Error: Word not found by id.");
                }
            }
        }
        else //scroll to unit
        {
            if searchText != ""
            {
                seq = 0
                guard let findUnit = Int(searchText) else
                {
                    return
                }
                var realFindUnit = findUnit
                if realFindUnit > 20
                {
                    realFindUnit = 20
                }
                for (index, val) in unitSections.enumerated()
                {
                    if val >= realFindUnit
                    {
                        unit = index
                        break
                    }
                }
            }
            else
            {
                unit = 0
                seq = 0
            }
            //print("unit seq: \(seq), \(unit)")
        }
 
    }
    
    func setWordsPerUnit()
    {
        //for (u, _) in wordsPerUnit.enumerated()
        wordsPerUnit = []
        unitSections = []
        for (idx,u) in wordsPerSection.enumerated()
        {
            if u > 0
            {
                wordsPerUnit.append(u)
                unitSections.append(idx+1)
            }
            //NSLog("words per: \(u), \(wordsPerUnit[u])")
        }
    }
    
    func howManySections() -> Int
    {
        var s = 0
        for i in wordsPerSection
        {
            if i > 0
            {
                s += 1
            }
        }
        return s
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !sortAlpha
        {
            return unitSections.count
        }
        else
        {
            return 1 //must have at least one section
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if !sortAlpha
        {
            count = wordsPerUnit[section]
        }
        else
        {
            count = words.count
        }
        //print("row count: \(count)")
        return count
    }
    
    func countSectionsBelow(section:Int) -> Int
    {
        if section < 0
        {
            return 0
        }
        var c = 0
        for i in 0...section
        {
            c += wordsPerUnit[i]
        }
        return c
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //print("row: \(indexPath.row), \(words[indexPath.row].unit), \(words[indexPath.row].lemma)")
        let priorSectionCount = countSectionsBelow(section:indexPath.section - 1)
        configureCell(cell, lemma: words[priorSectionCount + indexPath.row].lemma, unit: String(words[priorSectionCount + indexPath.row].unit))

        return cell
    }
    
    func getSelectedId(path:IndexPath) -> Int
    {
        let priorSectionCount = countSectionsBelow(section:path.section - 1)
        return Int(words[priorSectionCount + path.row].hqid)
    }
    
    //let highlightedRowBGColor = UIColor.init(red: 66/255.0, green: 127/255.0, blue: 237/255.0, alpha: 1.0)
    
    func configureCell(_ cell: UITableViewCell, lemma:String, unit:String) {
        if !sortAlpha
        {
            cell.textLabel!.text = lemma
            cell.textLabel?.font = greekFont
        }
        else
        {
            let nsstring = NSString(string: lemma)  //doesn't work with swift string len
            let unitLen = unit.count
            let attStr = NSMutableAttributedString(string: "\(lemma) (\(unit))")
            
            attStr.addAttributes(lemmaAttributes, range: NSRange(location: 0, length: nsstring.length))
            attStr.addAttributes(unitAttributes, range: NSRange(location: (nsstring.length + unitLen + 3) - (unitLen + 2) , length: unitLen + 2))
            cell.textLabel!.attributedText = attStr
        }
        
        //let greekFont = UIFont(name: "NewAthenaUnicode", size: 24.0)
        //cell.textLabel?.font = greekFont
        //cell.tag = Int(gw.wordid)
        
        //highlightedRowBGColor
        let bgColorView = UIView()
        bgColorView.backgroundColor = GlobalTheme.rowHighlightBG
        cell.selectedBackgroundView = bgColorView
    }
    

}
