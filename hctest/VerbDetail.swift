//
//  VerbDetail.swift
//  hctest
//
//  Created by Jeremy March on 3/15/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
import SQLite

class VerbDetailViewController: UIViewController {
    
    var verbIndex:Int = -1
    var res = [Result]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verb"
        
        let dbname:String = "hcdatadb.sqlite"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dbpath = documentsPath + "/" + dbname
        
        //https://www.raywenderlich.com/123579/sqlite-tutorial-swift
        let db = openDatabase(dbpath: dbpath)
        query(db: db!, gameid: 1)
        
        /*
        let db = Connection(dbpath, readonly:true)
        
        let users = Table("games")
        for user in db.prepare(users) {
            print("id: \(user[gameid]), score: \(user[score])")
            // id: 1, email: alice@mac.com, name: Optional("Alice")
        }
        */
        let backButton = UIBarButtonItem(title: "Practice", style: UIBarButtonItemStyle.plain, target: self, action: #selector
            (practiceVerb))
        self.navigationItem.rightBarButtonItem = backButton
    }
    
    func query(db:OpaquePointer, gameid:Int) {
        var queryStatement: OpaquePointer? = nil
        // 1
        let queryStatementString:String = "SELECT person,number,tense,voice,mood,verbid,incorrectAns,elapsedtime,correct FROM verbseq WHERE gameid=? ORDER BY ID DESC LIMIT 100;"
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(gameid))
            // 2
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
                
                
                // 5
                print("Query Result:")
                print("\(person),\(number),\(tense), \(voice),\(mood): \(verbid) | \(incorrectString), \(isCorrect)")
                
            }
            
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
    }
    /*
    func query(db:OpaquePointer, gameid:Int)
    {
        let query = "SELECT person,number,tense,voice,mood,verbid,incorrectAns,elapsedtime,correct FROM verbseq WHERE gameid=\(gameid) ORDER BY ID DESC LIMIT 100;"
        //char *err_msg = 0;
        //[results2 removeAllObjects];
        int rc = sqlite3_exec(db, query, getVerbSeqCallback2, 0, 0);

    }
    */
    func openDatabase(dbpath:String) -> OpaquePointer? {
        var db: OpaquePointer? = nil
        if sqlite3_open(dbpath, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(dbpath)")
        } else {
            print("Unable to open database. Verify that you created the directory described " +
                "in the Getting Started section.")
        }
        return db
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    /*
    func printVerb(verb:Verb2)
    {
        let vf = VerbForm(person: 0, number: 0, tense: 0, voice: 0, mood: 0, verb: Int(verb.verbId))

        var isOida:Bool = false
        if verb.present == "οἶδα" || verb.present == "σύνοιδα"
        {
            isOida = true
        }
        
        for tense in 0..<NUM_TENSES
        {
            vf.tense = UInt8(tense)
            for voice in 0..<NUM_VOICES
            {
                for mood in 0..<NUM_MOODS
                {
                    if !isOida && mood != INDICATIVE && (tense == PERFECT || tense == PLUPERFECT || tense == IMPERFECT || tense == FUTURE)
                    {
                        continue
                    }
                    else if isOida && mood != INDICATIVE && (tense == PLUPERFECT || tense == IMPERFECT || tense == FUTURE)
                    {
                        continue
                    }
                    var s:String?
                    if voice == ACTIVE || tense == AORIST || tense == FUTURE
                    {
                        s = "  " + tenses[tense] + " " + voices[voice] + " " + moods[mood]
                    }
                    else if voice == MIDDLE
                    {
                        //yes it's correct, middle deponents do not have a passive voice.  H&Q page 316
                        if  verb.isDeponent() == MIDDLE_DEPONENT || verb.isDeponent() == PASSIVE_DEPONENT || verb.isDeponent() == DEPONENT_GIGNOMAI || verb.present == "κεῖμαι"
                        {
                            s = "  " + tenses[tense] + " " + "Middle" + " " + moods[mood]
                        }
                        else
                        {
                            s = "  " + tenses[tense] + " " + "Middle/Passive" + " " + moods[mood]
                        }
                    }
                    else
                    {
                        continue; //skip passive if middle+passive are the same
                    }

                    for number in 0..<NUM_NUMBERS
                    {
                        for person in 0..<NUM_PERSONS
                        {
                            vf.number = UInt8(number)
                            vf.person = UInt8(person)
                            vf.mood = UInt8(mood)
                            
                            var form = vf.getForm(decomposed: false)
                            
                            if (form != "")
                            {
                                let label = String.init(format: "%d%s:", (person+1), (number == 0) ? "s" : "p")
                                form = form.replacingOccurrences(of: ", ", with: "\n")
                                    
                            }
                        }
                    }
                }
                
            }
        }
        
    }
*/
    func practiceVerb()
    {
        performSegue(withIdentifier: "SegueToHoplitePractice", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let hp = segue.destination as! HopliteChallenge
        hp.isGame = false
        hp.practiceVerbId = verbIndex
    }
}

