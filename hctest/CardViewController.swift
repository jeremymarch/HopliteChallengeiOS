//
//  CardViewController.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 12/7/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
import Koloda
import CoreData

class CardViewController: UIViewController {
@IBOutlet weak var kolodaView: KolodaView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray
        // Do any additional setup after loading the view.
        kolodaView.dataSource = self
        kolodaView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        //let att = [ NSAttributedStringKey.font: UIFont(name: "NewAthenaUnicode", size: 22)! ]
        //self.navigationController?.navigationBar.titleTextAttributes = att
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CardViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        //koloda.reloadData()
        koloda.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
    }
}

extension CardViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return 20
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let f = self.view.frame
        let l = CardView.init(frame: f)
        var fs:String = ""
        var bs:String = ""
        loadDef(frontStr: &fs, backString: &bs)
        l.label1!.text = fs
        l.label2!.text = bs
        return l;//UIImageView(image: images[index])
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil//Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
    }
    
    func loadDef(frontStr:inout String, backString: inout String)
    {
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
        
        let pred = NSPredicate(format: "(hqid = %d)", 1)
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
            frontStr = match!.lemma!
            backString = match!.def!
        }
        else
        {
            frontStr = "Could not find Greek word."
        }
    }
}
