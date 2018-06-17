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
    @IBOutlet var contentView:UIView?
    var kb:KeyboardViewController? = nil
    
    var hqid:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //https://www.natashatherobot.com/ios-autolayout-scrollview/
        scrollView!.contentSize = contentView!.frame.size;
        // Do any additional setup after loading the view.
        
        kb = KeyboardViewController() //kb needs to be member variable, can't be local to just this function
        kb?.appExt = false
        
        noteLabel?.inputView = kb?.inputView
        noteLabel?.isEditable = true
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
        if hqid > 0
        {
            loadDef()
        }
    
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
            if let w = ppLabel
            {
                if pos == "Verb"
                {
                    w.text = pp
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
