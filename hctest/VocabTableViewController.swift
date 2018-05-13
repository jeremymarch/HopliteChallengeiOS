//
//  VocabTableViewController.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 11/25/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
import CoreData

class VocabTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,UITextFieldDelegate {
    var wordsPerUnit = [Int](repeating: 0, count: 20)
    var sortAlpha = true
    @IBOutlet var tableView:UITableView!
    @IBOutlet var searchTextField:UITextField!
    @IBOutlet var searchView:UIView!
    let highlightSelectedRow = true
    let animatedScroll = false
    var selectedRow = -1
    var selectedId = -1
    
    func countForUnit(unit: Int) -> Int {
        let moc = self.fetchedResultsController.managedObjectContext
        if #available(iOS 10.0, *) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HQWords")
            fetchRequest.predicate = NSPredicate(format: "unit = %d", unit)
            fetchRequest.includesSubentities = false
            
            var entitiesCount = 0
            
            do {
                entitiesCount = try moc.count(for: fetchRequest)
                print("count: \(entitiesCount)")
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
    
    @objc func sortTogglePressed(_ sender: UIBarButtonItem ) {
        self.dismiss(animated: true, completion: nil)
        sortAlpha = !sortAlpha
        _fetchedResultsController = nil
        tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at:indexPath, at: .top, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        searchTextField.autocapitalizationType = .none
        searchTextField.autocorrectionType = .no
        searchTextField.clearButtonMode = .always
        searchTextField.contentVerticalAlignment = .center
        searchTextField.placeholder = "Search: "
        
        searchView.layer.borderColor = UIColor.black.cgColor
        searchView.layer.borderWidth = 2.0
        searchView.layer.cornerRadius = 20
        
        let searchFont = UIFont(name: "HelveticaNeue", size: 20.0)
        if #available(iOS 11.0, *) {
            //dynamic type
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            searchTextField?.font = fontMetrics.scaledFont(for: searchFont!)
            searchTextField?.adjustsFontForContentSizeCategory = true
        }
        else
        {
            searchTextField?.font = searchFont
        }
        
        //searchTextField?.inputView = kb?.inputView
        //searchTextField?.delegate = self
        
        //these 3 lines prevent undo/redo/paste from displaying above keyboard on ipad
        if #available(iOS 9.0, *)
        {
            let item: UITextInputAssistantItem = searchTextField!.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.datasync()
        
        let sortToggleBarButton = UIBarButtonItem(title: "Toggle Sort", style: .done, target: self, action: #selector(sortTogglePressed(_:)))
        self.navigationItem.rightBarButtonItem = sortToggleBarButton

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        for (u, _) in wordsPerUnit.enumerated()
        {
            wordsPerUnit[u] = countForUnit(unit: u+1)
            //NSLog("words per: \(u), \(wordsPerUnit[u])")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    @objc func textDidChange(_ notification: Notification) {
        //guard let textView = notification.object as? UITextField else { return }
        //print(textView.text ?? "abc")
        //scrollToWord()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTextField?.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !sortAlpha
        {
            return 34
        }
        else
        {
            return 0
        }
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

    func numberOfSections(in tableView: UITableView) -> Int {
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
            sortField = "seq"
        }
        else
        {
            sortField = "hqid"
            sectionField = "unit"
        }
        
        let sortDescriptor = NSSortDescriptor(key: sortField, ascending: true)
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event)
        // Configure the cell...

        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, withEvent gw: HQWords) {
        //cell.textLabel!.text = event.timestamp!.description
        //cell.textLabel!.text = "\(gw.hqid.description) \(gw.lemma!.description)"
        if !sortAlpha
        {
            cell.textLabel!.text = gw.lemma!.description
        }
        else
        {
            cell.textLabel!.text = gw.lemma!.description + " (" + gw.unit.description + ")"
        }
        
        let greekFont = UIFont(name: "NewAthenaUnicode", size: 24.0)
        cell.textLabel?.font = greekFont
        //cell.tag = Int(gw.wordid)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.init(red: 136/255.0, green: 153/255.0, blue: 238/255.0, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        
        performSegue(withIdentifier: "ShowVocabDetail", sender: self)
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
        searchTextField?.resignFirstResponder() //works for pad and phone
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let indexPath = tableView.indexPathForSelectedRow
        let object = fetchedResultsController.object(at: indexPath!)
        let wordid = Int(object.hqid)
        let vd = segue.destination as! VocabDetailViewController
        vd.hqid = wordid
    }
    
    func scrollToWord()
    {
        let rowCount = tableView.numberOfRows(inSection: 0)
        
        //There are zero rows
        if rowCount < 1
        {
            return;
        }
        
        let searchText = searchTextField?.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        var vc:NSManagedObjectContext
        if #available(iOS 10.0, *) {
            vc = delegate.persistentContainer.viewContext
        } else {
            vc = delegate.managedObjectContext
        }
        
        var seq = -1
        
        let request: NSFetchRequest<HQWords> = HQWords.fetchRequest()
        if #available(iOS 10.0, *) {
            request.entity = HQWords.entity()
        } else {
            request.entity = NSEntityDescription.entity(forEntityName: "HQWords", in: delegate.managedObjectContext)
        }
        
        let pred = NSPredicate(format: "(unaccentedWord >= %@)", searchText!)
        request.predicate = pred
        
        let sortDescriptor = NSSortDescriptor(key: "unaccentedWord", ascending: true)
        request.sortDescriptors = [sortDescriptor]
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
            seq = Int((results?[0].seq)!)
        }
        else
        {
            selectedRow = -1
            selectedId = -1
            NSLog("Error: Word not found by id.");
        }

        
        if seq < 1 || seq > rowCount
        {
            //NSLog("Scroll out of bounds: %d", seq);
            seq = rowCount;
        }
        
        let scrollIndexPath = NSIndexPath(row: (seq - 1), section: 0) as IndexPath
        //NSLog("scroll to: \(highlightSelectedRow)")
        if highlightSelectedRow
        {
            if seq == 1
            {
                tableView.scrollToRow(at: scrollIndexPath, at: UITableViewScrollPosition.middle, animated: animatedScroll)
                if let indexPath = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: indexPath, animated: animatedScroll)
                }
            }
            else
            {
                tableView.selectRow(at: scrollIndexPath, animated: animatedScroll, scrollPosition: UITableViewScrollPosition.middle)
            }
        }
        else
        {
            tableView.scrollToRow(at: scrollIndexPath, at: UITableViewScrollPosition.middle, animated: animatedScroll)
        }
    }
}

