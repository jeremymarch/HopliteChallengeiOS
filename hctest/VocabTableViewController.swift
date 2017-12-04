//
//  VocabTableViewController.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 11/25/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
import CoreData

class VocabTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var wordsPerUnit = [Int](repeating: 0, count: 20)
    var sortAlpha = true
    
    func countForUnit(unit: Int) -> Int {
        let moc = self.fetchedResultsController.managedObjectContext
        if #available(iOS 10.0, *) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HQWords")
            fetchRequest.predicate = NSPredicate(format: "unit = %d", unit)
            fetchRequest.includesSubentities = false
            
            var entitiesCount = 0
            
            do {
                entitiesCount = try moc.count(for: fetchRequest)
            }
            catch {
                print("error executing fetch request: \(error)")
            }
            
            return entitiesCount
        }
        else
        {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HQWords")
            fetchRequest.predicate = NSPredicate(format: "unit = %d", unit)
            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.datasync()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        for (u, _) in wordsPerUnit.enumerated()
        {
            wordsPerUnit[u] = countForUnit(unit: u+1)
            //NSLog("words per: \(u), \(wordsPerUnit[u])")
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if !sortAlpha
        {
            let label = UILabel()
            label.text = "  Unit \(section + 1)"
            
            label.backgroundColor = UIColor.init(red: 0, green: 0, blue: 110.0/255.0, alpha: 1.0)
            label.textColor = UIColor.white
            return label
        }
        else
        {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if !sortAlpha
        {
            return 20
        }
        else
        {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //let sectionInfo = fetchedResultsController.sections![section]
        //NSLog("FRC Count: \(sectionInfo.numberOfObjects)")
        if !sortAlpha
        {
            return wordsPerUnit[section]
        }
        else
        {
            return 527
        }
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
        var sortField:String?
        if sortAlpha
        {
            sectionField = nil
            sortField = "lemma"
        }
        else
        {
            sortField = "hqid"
            sectionField = "unit"
        }
        
        let sortDescriptor = NSSortDescriptor(key: sortField, ascending: true, selector:#selector(NSString.caseInsensitiveCompare))
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: x.managedObjectContext, sectionNameKeyPath: sectionField, cacheName: "VocabMaster")
        aFetchedResultsController.delegate = self
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event)
        // Configure the cell...

        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, withEvent gw: HQWords) {
        //cell.textLabel!.text = event.timestamp!.description
        //cell.textLabel!.text = "\(gw.hqid.description) \(gw.lemma!.description)"
        cell.textLabel!.text = gw.lemma!.description
        let greekFont = UIFont(name: "NewAthenaUnicode", size: 24.0)
        cell.textLabel?.font = greekFont
        //cell.tag = Int(gw.wordid)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.init(red: 136/255.0, green: 153/255.0, blue: 238/255.0, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let btn = UIButton(type: UIButtonType.custom)
        //btn.tag = indexPath.row
        
        //performSegue(withIdentifier: "ShowVocabDetail", sender: self)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let indexPath = tableView.indexPathForSelectedRow
        let object = fetchedResultsController.object(at: indexPath!)
        let wordid = Int(object.hqid)
        let vd = segue.destination as! VocabDetailViewController
        vd.hqid = wordid
    }
    

}
