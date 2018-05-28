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
    @IBOutlet var searchToggleButton:UIButton!
    //var predicateWords:[(Int,Int,Int,String,String)] = []
    let highlightSelectedRow = true
    let animatedScroll = false
    var selectedRow = -1
    var selectedId = -1
    var usePrediate = true
    var kb:KeyboardViewController? = nil 
    
    let highlightedRowBGColor = UIColor.init(red: 66/255.0, green: 127/255.0, blue: 237/255.0, alpha: 1.0)
    
    func countForUnit(unit: Int) -> Int {
        let moc = self.fetchedResultsController.managedObjectContext
        if #available(iOS 10.0, *) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HQWords")
            if usePrediate
            {
                fetchRequest.predicate = NSPredicate(format: "unit = %d AND pos='Verb'", unit)
            }
            else
            {
                fetchRequest.predicate = NSPredicate(format: "unit = %d", unit)
            }
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
        searchTextField.text = ""
        _fetchedResultsController = nil
        tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at:indexPath, at: .top, animated: false)
        
        searchTextField.resignFirstResponder()
        if sortAlpha
        {
            searchTextField.inputView = kb?.inputView
            searchToggleButton.setTitle("Word: ", for: [])
        }
        else
        {
            searchTextField.inputView = nil
            searchTextField.keyboardType = .numberPad
            searchToggleButton.setTitle("Unit: ", for: [])
        }
        searchTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "H&Q Vocabulary"
        
        searchToggleButton.backgroundColor = UIColor.clear
        searchToggleButton.clipsToBounds = true
        searchToggleButton.setTitleColor(UIColor.black, for: .normal)
        searchToggleButton.titleLabel?.textAlignment = .right
        searchToggleButton.setTitle("Word: ", for: .normal)
        let titleFont = UIFont(name: "Helvetica-Bold", size: 18.0)
        if #available(iOS 11.0, *) {
            //dynamic type
            let fontMetrics = UIFontMetrics(forTextStyle: .body)
            searchToggleButton.titleLabel?.font = fontMetrics.scaledFont(for: titleFont!)
            searchToggleButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
        else
        {
            searchToggleButton.titleLabel?.font = titleFont
        }
        searchToggleButton.addTarget(self, action: #selector(sortTogglePressed(_:)), for: .touchDown)
        
        //add padding around button label

        searchToggleButton.contentEdgeInsets = UIEdgeInsets(top: 13.0, left: 8.0, bottom: 13.0, right: 2.0)
        
        searchTextField.autocapitalizationType = .none
        searchTextField.autocorrectionType = .no
        searchTextField.clearButtonMode = .always
        searchTextField.contentVerticalAlignment = .center
        //searchTextField.placeholder = "Search: "
        
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
        
        let greekKeys = [["ε", "ρ", "τ", "υ", "θ", "ι", "ο", "π"],
                         ["α", "σ", "δ", "φ", "γ", "η", "ξ", "κ", "λ"],
                         ["ζ", "χ", "ψ", "ω", "β", "ν", "μ", "BK"]]
        
        kb = KeyboardViewController() //kb needs to be member variable, can't be local to just this function
        kb?.appExt = false
        var portraitHeight:CGFloat = 250.0
        var landscapeHeight:CGFloat = 250.0
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            portraitHeight = 266.0
            landscapeHeight = 266.0
        }
        else
        {
            //iPhone X
            if UIScreen.main.nativeBounds.height == 2436.0 && UIScreen.main.nativeBounds.width == 1125.0
            {
                portraitHeight = 214.0
                landscapeHeight = portraitHeight
            }
            else if UIScreen.main.nativeBounds.width < 641
            {
                //for iphone 5s and narrower
                portraitHeight = 174.0
                landscapeHeight = portraitHeight
            }
            else //larger iPhones
            {
                portraitHeight = 174.0
                landscapeHeight = portraitHeight
            }
        }
        kb?.heightOverride = portraitHeight
        kb?.forceLowercase = true
        
        searchTextField?.inputView = kb?.inputView
        kb?.setButtons(keys: greekKeys) //has to be after set as inputView
        searchTextField?.delegate = self

        //these 3 lines prevent undo/redo/paste from displaying above keyboard on ipad
        if #available(iOS 9.0, *)
        {
            let item: UITextInputAssistantItem = searchTextField!.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        }
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        //move bottom of table up when keyboard shows, so we can access bottom rows and
        //also so selected row is in middle of screen - keyboard height.
        //https://stackoverflow.com/questions/594181/making-a-uitableview-scroll-when-text-field-is-selected/41040630#41040630
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    @objc func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? UITextField else { return }
        scrollToWord()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as?
            NSValue)?.cgRectValue.height {
            //the above doesn't work on ipad because we change the kb height later
            //let keyboardHeight = (kb?.portraitHeight)! //this works
            tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            // For some reason adding inset in keyboardWillShow is animated by itself but removing is not, that's why we have to use animateWithDuration here
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        })
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
            if usePrediate
            {
                return 19
            }
            else
            {
                return 20
            }
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
            if usePrediate
            {
                return wordsPerUnit[section + 1]
            }
            else
            {
                return wordsPerUnit[section]
            }
        }
        else
        {
            return (fetchedResultsController.fetchedObjects?.count)!
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
            sortField = "sortkey"
        }
        else
        {
            sortField = "hqid"
            sectionField = "unit"
        }
        
        if usePrediate
        {
            let pred = NSPredicate(format: "pos=='Verb'")
            fetchRequest.predicate = pred
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
        let gw = fetchedResultsController.object(at: indexPath)
        configureCell(cell, lemma: gw.lemma!.description, unit: gw.unit.description)

        return cell
    }
    
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
        bgColorView.backgroundColor = highlightedRowBGColor
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
            return
        }
        
        let searchText = searchTextField?.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        var seq = 0 //zero-indexed
        var unit = 0 //zero-indexed
        
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
            if usePrediate
            {
                pred = NSPredicate(format: "(sortkey < %@ AND pos=='Verb')", searchText!)
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
                pred = NSPredicate(format: "(sortkey >= %@)", searchText!)
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
                    selectedRow = -1
                    selectedId = -1
                    seq = rowCount - 1
                    NSLog("Error: Word not found by id.");
                }
            }
        }
        else //sort by unit
        {
            if searchText != nil && searchText! != ""
            {
                seq = 0
                unit = Int(searchText!)! - 1
            }
            else
            {
                unit = 0
                seq = 0
            }
            print("unit seq: \(seq), \(unit)")
        }
        
        if seq < 0
        {
            NSLog("Scroll out of bounds: %d", seq)
            seq = 0
        }
        else if seq >= rowCount
        {
            NSLog("Scroll out of bounds: %d", seq)
            seq = rowCount - 1
        }
        if unit < 0
        {
            unit = 0
        }
        else if unit > 19
        {
            unit = 19
        }
        
        let scrollIndexPath = NSIndexPath(row: seq, section: unit) as IndexPath
        //NSLog("scroll to: \(highlightSelectedRow)")
        if highlightSelectedRow && sortAlpha
        {
            if seq == 0 && searchText == ""
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
            if sortAlpha
            {
                tableView.scrollToRow(at: scrollIndexPath, at: UITableViewScrollPosition.middle, animated: animatedScroll)
            }
            else
            {
                tableView.scrollToRow(at: scrollIndexPath, at: UITableViewScrollPosition.top, animated: animatedScroll)
            }
            
        }
    }
}

