//
//  VerbList.swift
//  hctest
//
//  Created by Jeremy March on 3/15/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
import CoreData

class VerbListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,UITextFieldDelegate {
    var sortAlpha = true
    @IBOutlet var tableView:UITableView!
    @IBOutlet var searchTextField:UITextField!
    @IBOutlet var searchView:UIView!
    @IBOutlet var searchToggleButton:UIButton!
    var kb:KeyboardViewController? = nil
    var items = [String]()
    let verbsPerSection:[Int] = [2,2,4,4,4,4,3,2,4,6,7,10,8,13,8,9,7,11,10,7]
    
    @objc func sortTogglePressed(_ sender: UIBarButtonItem ) {
        self.dismiss(animated: true, completion: nil)
        sortAlpha = !sortAlpha
        searchTextField.text = ""
        //_fetchedResultsController = nil
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
        
        title = "Verbs"
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        //move bottom of table up when keyboard shows, so we can access bottom rows and
        //also so selected row is in middle of screen - keyboard height.
        //https://stackoverflow.com/questions/594181/making-a-uitableview-scroll-when-text-field-is-selected/41040630#41040630
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    @objc func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? UITextField else { return }
        //scrollToWord()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateArray()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func updateArray(){
        
        let mirror = Mirror(reflecting: verbs)
        for (_, value) in mirror.children {
            switch value {
            case is Verb:
                var s:String = String(cString: (value as! Verb).present)
                if s.count < 1
                {
                    s = String(cString: (value as! Verb).future)
                }
                items.append(s)
            default: ()
            }
        }
 
        /*
        for i in 0..<NUM_VERBS
        {
            let v = Verb2(verbid: Int(i))
            var s:String = v.present
            if s.characters.count < 1
            {
                s = v.future
            }
            items.append(s)
            
        }
        */
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "VerbListCell")!

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        
        var index = 0
        for i in 0..<indexPath.section
        {
            index += verbsPerSection[i]
        }
        index += indexPath.row
        
        lblTitle.text = items[index]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        
        performSegue(withIdentifier: "SegueToVerbDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return verbsPerSection[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 20//verbsPerSection.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let label = UILabel()
        label.text = "  Unit \(section + 1)"

        label.backgroundColor = UIColor.init(red: 0, green: 0, blue: 110.0/255.0, alpha: 1.0)
        label.textColor = UIColor.white
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        var verbIndex = 0
        for i in 0..<(indexPath?.section)!
        {
            verbIndex += verbsPerSection[i]
        }
        verbIndex += (indexPath?.row)!
        let vd = segue.destination as! VerbDetailViewController
        vd.verbIndex = verbIndex
    }
    /*
    func scrollToWord()
    {
        let rowCount = tableView.numberOfRows(inSection: 0)
        
        //There are zero rows
        if rowCount < 1
        {
            return;
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
            
            let pred = NSPredicate(format: "(sortkey >= %@)", searchText!)
            request.predicate = pred
            
            let sortDescriptor = NSSortDescriptor(key: "sortkey", ascending: true)
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
        else
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
    */
}

