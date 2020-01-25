//
//  VocabDetailViewController.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 11/30/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
import CoreData

class VocabDetailViewController: UIViewController {
    @IBOutlet var lemmaLabel:UITextField?
    @IBOutlet var unitLabel:UITextField?
    @IBOutlet var posLabel:UITextField?
    @IBOutlet var defLabel:UITextView?
    @IBOutlet var ppLabel:UITextView?
    @IBOutlet var noteLabel:UITextView?
    @IBOutlet var scrollView:UIScrollView?
    @IBOutlet var arrowedLabel:UITextField?
    @IBOutlet var pageLineLabel:UITextField?
    @IBOutlet var verbClassView:UITextField?
    @IBOutlet var contentView:UIView?
    var kb:KeyboardViewController? = nil
    
    var db: OpaquePointer? = nil
    
    var hqid:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //https://www.natashatherobot.com/ios-autolayout-scrollview/
        scrollView!.contentSize = contentView!.frame.size
        // Do any additional setup after loading the view.
        
        kb = KeyboardViewController() //kb needs to be member variable, can't be local to just this function
        kb?.appExt = false
        
        noteLabel?.inputView = kb?.inputView
        noteLabel?.isEditable = true
        
        let dbpath = (UIApplication.shared.delegate as! AppDelegate).dbpath
        //https://www.raywenderlich.com/123579/sqlite-tutorial-swift
        db = openDatabase(dbpath: dbpath)
        print("get db")
        if db != nil
        {
            print("db ok")
            if hqid > 0
            {
                loadDef()
            }
            //query(sortAlpha:self.sortAlpha, predicate:self.predicate)
        }
        resetColors()
    }
    
    func resetColors()
    {
        GlobalTheme = (isDarkMode()) ? DarkTheme.self : DefaultTheme.self
        //UINavigationBar.appearance().tintColor = GlobalTheme.primaryText
        navigationController?.navigationBar.tintColor  = GlobalTheme.primaryText
        
        if isDarkMode()
        {
            lemmaLabel?.layer.borderColor = GlobalTheme.primaryText.cgColor
            lemmaLabel?.layer.borderWidth = 1.0
            unitLabel?.layer.borderColor = GlobalTheme.primaryText.cgColor
            unitLabel?.layer.borderWidth = 1.0
            posLabel?.layer.borderColor = GlobalTheme.primaryText.cgColor
            posLabel?.layer.borderWidth = 1.0
            defLabel?.layer.borderColor = GlobalTheme.primaryText.cgColor
            defLabel?.layer.borderWidth = 1.0
            ppLabel?.layer.borderColor = GlobalTheme.primaryText.cgColor
            ppLabel?.layer.borderWidth = 1.0
            noteLabel?.layer.borderColor = GlobalTheme.primaryText.cgColor
            noteLabel?.layer.borderWidth = 1.0

            view.backgroundColor = GlobalTheme.primaryBG
        }
        else
        {
            lemmaLabel?.layer.borderWidth = 0.0
            unitLabel?.layer.borderWidth = 0.0
            posLabel?.layer.borderWidth = 0.0
            defLabel?.layer.borderWidth = 0.0
            ppLabel?.layer.borderWidth = 0.0
            noteLabel?.layer.borderWidth = 0.0
            view.backgroundColor = UIColor.systemGray
        }
         
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true
            {
                resetColors()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        //self.navigationItem.title = ""
        /*
         let infoButton = UIButton.init(type: .infoDark)
         infoButton.addTarget(self, action: #selector(showCredits), for: .touchUpInside)
         let buttonItem = UIBarButtonItem.init(customView: infoButton)
         navigationItem.rightBarButtonItem = buttonItem
         */
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
    
    func principalParts(present:String, future:String,aorist:String,perfect:String,perfectmid:String,aoristpass:String,seperator:String) -> String
    {
        let dash = "—"//let dash = "–"
        var innerSeperator:String = " or"
        if seperator != ""
        {
            innerSeperator = seperator
        }
        var sa = [String]()
        sa.append(present != "" ? present.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        sa.append(future != "" ? future.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        sa.append(aorist != "" ? aorist.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        sa.append(perfect != "" ? perfect.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        sa.append(perfectmid != "" ? perfectmid.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        sa.append(aoristpass != "" ? aoristpass.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        
        return sa.joined(separator: ", ")
    }
    
    func loadDef()
    {
        var queryStatement: OpaquePointer? = nil
        if hqid < 1
        {
            return
        }
        /*
        let delegate = UIApplication.shared.delegate as! AppDelegate
        var vc:NSManagedObjectContext
        if #available(iOS 10.0, *) {
            vc = delegate.persistentContainer.viewContext
        } else {
            vc = delegate.managedObjectContext
        }
        let request: NSFetchRequest<HQWords> = HQWords.fetchRequest()
        if #available(iOS 10.0, *) {
            request.entity = HQWords.entity()
        } else {
            request.entity = NSEntityDescription.entity(forEntityName: "HQWords", in: delegate.managedObjectContext)
        }
        
        let pred = NSPredicate(format: "(hqid = %d)", self.hqid)
        request.predicate = pred
        var results: [HQWords]? = nil
        do {
            results =
                try vc.fetch(request as!
                    NSFetchRequest<NSFetchRequestResult>) as? [HQWords]
            
        } catch let error {
            NSLog("Error: %@", error.localizedDescription)
            return
        }
         
         if results != nil && results!.count > 0
         {
             let match = results?[0]
             let lemma:String = match!.lemma!
             let def:String = match!.def!
             let unit:Int16 = match!.unit
             let pos:String = match!.pos!
             let note:String = match!.note!
             let pp:String = principalParts(present:match!.present!, future:match!.future!, aorist:match!.aorist!,perfect:match!.perfect!,perfectmid:match!.perfectmid!, aoristpass:match!.aoristpass!,seperator: " or")
        */
        
        let query = "SELECT hqid,unit,lemma,def,pos,note,present,future,aorist,perfect,perfectmid,aoristpass,arrowedDay,pageLine,verbClass FROM hqvocab WHERE hqid = \(hqid) LIMIT 1;"
        //print(query)
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK
        {
            //print("query ok")
            if sqlite3_step(queryStatement) == SQLITE_ROW
            {
                //let hqid = sqlite3_column_int(queryStatement, 0)
                let unit = sqlite3_column_int(queryStatement, 1)
                let lemma = String(cString: sqlite3_column_text(queryStatement, 2)!)
                let def = String(cString: sqlite3_column_text(queryStatement, 3)!)
                let pos = String(cString: sqlite3_column_text(queryStatement, 4)!)
                let note = String(cString: sqlite3_column_text(queryStatement, 5)!)
                let present = String(cString: sqlite3_column_text(queryStatement, 6)!)
                let future = String(cString: sqlite3_column_text(queryStatement, 7)!)
                let aorist = String(cString: sqlite3_column_text(queryStatement, 8)!)
                let perfect = String(cString: sqlite3_column_text(queryStatement, 9)!)
                let perfectmid = String(cString: sqlite3_column_text(queryStatement, 10)!)
                let aoristpass = String(cString: sqlite3_column_text(queryStatement, 11)!)
                let arrowedDay = sqlite3_column_int(queryStatement, 12)
                let pageLine = String(cString: sqlite3_column_text(queryStatement, 13))
                let verbClass = sqlite3_column_int(queryStatement, 14)
                let pp:String = principalParts(present:present, future:future, aorist:aorist,perfect:perfect,perfectmid:perfectmid, aoristpass:aoristpass,seperator: " or")

                //print("query: \(unit) \(String(cString: lemma!))")

                if let w = defLabel
                {
                    w.text = def
                    /*
                    let maxHeight = CGFloat.infinity
                    let rect = w.text.boundingRect(with: CGSize(width:w.frame.size.width, height:maxHeight), options: .usesLineFragmentOrigin, context: nil)
                    var frame = w.frame
                    frame.size.height = rect.size.height
                    w.frame = frame
     */
                    //w.sizeToFit()
                }
                if let w = lemmaLabel
                {
                    w.text = lemma
                }
                if let w = posLabel
                {
                    w.text = pos
                }
                if let w = unitLabel
                {
                    w.text = "\(unit)"
                }
                if let w = noteLabel
                {
                    w.text = note
                }
                
                if let w = verbClassView
                {
                    w.text = String(verbClass)
                }
                if let w = pageLineLabel
                {
                    w.text = pageLine
                }
                if let w = arrowedLabel
                {
                    w.text = String(arrowedDay)
                }
                
                if let w = ppLabel
                {
                    if pos == "Verb"
                    {
                        w.text = pp
                    }
                }
            }
        }
        else
        {
            if let w = defLabel
            {
            //label.text = detail.timestamp!.description
            w.text = "Could not find Greek word \(self.hqid)."
            }
        }
        sqlite3_finalize(queryStatement);
        sqlite3_close(db);
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
