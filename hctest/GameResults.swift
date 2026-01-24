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
    
    var gameid:Int = 1 //set from previous view controller
    var isHCGame = false //set from previous view controller
    
    var res = [Result]()
    let checkImage = UIImage(systemName: "checkmark.circle.fill")// named:"greencheck.png")
    let xImage = UIImage(systemName: "x.circle.fill")// named:"redx.png")
    let vf = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: 0)
    let prevVF = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: 0)
    //let f = UIFont(name: "HelveticaNeue", size: 16.0)!
    let greekFont = UIFont(name: "NewAthenaUnicode", size: 18.0)
    //lazy var startTextAttributes = [NSAttributedString.Key.font: f]
    lazy var italicTextAttributes = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 16.0), NSAttributedString.Key.foregroundColor: UIColor.gray]
    lazy var normalTextAttributes = [NSAttributedString.Key.font: greekFont, NSAttributedString.Key.foregroundColor: GlobalTheme.primaryText]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isHCGame
        {
            title = "Game Moves"
        }
        else
        {
            title = "Practice Moves"
        }
        
        let dbpath = (UIApplication.shared.delegate as! AppDelegate).dbpath
        
        //https://www.raywenderlich.com/123579/sqlite-tutorial-swift
        if let db = openDatabase(dbpath: dbpath)
        {
            query(db: db, gameid: gameid)
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        //print("len" + String(res.count) + " , " + String(res[0].verbid))
    }
    
    func resetColors()
    {
        GlobalTheme = (isDarkMode()) ? DarkTheme.self : DefaultTheme.self
        //UINavigationBar.appearance().tintColor = GlobalTheme.primaryText
        view.backgroundColor = GlobalTheme.primaryBG
        navigationController?.navigationBar.tintColor  = GlobalTheme.primaryText
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true
            {
                resetColors()
                self.tableView.reloadData()
            }
        }
    }
    
    func query(db:OpaquePointer, gameid:Int) {
        var queryStatement: OpaquePointer? = nil

        let queryStatementString:String = "SELECT person,number,tense,voice,mood,verbid,answerGiven,elapsedtime,correct FROM verbseq WHERE gameid=? ORDER BY ID DESC LIMIT 1000;"
        
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
                
                //print("Query Result:")
                //print("\(person),\(number),\(tense),\(voice),\(mood):\(verbid) | \(incorrectString), \(isCorrect), \(timeString)")
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
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        cell.accessoryType = UITableViewCell.AccessoryType.none

        let index = indexPath.row

        
        let stemTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let correctTitle : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        let incorrectTitle : UILabel = cell.contentView.viewWithTag(103) as! UILabel
        let timeTitle : UILabel = cell.contentView.viewWithTag(104) as! UILabel
        let isCorrect : UIImageView = cell.contentView.viewWithTag(105) as! UIImageView
        
        vf.setPerson(UInt8(res[index].person))
        vf.setNumber(UInt8(res[index].number))
        vf.setTense(UInt8(res[index].tense))
        vf.setVoice(UInt8(res[index].voice))
        vf.setMood(UInt8(res[index].mood))
        vf.verbid = Int(res[index].verbid)
        
        var attribDescription:NSMutableAttributedString?
        if index < res.count - 1 //also check that it's not a starting form
        {
            prevVF.setPerson(UInt8(res[index + 1].person))
            prevVF.setNumber(UInt8(res[index + 1].number))
            prevVF.setTense(UInt8(res[index + 1].tense))
            prevVF.setVoice(UInt8(res[index + 1].voice))
            prevVF.setMood(UInt8(res[index + 1].mood))
            prevVF.verbid = Int(res[index + 1].verbid)
            
            attribDescription = attributedDescription(orig: prevVF.getDescription(), new: vf.getDescription())
        }
 
        //print("verb \(vf.verbid)")
        
        if vf.verbid < 0
        {
            return cell
        }
        
        if attribDescription != nil && res[index].incorrectAns != "START"
        {
            stemTitle.attributedText = attribDescription
        }
        else
        {
            stemTitle.text = vf.getDescription()
        }
        
        let attributedCorrect = NSAttributedString(string: "(" + vf.getForm(decomposed: false).replacingOccurrences(of: "\n", with: " ", options: .literal, range: nil) + ")", attributes: normalTextAttributes as [NSAttributedString.Key : Any])
        correctTitle.attributedText = attributedCorrect
        
        //if starting form of the sequence
        if res[index].incorrectAns == "START"
        {
            isCorrect.isHidden = true
            timeTitle.isHidden = true
            
            let attributedQuote = NSAttributedString(string: "initial form", attributes: italicTextAttributes)
            incorrectTitle.attributedText = attributedQuote
        }
        else
        {
            //if given answer is blank
            if res[index].incorrectAns.trimmingCharacters(in: .whitespaces).isEmpty {
                let attributedUnasnwered = NSAttributedString(string: "unanswered", attributes: italicTextAttributes)
                incorrectTitle.attributedText = attributedUnasnwered
            }
            else {
                let incorrectAnswered = NSAttributedString(string: res[index].incorrectAns.replacingOccurrences(of: "\n", with: " ", options: .literal, range: nil), attributes: normalTextAttributes as [NSAttributedString.Key : Any])
                incorrectTitle.attributedText = incorrectAnswered
            }
            
            timeTitle.text = res[index].elapsedTime
            timeTitle.textColor = GlobalTheme.primaryText
            timeTitle.isHidden = false
            
            isCorrect.image = (res[index].isCorrect == 0) ? xImage : checkImage
            isCorrect.tintColor = (res[index].isCorrect == 0) ? GlobalTheme.redX : GlobalTheme.greenCheck
            isCorrect.isHidden = false
        }
        return cell
    }
    
    func attributedDescription(orig:String, new:String) -> NSMutableAttributedString
    {
        let a = orig.components(separatedBy: " ")
        let b = new.components(separatedBy: " ")
        
        //print("orig: \(orig), new: \(new)")
        
        let att = NSMutableAttributedString.init(string: new)
        var start = 0
        for i in 0...4
        {
            if a[i] != b[i]
            {
                att.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, range: NSRange(location: start, length: b[i].count))
            }
            start += b[i].count + 1
        }
        att.addAttribute(NSAttributedString.Key.foregroundColor, value: GlobalTheme.primaryText, range: NSRange(location: 0, length: att.length))
        return att
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.tag = indexPath.row
        
        //performSegue(withIdentifier: "SegueToVerbDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return res.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
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

