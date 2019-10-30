//
//  GameHistory.swift
//  hctest
//
//  Created by Jeremy March on 3/15/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

struct Game {
    var id = 0
    var date = ""
    var score = 0
}
class GameHistoryViewController: UITableViewController {
        var isHCGame = false
        var games = [Game]()
        var gameOrPracticeDescription = "Games"
        let dbpath = (UIApplication.shared.delegate as! AppDelegate).dbpath
    
    func resetColors()
    {
        GlobalTheme = (isDarkMode()) ? DarkTheme.self : DefaultTheme.self
        //UINavigationBar.appearance().tintColor = GlobalTheme.primaryText
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
    
        override func viewDidLoad() {
            super.viewDidLoad()
            if isHCGame
            {
                gameOrPracticeDescription = "Games"
            }
            else
            {
                gameOrPracticeDescription = "Practice"
            }
            title = gameOrPracticeDescription
            
            //https://www.raywenderlich.com/123579/sqlite-tutorial-swift
            let db = openDatabase(dbpath: dbpath)
            query(db: db!)
        }
        
        func query(db:OpaquePointer) {
            var queryStatement: OpaquePointer? = nil
            
            var equalNotEqual = "!="
            if !isHCGame
            {
                equalNotEqual = "="
            }
            
            let queryStatementString:String = "SELECT gameid,timest,score FROM games WHERE score \(equalNotEqual) -1 ORDER BY gameid DESC;"
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK
            {
                //sqlite3_bind_int(queryStatement, 1, Int32(gameid))
                
                while sqlite3_step(queryStatement) == SQLITE_ROW
                {
                    let gameid = sqlite3_column_int(queryStatement, 0)
                    let timest = sqlite3_column_int(queryStatement, 1)
                    let score = sqlite3_column_int(queryStatement, 2)
                    
                    games.append(Game(id: Int(gameid), date: convertDateFormater(date: Int(timest)), score: Int(score)))
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
            sqlite3_close(db);
        }
    
    func convertDateFormater(date: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(date))
        
        //let now = Date.init()
        //if date.compare(now)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MMM dd HH:mm"
        //dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let timeStamp = dateFormatter.string(from: date)
        
        return timeStamp
    }
        
        //https://www.raywenderlich.com/123579/sqlite-tutorial-swift
        func openDatabase(dbpath:String) -> OpaquePointer? {
            var db: OpaquePointer? = nil
            if sqlite3_open(dbpath, &db) == SQLITE_OK
            {
                print("Successfully opened connection to database at \(dbpath)")
            }
            else
            {
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
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "GameHistoryCell")!
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.layoutMargins = UIEdgeInsets.zero
            cell.preservesSuperviewLayoutMargins = false
            cell.backgroundColor = UIColor.clear
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            
            let index = indexPath.row
            cell.tag = games[index].id
            
            let dateTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
            dateTitle.text = games[index].date
            let scoreTitle : UILabel = cell.contentView.viewWithTag(102) as! UILabel
            if isHCGame
            {
                scoreTitle.text = String(games[index].score)
            }
            else
            {
                scoreTitle.text = ""
            }
            
            /*
            if games[index].id == 1
            {
                dateTitle.text = "Practice History"
                scoreTitle.text = ""
            }
            else
            {*/
            
            
            //}
            
            
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let btn = UIButton(type: UIButton.ButtonType.custom)
            btn.tag = indexPath.row
            
            performSegue(withIdentifier: "SegueToGameResults", sender: self)
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return games.count
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 44
        }
    
         override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         
         let label = UILabel()
         label.text = "  \(gameOrPracticeDescription)"
         
         label.backgroundColor = GlobalTheme.secondaryBG// hcDarkBlue
         label.textColor = GlobalTheme.secondaryText
         return label
         }
         
         override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 34
         }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        //let id = indexPath.

        if let gr = segue.destination as? GameResultsViewController
        {
            let gameid = games[(indexPath?.row)!].id
            let score = games[(indexPath?.row)!].score
            
            gr.gameid = gameid
            if score < 0
            {
                gr.isHCGame = false
            }
            else
            {
                gr.isHCGame = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            deleteGame(gameid:games[indexPath.row].id)
            games.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func deleteGame(gameid:Int)
    {
        var queryStatement: OpaquePointer? = nil
        let db = openDatabase(dbpath: dbpath)
        //var zErrMsg:UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?
        
        var rc = sqlite3_exec(db, "BEGIN;", nil, nil, nil)
        if( rc != SQLITE_OK )
        {
            print("Did not delete game. BEGIN\n");
            //sqlite3_free(zErrMsg);
            return
        }
        
        var queryStatementString:String = "DELETE FROM games WHERE gameid = ?;"
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK
        {
            sqlite3_bind_int(queryStatement, 1, Int32(gameid))
            
            if sqlite3_step(queryStatement) == SQLITE_DONE
            {
                print("deleted game1")
            }
            else
            {
                print("not deleted1")
                sqlite3_finalize(queryStatement)
                return
            }
        }
        else
        {
            print("delete statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        queryStatementString = "DELETE FROM verbseq WHERE gameid = ?;"
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK
        {
            sqlite3_bind_int(queryStatement, 1, Int32(gameid))
            
            if sqlite3_step(queryStatement) == SQLITE_DONE
            {
                print("deleted game2")
            }
            else
            {
                print("not deleted2")
                sqlite3_finalize(queryStatement)
                return
            }
        }
        else
        {
            print("delete statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        rc = sqlite3_exec(db, "COMMIT;", nil, nil, nil)
        if( rc != SQLITE_OK )
        {
            print("Did not delete game. COMMIT\n");
            //sqlite3_free(zErrMsg);
            return
        }
        sqlite3_close(db);
    }
}

