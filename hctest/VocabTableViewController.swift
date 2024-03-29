//
//  VocabTableViewController.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 11/25/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//
import UIKit
import CoreData

protocol VerbChooserDelegate {
    func setSelectedVerb(verbID: Int)
    func onDismissVerbChooser()
}

class VocabTableViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    let hcblue:UIColor = UIColor(red: 0.0, green: 0.47, blue: 1.0, alpha: 1.0)
    let hcLightBlue:UIColor = UIColor(red: 140/255.0, green: 220/255.0, blue: 255/255.0, alpha: 1.0)
    let hcDarkBlue:UIColor = UIColor.init(red: 0, green: 0, blue: 110.0/255.0, alpha: 1.0)
    var filterButtons:[UIButton] = []
    var selectedButtonIndex = 0
    var navTitle = "H&Q Vocabulary"
    var delegate:VerbChooserDelegate?
    @IBOutlet var filterButtonView:UIView!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var searchTextField:UITextField!
    @IBOutlet var searchView:UIView!
    @IBOutlet var searchToggleButton:UIButton!
    @IBOutlet var allButton:UIButton!
    @IBOutlet var verbButton:UIButton!
    @IBOutlet var nounButton:UIButton!
    @IBOutlet var adjectiveButton:UIButton!
    @IBOutlet var otherButton:UIButton!
    @IBOutlet var filterViewHeight:NSLayoutConstraint!
    var filterViewHeightValue:CGFloat = 43.0 //so we can show filter or not
    let highlightSelectedRow = true
    let animatedScroll = false
    var selectedRow = -1
    var selectedId = -1
    var predicate = ""
    var sortAlpha = false
    //var kb:KeyboardViewController? = nil
    var kb:minimalGreekKB? = nil
    var segueDest:String = ""
    var dataSource:VocabDataSourceProtocol?
    
    let highlightedRowBGColor = GlobalTheme.rowHighlightBG // UIColor.init(red: 66/255.0, green: 127/255.0, blue: 237/255.0, alpha: 1.0)
    
    func resetColors()
    {
        GlobalTheme = (isDarkMode()) ? DarkTheme.self : DefaultTheme.self
        //UINavigationBar.appearance().tintColor = GlobalTheme.primaryText
        navigationController?.navigationBar.tintColor  = GlobalTheme.primaryText
        
        searchView.layer.borderColor = GlobalTheme.primaryText.cgColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true
            {
                resetColors()
                self.tableView.reloadData()
            }
        }
    }

    
    @objc func filterButtonPressed(_ sender: UIButton ) {
        //self.dismiss(animated: true, completion: nil)
        
        if sender.titleLabel?.text == "Verb"
        {
            selectedButtonIndex = 1
            dataSource!.predicate = "LOWER(pos)=='verb'"
        }
        else if sender.titleLabel?.text == "Noun"
        {
            selectedButtonIndex = 2
            dataSource!.predicate = "LOWER(pos)=='noun'"
        }
        else if sender.titleLabel?.text == "Adjective"
        {
            selectedButtonIndex = 3
            dataSource!.predicate = "LOWER(pos)=='adjective'"
        }
        else if sender.titleLabel?.text == "Other"
        {
            selectedButtonIndex = 4
            dataSource!.predicate = "LOWER(pos)!='adjective' AND LOWER(pos)!='noun' AND LOWER(pos)!='verb'"
        }
        else if sender.titleLabel?.text == "All"
        {
            selectedButtonIndex = 0
            dataSource!.predicate = ""
        }
        
        dataSource!.filter()
        self.tableView.reloadData()
        
        if (self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0) {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at:indexPath, at: .top, animated: false)
        }
        setFilterButtons()
        
        scrollToWord()
    }
    
    @objc func sortTogglePressed(_ sender: UIButton ) {
        //self.dismiss(animated: true, completion: nil)
        
        sortAlpha = !dataSource!.sortAlpha
        let d = UserDefaults.standard
        d.set(sortAlpha, forKey: "sortAlpha")
        d.synchronize()
        dataSource!.sortAlpha = sortAlpha
        
        searchTextField.text = ""
        
        dataSource!.resort()
        self.tableView.reloadData()
        
        if (self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0) {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at:indexPath, at: .top, animated: false)
        }
        searchTextField.resignFirstResponder()
        setSortToggleButton()
        searchTextField.becomeFirstResponder()
    }
    
    func setSortToggleButton()
    {
        if dataSource!.sortAlpha
        {
            searchTextField.inputView = kb?.inputView
            searchToggleButton.setTitle("Word: ", for: [])
        }
        else
        {
            searchTextField.inputView = nil
            searchTextField.keyboardType = .numberPad
            //searchTextField.reloadInputViews()
            searchToggleButton.setTitle("Unit: ", for: [])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if dataSource!.sortAlpha {
            return 0.0
        } else {
            return 34.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetColors()
        
        //dataSource = VocabListDataSourceCoreData(sortAlpha:sortAlpha, predicate:predicate)
        dataSource = VocabListDataSourceSqlite(sortAlpha:sortAlpha, predicate:predicate)
        
        tableView.sectionHeaderHeight = 34.0
        tableView.dataSource = dataSource!
        tableView.delegate = self
        tableView.reloadData()
        
        filterViewHeight.constant = filterViewHeightValue
        if filterViewHeightValue == 0.0
        {
            filterButtonView.isHidden = true
        }
        
        self.navigationItem.title = navTitle
        
        filterButtons.append(allButton)
        filterButtons.append(verbButton)
        filterButtons.append(nounButton)
        filterButtons.append(adjectiveButton)
        filterButtons.append(otherButton)
        
        setFilterButtons()
        
        searchToggleButton.clipsToBounds = true
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
        allButton.addTarget(self, action: #selector(filterButtonPressed(_:)), for: .touchDown)
        verbButton.addTarget(self, action: #selector(filterButtonPressed(_:)), for: .touchDown)
        nounButton.addTarget(self, action: #selector(filterButtonPressed(_:)), for: .touchDown)
        adjectiveButton.addTarget(self, action: #selector(filterButtonPressed(_:)), for: .touchDown)
        otherButton.addTarget(self, action: #selector(filterButtonPressed(_:)), for: .touchDown)
        
        //add padding around button label

        searchToggleButton.contentEdgeInsets = UIEdgeInsets(top: 13.0, left: 8.0, bottom: 13.0, right: 2.0)
        
        searchTextField.autocapitalizationType = .none
        searchTextField.autocorrectionType = .no
        searchTextField.clearButtonMode = .always
        searchTextField.contentVerticalAlignment = .center
        //searchTextField.placeholder = "Search: "
        
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
        
        /*let greekKeys = [["ε", "ρ", "τ", "υ", "θ", "ι", "ο", "π"],
                         ["α", "σ", "δ", "φ", "γ", "η", "ξ", "κ", "λ"],
                         ["ζ", "χ", "ψ", "ω", "β", "ν", "μ", "BK"]]*/
        
        //kb = KeyboardViewController() //kb needs to be member variable, can't be local to just this function
        kb = minimalGreekKB(isAppExtension: false)

        
        searchTextField?.inputView = kb?.inputView
        //kb?.setButtons(keys: greekKeys) //has to be after set as inputView
        searchTextField?.delegate = self

        //these 3 lines prevent undo/redo/paste from displaying above keyboard on ipad
        if #available(iOS 9.0, *)
        {
            let item: UITextInputAssistantItem = searchTextField!.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        }
        
        //let delegate = UIApplication.shared.delegate as! AppDelegate
        //delegate.datasync()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //dataSource.setWordsPerUnit()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: nil)
        
        //move bottom of table up when keyboard shows, so we can access bottom rows and
        //also so selected row is in middle of screen - keyboard height.
        //https://stackoverflow.com/questions/594181/making-a-uitableview-scroll-when-text-field-is-selected/41040630#41040630
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        setSortToggleButton()
        setFilterButtons()
    }
    
    func setFilterButtons()
    {
        for i in 0...filterButtons.count - 1
        {
            if i == selectedButtonIndex
            {
                filterButtons[i].backgroundColor = GlobalTheme.secondaryBG
                filterButtons[i].layer.borderColor = GlobalTheme.secondaryBG.cgColor
                filterButtons[i].layer.borderWidth = 0.5
                filterButtons[i].setTitleColor(UIColor.white, for: [])
            }
            else
            {
                filterButtons[i].backgroundColor = hcLightBlue
                filterButtons[i].layer.borderColor = GlobalTheme.secondaryBG.cgColor
                filterButtons[i].layer.borderWidth = 0.5
                filterButtons[i].setTitleColor(GlobalTheme.secondaryBG, for: [])
            }
        }
    }
    
    @objc func textDidChange(_ notification: Notification) {
        //guard let textView = notification.object as? UITextField else { return }
        scrollToWord()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
            NSValue)?.cgRectValue.height {
            //the above doesn't work on ipad because we change the kb height later
            //let keyboardHeight = (kb?.portraitHeight)! //this works
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            // For some reason adding inset in keyboardWillShow is animated by itself but removing is not, that's why we have to use animateWithDuration here
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTextField?.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if !dataSource!.sortAlpha
        {
            let label = UILabel()
            label.text = "  Unit \(dataSource!.unitSections[section])"
            
            label.backgroundColor = GlobalTheme.secondaryBG// hcDarkBlue
            label.textColor = GlobalTheme.secondaryText
            return label
        }
        else
        {
            return nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let att = [ NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 20)! ]
        self.navigationController?.navigationBar.titleTextAttributes = att
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let btn = UIButton(type: UIButtonType.custom)
        //btn.tag = indexPath.row
        
        if delegate != nil //if it's acting as a verb chooser
        {
            let wordid = dataSource!.getSelectedId(path:indexPath)
            delegate?.setSelectedVerb(verbID: wordid)
            //close
            self.presentingViewController?.dismiss(animated: true, completion:delegate?.onDismissVerbChooser)
        }
        else //to see detail
        {
            if segueDest == "synopsis"
            {
                performSegue(withIdentifier: "showVerbDetail2", sender: self)
            }
            else
            {
                performSegue(withIdentifier: "ShowVocabDetail", sender: self)
            }
        }
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
        if let indexPath = tableView.indexPathForSelectedRow
        {
            let wordid = dataSource!.getSelectedId(path:indexPath)
            if segueDest == "synopsis"
            {
                let vd = segue.destination as! VerbDetailViewController
                vd.verbIndex = wordid
            }
            else
            {
                let vd = segue.destination as! VocabDetailViewController
                vd.hqid = wordid
            }
        }
    }
    
    func scrollToWord()
    {
        if self.tableView.numberOfSections < 1 || self.tableView.numberOfRows(inSection: 0) < 1
        {
            return
        }
        
        let rowCount = self.tableView.numberOfRows(inSection: 0)
        
        let searchText = searchTextField?.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        var seq = 0 //zero-indexed
        var unit = 0 //zero-indexed
        
        dataSource!.getScrollSeq(searchText:searchText!, seq: &seq, unit: &unit)
        
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
        else if unit > dataSource!.unitSections.last!
        {
            unit = dataSource!.unitSections.last!
        }
        
        let scrollIndexPath = NSIndexPath(row: seq, section: unit) as IndexPath
        //NSLog("scroll to: \(highlightSelectedRow)")
        if highlightSelectedRow && dataSource!.sortAlpha
        {
            if seq == 0 && searchText == ""
            {
                tableView.scrollToRow(at: scrollIndexPath, at: UITableView.ScrollPosition.middle, animated: animatedScroll)
                if let indexPath = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: indexPath, animated: animatedScroll)
                }
            }
            else
            {
                tableView.selectRow(at: scrollIndexPath, animated: animatedScroll, scrollPosition: UITableView.ScrollPosition.middle)
            }
        }
        else
        {
            if dataSource!.sortAlpha
            {
                tableView.scrollToRow(at: scrollIndexPath, at: UITableView.ScrollPosition.middle, animated: animatedScroll)
            }
            else
            {
                tableView.scrollToRow(at: scrollIndexPath, at: UITableView.ScrollPosition.top, animated: animatedScroll)
            }
            
        }
    }
}

