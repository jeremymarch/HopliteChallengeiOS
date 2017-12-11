//
//  CardController.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 12/10/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CardController {
    var cardIndex = 0
    
    init() { // Constructor
        cardIndex = 0
    }
    
    func reset()
    {
        cardIndex = 0
    }
    
    func markRightOrWrong(cardId:Int, correct:Bool)
    {
        print("card: \(cardId) = \(correct)")
    }
    
    func nextCard(hqid: inout Int, frontStr:inout String, backString: inout String)
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
        let sortDescriptor = NSSortDescriptor(key: "seq", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        //let pred = NSPredicate(format: "(hqid = %d)", 1)
        //request.predicate = pred
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
            let match = results?[cardIndex]
            frontStr = match!.lemma!
            backString = match!.def!
            hqid = Int(match!.hqid)
            
            cardIndex = cardIndex + 1
        }
        else
        {
            frontStr = "Could not find Greek word."
        }
    }
}
