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
    weak var lemmaL:UILabel?
    weak var hqidL:UILabel?
    weak var unitL:UILabel?
    weak var posL:UILabel?
    weak var defL:UILabel?
    weak var ppL:UILabel?
    weak var noteL:UILabel?
    weak var arrowedL:UILabel?
    weak var pageLineL:UILabel?
    weak var verbClassL:UILabel?
    weak var lemmaLabel:UITextField?
    weak var hqidLabel:UITextField?
    weak var unitLabel:UITextField?
    weak var posLabel:UITextField?
    weak var defLabel:UITextView?
    weak var ppLabel:UITextView?
    weak var noteLabel:UITextView?
    //@IBOutlet var scrollView:UIScrollView?
    weak var arrowedLabel:UITextField?
    weak var pageLineLabel:UITextField?
    weak var verbClassLabel:UITextField?

    weak var contentView:UIView?
    weak var scrollView:UIScrollView?
    //@IBOutlet var contentView:UIView?
    var kb:KeyboardViewController? = nil
    var defColor = "black"
    var db: OpaquePointer? = nil
    let dbpath = (UIApplication.shared.delegate as! AppDelegate).dbpath
    
    override func loadView() {
        super.loadView()

        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        
        let contentView = UIView(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let hqidL = UILabel(frame: .zero)
        hqidL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hqidL)
        
        let hqidLabel = UITextField(frame: .zero)
        hqidLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hqidLabel)
        
        let lemmaL = UILabel(frame: .zero)
        lemmaL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lemmaL)
        
        //view.translatesAutoresizingMaskIntoConstraints = true
        let lemmaLabel = UITextField(frame: .zero)
        lemmaLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lemmaLabel)
        
        let unitL = UILabel(frame: .zero)
        unitL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(unitL)
        
        let unitLabel = UITextField(frame: .zero)
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(unitLabel)
        
        let posL = UILabel(frame: .zero)
        posL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posL)
        
        let posLabel = UITextField(frame: .zero)
        posLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posLabel)
        
        let defL = UILabel(frame: .zero)
        defL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(defL)
        
        let defLabel = UITextView(frame: .zero)
        defLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(defLabel)
        
        let ppL = UILabel(frame: .zero)
        ppL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ppL)
        
        let ppLabel = UITextView(frame: .zero)
        ppLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ppLabel)
        
        let noteL = UILabel(frame: .zero)
        noteL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(noteL)
        
        let noteLabel = UITextView(frame: .zero)
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(noteLabel)
        
        let arrowedL = UILabel(frame: .zero)
        arrowedL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(arrowedL)
        
        let arrowedLabel = UITextField(frame: .zero)
        arrowedLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(arrowedLabel)
        
        let pageLineL = UILabel(frame: .zero)
        pageLineL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pageLineL)
        
        let pageLineLabel = UITextField(frame: .zero)
        pageLineLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pageLineLabel)
        
        let verbClassL = UILabel(frame: .zero)
        verbClassL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(verbClassL)
        
        let verbClassLabel = UITextField(frame: .zero)
        verbClassLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(verbClassLabel)

        if #available(iOS 11.0, *) {
            let vv = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: vv.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: vv.trailingAnchor),
                scrollView.topAnchor.constraint(equalTo: vv.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: vv.bottomAnchor)
            ])
        }
        else
        {
            let vv = view!
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: vv.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: vv.trailingAnchor),
                scrollView.topAnchor.constraint(equalTo: vv.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: vv.bottomAnchor)
            ])
        }
        let vMargin:CGFloat = 8.0
        NSLayoutConstraint.activate([

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.2),
            
            hqidL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hqidL.trailingAnchor.constraint(equalTo: hqidLabel.leadingAnchor),
            hqidL.topAnchor.constraint(equalTo: contentView.topAnchor),
            hqidL.bottomAnchor.constraint(equalTo: lemmaL.topAnchor, constant: vMargin * -1),
            
            hqidLabel.leadingAnchor.constraint(equalTo: hqidL.trailingAnchor),
            hqidLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hqidLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            hqidLabel.bottomAnchor.constraint(equalTo: lemmaL.topAnchor, constant: vMargin * -1),
            
            lemmaL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lemmaL.trailingAnchor.constraint(equalTo: lemmaLabel.leadingAnchor),
            lemmaL.topAnchor.constraint(equalTo: hqidL.bottomAnchor, constant: vMargin),
            lemmaL.bottomAnchor.constraint(equalTo: unitLabel.topAnchor, constant: vMargin * -1),
            
            lemmaLabel.leadingAnchor.constraint(equalTo: lemmaL.trailingAnchor),
            lemmaLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lemmaLabel.topAnchor.constraint(equalTo: hqidL.bottomAnchor, constant: vMargin),
            lemmaLabel.bottomAnchor.constraint(equalTo: unitLabel.topAnchor, constant: vMargin * -1),
            //lemmaLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),

            unitL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            unitL.trailingAnchor.constraint(equalTo: unitLabel.leadingAnchor),
            unitL.topAnchor.constraint(equalTo: lemmaLabel.bottomAnchor, constant: vMargin),
            unitL.bottomAnchor.constraint(equalTo: posLabel.topAnchor, constant: vMargin * -1),
            
            unitLabel.leadingAnchor.constraint(equalTo: unitL.trailingAnchor),
            unitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            unitLabel.topAnchor.constraint(equalTo: lemmaLabel.bottomAnchor, constant: vMargin),
            unitLabel.bottomAnchor.constraint(equalTo:posLabel.topAnchor, constant: vMargin * -1),

            posL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posL.trailingAnchor.constraint(equalTo: posLabel.leadingAnchor),
            posL.topAnchor.constraint(equalTo: unitLabel.bottomAnchor, constant: vMargin),
            posL.bottomAnchor.constraint(equalTo: defL.topAnchor, constant: vMargin * -1),
            
            posLabel.leadingAnchor.constraint(equalTo: posL.trailingAnchor),
            posLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posLabel.topAnchor.constraint(equalTo: unitLabel.bottomAnchor, constant: vMargin),
            posLabel.bottomAnchor.constraint(equalTo: defL.topAnchor, constant: vMargin * -1),
            
            defL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            defL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            defL.topAnchor.constraint(equalTo: posL.bottomAnchor, constant: vMargin),
            defL.bottomAnchor.constraint(equalTo: defLabel.topAnchor, constant: vMargin * -1),
            
            defLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            defLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            defLabel.topAnchor.constraint(equalTo: defL.bottomAnchor, constant: vMargin),
            defLabel.bottomAnchor.constraint(equalTo: ppL.topAnchor, constant: vMargin * -1),
            defLabel.heightAnchor.constraint(equalToConstant: 80.0),
            
            ppL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ppL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ppL.topAnchor.constraint(equalTo: defLabel.bottomAnchor, constant: vMargin),
            ppL.bottomAnchor.constraint(equalTo: ppLabel.topAnchor, constant: vMargin * -1),

            ppLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ppLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ppLabel.topAnchor.constraint(equalTo: ppL.bottomAnchor, constant: vMargin),
            ppLabel.bottomAnchor.constraint(equalTo: noteL.topAnchor, constant: vMargin * -1),
            ppLabel.heightAnchor.constraint(equalToConstant: 80.0),
            
            noteL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            noteL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            noteL.topAnchor.constraint(equalTo: ppLabel.bottomAnchor, constant: vMargin),
            noteL.bottomAnchor.constraint(equalTo: noteLabel.topAnchor, constant: vMargin * -1),
            
            noteLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            noteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            noteLabel.topAnchor.constraint(equalTo: noteL.bottomAnchor, constant: vMargin),
            noteLabel.bottomAnchor.constraint(equalTo: verbClassL.topAnchor, constant: vMargin * -1),
            noteLabel.heightAnchor.constraint(equalToConstant: 80.0),

            verbClassL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            verbClassL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            verbClassL.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: vMargin),
            verbClassL.bottomAnchor.constraint(equalTo: verbClassLabel.topAnchor, constant: vMargin * -1),
            
            verbClassLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            verbClassLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            verbClassLabel.topAnchor.constraint(equalTo: verbClassL.bottomAnchor, constant: vMargin),
            verbClassLabel.bottomAnchor.constraint(equalTo: arrowedL.topAnchor, constant: vMargin * -1),
            
            arrowedL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            arrowedL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            arrowedL.topAnchor.constraint(equalTo: verbClassLabel.bottomAnchor, constant: vMargin),
            arrowedL.bottomAnchor.constraint(equalTo: arrowedLabel.topAnchor, constant: vMargin * -1),
            
            arrowedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            arrowedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            arrowedLabel.topAnchor.constraint(equalTo: arrowedL.bottomAnchor, constant: vMargin),
            arrowedLabel.bottomAnchor.constraint(equalTo: pageLineL.topAnchor, constant: vMargin * -1),
            
            pageLineL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageLineL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pageLineL.topAnchor.constraint(equalTo: arrowedLabel.bottomAnchor, constant: vMargin),
            pageLineL.bottomAnchor.constraint(equalTo: pageLineLabel.topAnchor, constant: vMargin * -1),
            
            pageLineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageLineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pageLineLabel.topAnchor.constraint(equalTo: pageLineL.bottomAnchor, constant: vMargin),
            pageLineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        self.hqidL = hqidL
        self.hqidLabel = hqidLabel
        self.lemmaL = lemmaL
        self.lemmaLabel = lemmaLabel
        self.unitL = unitL
        self.unitLabel = unitLabel
        self.posL = posL
        self.posLabel = posLabel
        self.defL = defL
        self.defLabel = defLabel
        self.ppL = ppL
        self.ppLabel = ppLabel
        self.noteL = noteL
        self.noteLabel = noteLabel
        self.verbClassL = verbClassL
        self.verbClassLabel = verbClassLabel
        self.arrowedL = arrowedL
        self.arrowedLabel = arrowedLabel
        self.pageLineL = pageLineL
        self.pageLineLabel = pageLineLabel
        self.scrollView = scrollView
        self.contentView = contentView
    }
    
    var hqid:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        lemmaL!.text = "Lemma: "
        lemmaL?.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        hqidL!.text = "ID: "
        hqidL?.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        unitL!.text = "Unit: "
        unitL?.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        posL!.text = "POS: "
        posL?.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        defL!.text = "Def:"
        defL?.setContentHuggingPriority(.defaultHigh, for: .vertical)
        ppL!.text = "Principal Parts:"
        ppL?.setContentHuggingPriority(.defaultHigh, for: .vertical)
        noteL!.text = "Notes:"
        noteL?.setContentHuggingPriority(.defaultHigh, for: .vertical)
        verbClassL!.text = "Verb Class:"
        verbClassL?.setContentHuggingPriority(.defaultHigh, for: .vertical)
        verbClassLabel?.setContentHuggingPriority(.defaultHigh, for: .vertical)
        arrowedL!.text = "Arrowed Day:"
        arrowedL?.setContentHuggingPriority(.defaultHigh, for: .vertical)
        arrowedLabel?.setContentHuggingPriority(.defaultHigh, for: .vertical)
        pageLineL!.text = "Page/Line:"
        pageLineL?.setContentHuggingPriority(.defaultHigh, for: .vertical)
        //pageLineLabel?.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        //https://www.natashatherobot.com/ios-autolayout-scrollview/
        //scrollView!.contentSize = contentView!.frame.size
        // Do any additional setup after loading the view.
        
        //kb = KeyboardViewController() //kb needs to be member variable, can't be local to just this function
        //kb?.appExt = false
        //noteLabel?.inputView = kb?.inputView
        //noteLabel?.isEditable = true
        
        resetColors()
        
        loadDef()
        //query(sortAlpha:self.sortAlpha, predicate:self.predicate)
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
            defColor = "white"
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
            defColor = "black"
        }
         
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true
            {
                resetColors()
                //loadDef() //crashes?
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
        if hqid < 1
        {
            return
        }
        
        //https://www.raywenderlich.com/123579/sqlite-tutorial-swift
        db = openDatabase(dbpath: dbpath)
        if db == nil
        {
            print("db not ok")
            return
        }
        print("db ok")
        
        var queryStatement: OpaquePointer? = nil
        
        let query = "SELECT hqid,unit,lemma,def,pos,note,present,future,aorist,perfect,perfectmid,aoristpass,arrowedDay,pageLine,verbClass FROM hqvocab WHERE hqid = \(hqid) LIMIT 1;"
        //print(query)
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK
        {
            //print("query ok")
            if sqlite3_step(queryStatement) == SQLITE_ROW
            {
                let hqidValue = sqlite3_column_int(queryStatement, 0)
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
                    let useAttributed = true
                    if useAttributed
                    {
                        let htmlText = "<span style='color:\(defColor);font-size:14pt;font-family:helvetica;'>" + def + "</span>"
                        let encodedData = htmlText.data(using: .utf8)!

                        do {
                            let attributedString = try NSAttributedString(data: encodedData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
                            w.attributedText = attributedString
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        } catch {
                            print("error")
                        }
                    }
                    else
                    {
                        w.text = def
                    }
    /*
                    let maxHeight = CGFloat.infinity
                    let rect = w.text.boundingRect(with: CGSize(width:w.frame.size.width, height:maxHeight), options: .usesLineFragmentOrigin, context: nil)
                    var frame = w.frame
                    frame.size.height = rect.size.height
                    w.frame = frame
     */
                    //w.sizeToFit()
                }
                if let w = hqidLabel
                {
                    w.text = "\(hqidValue)"
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
                
                if let w = verbClassLabel
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
