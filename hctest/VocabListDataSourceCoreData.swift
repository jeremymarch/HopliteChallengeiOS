//
//  VocabListDataSourceCoreData.swift
//  HopliteChallenge
//
//  Created by Jeremy on 6/9/19.
//  Copyright © 2019 Jeremy March. All rights reserved.
//

import UIKit
import CoreData

class VocabListDataSourceCoreData: NSObject, VocabDataSourceProtocol {
    // We keep this public and mutable, to enable our data
    // source to be updated as new data comes in.
    var sortAlpha = false
    var wordsPerUnit:[Int] = [] //[Int](repeating: 0, count: 20)
    var unitSections:[Int] = []
    var predicate = ""
    
    init(sortAlpha:Bool, predicate:String) {
        super.init()
        self.sortAlpha = sortAlpha
        self.predicate = predicate
        self.setWordsPerUnit()
    }
    
    func filter()
    {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "VocabMaster")
        
        if predicate != ""
        {
            print("filter predicate: \(predicate)")
            let pred = NSPredicate(format: predicate)
            _fetchedResultsController?.fetchRequest.predicate = pred
        }
        else
        {
            _fetchedResultsController?.fetchRequest.predicate = nil
        }
        
        do {
            try _fetchedResultsController?.performFetch()
        } catch let error {
            NSLog(error.localizedDescription)
            return
        }
        setWordsPerUnit()
    }
    
    func resort()
    {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "VocabMaster")
        _fetchedResultsController = nil
        /*
         let sortDescriptor = NSSortDescriptor(key: sortField, ascending: true)
         _fetchedResultsController?.fetchRequest.sortDescriptors = [sortDescriptor]
         _fetchedResultsController?.sectionNameKeyPath = ""
         */
    }
    
    func getScrollSeq(searchText:String, seq: inout Int, unit: inout Int)
    {
        if sortAlpha
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
            
            let sortDescriptor = NSSortDescriptor(key: "sortkey", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            
            var pred:NSPredicate?
            if predicate != ""
            {
                pred = NSPredicate(format: "(sortkey < %@ AND \(predicate))", searchText)
                request.predicate = pred
                do {
                    seq = try vc.count(for: request)
                }
                catch let error {
                    NSLog("Error: %@", error.localizedDescription)
                    return
                }
                NSLog("seqA is: \(seq)")
            }
            else
            {
                pred = NSPredicate(format: "(sortkey >= %@)", searchText)
                request.predicate = pred
                request.fetchLimit = 1
                
                var results: [HQWords]? = nil
                do {
                    results =
                        try vc.fetch(request as!
                            NSFetchRequest<NSFetchRequestResult>) as? [HQWords]
                    
                } catch let error {
                    // Handle error
                    NSLog("Error: %@", error.localizedDescription)
                    return
                }
                if results != nil && results!.count > 0
                {
                    //let match = results?[0]
                    seq = Int((results?[0].seq)!) - 1
                    unit = 0
                }
                else //past end, select last item
                {
                    //selectedRow = -1
                    //selectedId = -1
                    seq = (fetchedResultsController.fetchedObjects?.count)! - 1 //rowCount - 1
                    NSLog("Error: Word not found by id.");
                }
            }
        }
        else //scroll to unit
        {
            if searchText != ""
            {
                seq = 0
                guard let findUnit = Int(searchText) else
                {
                    return
                }
                var realFindUnit = findUnit
                if realFindUnit > 20
                {
                    realFindUnit = 20
                }
                for (index, val) in unitSections.enumerated()
                {
                    if val >= realFindUnit
                    {
                        unit = index
                        break
                    }
                }
            }
            else
            {
                unit = 0
                seq = 0
            }
            print("unit seq: \(seq), \(unit)")
        }
    }
    
    func countForUnit(unit: Int) -> Int {
        let moc = self.fetchedResultsController.managedObjectContext
        if #available(iOS 10.0, *) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HQWords")
            print("pred: \(predicate)")
            if predicate != ""
            {
                fetchRequest.predicate = NSPredicate(format: "unit = %d AND \(predicate)", unit)
            }
            else
            {
                fetchRequest.predicate = NSPredicate(format: "unit = %d", unit)
            }
            fetchRequest.includesSubentities = false
            
            var entitiesCount = 0
            
            do {
                entitiesCount = try moc.count(for: fetchRequest)
                print("unit: \(unit), count: \(entitiesCount)")
            }
            catch {
                print("error executing fetch request: \(error)")
            }
            
            return entitiesCount
        }
        else
        {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HQWords")
            if predicate != ""
            {
                fetchRequest.predicate = NSPredicate(format: "unit = %d AND \(predicate)", unit)
            }
            else
            {
                fetchRequest.predicate = NSPredicate(format: "unit = %d", unit)
            }
            
            var results: [NSManagedObject] = []
            
            do {
                results = try moc.fetch(fetchRequest)
            }
            catch {
                print("error executing fetch request: \(error)")
            }
            return results.count
        }
    }
    
    func setWordsPerUnit()
    {
        //for (u, _) in wordsPerUnit.enumerated()
        wordsPerUnit = []
        unitSections = []
        for u in 0...19
        {
            let c = countForUnit(unit: u+1)
            if c > 0
            {
                wordsPerUnit.append(c)
                unitSections.append(u+1)
            }
            //NSLog("words per: \(u), \(wordsPerUnit[u])")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if !sortAlpha
        {
            return wordsPerUnit.count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //let sectionInfo = fetchedResultsController.sections![section]
        //NSLog("FRC Count: \(sectionInfo.numberOfObjects)")
        if !sortAlpha
        {
            return wordsPerUnit[section]
        }
        else
        {
            return (fetchedResultsController.fetchedObjects?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let gw = fetchedResultsController.object(at: indexPath)
        configureCell(cell, lemma: gw.lemma!.description, unit: gw.unit.description)
        
        return cell
    }
    
    func getSelectedId(path:IndexPath) -> Int
    {
        let object = fetchedResultsController.object(at: path)
        return Int(object.hqid)
    }
    
    //let highlightedRowBGColor = UIColor.init(red: 66/255.0, green: 127/255.0, blue: 237/255.0, alpha: 1.0)
    
    func configureCell(_ cell: UITableViewCell, lemma:String, unit:String) {
        //cell.textLabel!.text = event.timestamp!.description
        //cell.textLabel!.text = "\(gw.hqid.description) \(gw.lemma!.description)"
        if !sortAlpha
        {
            cell.textLabel!.text = lemma
        }
        else
        {
            //cell.textLabel!.text = "\(gw.lemma!.description) : \(gw.sortkey!.description) (\(gw.unit.description))"
            cell.textLabel!.text = "\(lemma) (\(unit))"
        }
        
        let greekFont = UIFont(name: "NewAthenaUnicode", size: 24.0)
        cell.textLabel?.font = greekFont
        //cell.tag = Int(gw.wordid)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = GlobalTheme.rowHighlightBG //highlightedRowBGColor
        cell.selectedBackgroundView = bgColorView
        
    }
    
    var fetchedResultsController: NSFetchedResultsController<HQWords> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<HQWords> = HQWords.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let x = UIApplication.shared.delegate as! AppDelegate
        
        var sectionField:String?
        let sortDescriptorUnit = NSSortDescriptor(key: "unit", ascending: true)
        let sortDescriptorSeq = NSSortDescriptor(key: "seq", ascending: true)
        if sortAlpha
        {
            sectionField = nil
            fetchRequest.sortDescriptors = [sortDescriptorSeq]
        }
        else
        {
            sectionField = "unit"
            fetchRequest.sortDescriptors = [sortDescriptorUnit,sortDescriptorSeq]
        }
        
        if predicate != ""
        {
            let pred = NSPredicate(format: predicate)
            fetchRequest.predicate = pred
        }
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: x.managedObjectContext, sectionNameKeyPath: sectionField, cacheName: "VocabMaster")
        aFetchedResultsController.delegate = nil //we don't need this
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<HQWords>? = nil
}
