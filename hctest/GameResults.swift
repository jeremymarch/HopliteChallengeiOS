//
//  VerbDetail.swift
//  hctest
//
//  Created by Jeremy March on 3/15/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

struct Result {
    var person:Int32 = 0
    var number:Int32 = 0
    var tense:Int32 = 0
    var voice:Int32 = 0
    var mood:Int32 = 0
    var verbid:Int32 = 0
    var incorrectAns = ""
    var elapsedTime = ""
    var isCorrect:Int32 = 0
}

class GameResultsViewController: UITableViewController {
    
    var gameid:Int = 1
    var res = [Result]()
    let checkImage = UIImage(named:"greencheck.png")
    let xImage = UIImage(named:"redx.png")
    let vf = VerbForm(person: 0, number: 0, tense: 0, voice: 0, mood: 0, verb: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if gameid == 1
        {
            title = "Practice History"
        }
        else
        {
            title = "Game History"
        }
        
        let dbpath = (UIApplication.shared.delegate as! AppDelegate).dbpath
        
        //https://www.raywenderlich.com/123579/sqlite-tutorial-swift
        let db = openDatabase(dbpath: dbpath)
        query(db: db!, gameid: gameid)
    }
    
    func query(db:OpaquePointer, gameid:Int) {
        var queryStatement: OpaquePointer? = nil

        let queryStatementString:String = "SELECT person,number,tense,voice,mood,verbid,incorrectAns,elapsedtime,correct FROM verbseq WHERE gameid=? ORDER BY ID DESC LIMIT 100;"
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK
        {
            sqlite3_bind_int(queryStatement, 1, Int32(gameid))

            while sqlite3_step(queryStatement) == SQLITE_ROW
            {
                let person = sqlite3_column_int(queryStatement, 0)
                let number = sqlite3_column_int(queryStatement, 1)
                let tense = sqlite3_column_int(queryStatement, 2)
                let voice = sqlite3_column_int(queryStatement, 3)
                let mood = sqlite3_column_int(queryStatement, 4)
                let verbid = sqlite3_column_int(queryStatement, 5)
                let incorrect = sqlite3_column_text(queryStatement, 6)
                let incorrectString = String(cString: incorrect!)
                let time = sqlite3_column_text(queryStatement, 7)
                let timeString = String(cString: time!)
                let isCorrect = sqlite3_column_int(queryStatement, 8)
                
                res.append(Result(person: person, number: number, tense: tense, voice: voice, mood: mood, verbid: verbid, incorrectAns: incorrectString, elapsedTime: timeString, isCorrect: isCorrect))
                /*
                print("Query Result:")
                print("\(person),\(number),\(tense),\(voice),\(mood):\(verbid) | \(incorrectString), \(isCorrect), \(timeString)")
                */
            }
            
        }
        else
        {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
    }

    //https://www.raywenderlich.com/123579/sqlite-tutorial-swift
    func openDatabase(dbpath:String) -> OpaquePointer? {
        var db: OpaquePointer? = nil
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "GameResultCell")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        cell.accessoryType = UITableViewCellAccessoryType.none

        let index = indexPath.row

        
        let stemTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let correctTitle : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        let incorrectTitle : UILabel = cell.contentView.viewWithTag(103) as! UILabel
        let timeTitle : UILabel = cell.contentView.viewWithTag(104) as! UILabel
        let isCorrect : UIImageView = cell.contentView.viewWithTag(105) as! UIImageView
        
        vf.person = UInt8(res[index].person)
        vf.number = UInt8(res[index].number)
        vf.tense = UInt8(res[index].tense)
        vf.voice = UInt8(res[index].voice)
        vf.mood = UInt8(res[index].mood)
        vf.verbid = Int(res[index].verbid)
        
        
        stemTitle.text = vf.getDescription()
        correctTitle.text = vf.getForm(decomposed: false)
        incorrectTitle.text = res[index].incorrectAns
        timeTitle.text = res[index].elapsedTime
        isCorrect.image = (res[index].isCorrect == 0) ? xImage : checkImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        
        //performSegue(withIdentifier: "SegueToVerbDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return res.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
   /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.text = "  Unit \(section + 1)"
        
        label.backgroundColor = UIColor.blue
        label.textColor = UIColor.white
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
*/
}

