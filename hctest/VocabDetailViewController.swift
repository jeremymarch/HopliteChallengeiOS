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
    @IBOutlet var lemmaLabel:UILabel?
    @IBOutlet var unitLabel:UILabel?
    @IBOutlet var posLabel:UILabel?
    @IBOutlet var defLabel:UILabel?
    @IBOutlet var ppLabel:UILabel?
    @IBOutlet var noteLabel:UILabel?
    @IBOutlet var scrollView:UIScrollView?
    @IBOutlet var contentView:UIView?
    
    var hqid:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView!.contentSize = contentView!.frame.size;
        // Do any additional setup after loading the view.
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
            let pp:String = match!.present! + ", " + match!.future! + ", " + match!.aorist! + ", " + match!.perfect! + ", " + match!.perfectmid! + ", " + match!.aoristpass!
            
            if let w = defLabel
            {
                w.text = def
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
                w.text = pp
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
