//
//  VerbList.swift
//  hctest
//
//  Created by Jeremy March on 3/15/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class VerbListViewController: UITableViewController {
    
    var items = [String]()
    let verbsPerSection:[Int] = [2,2,4,4,4,4,3,2,4,6,7,8,8,8,8,8,7,9,9,7]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        
        title = "Verbs"
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        
        performSegue(withIdentifier: "SegueToVerbDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return verbsPerSection[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 20//verbsPerSection.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let label = UILabel()
        label.text = "  Unit \(section + 1)"

        label.backgroundColor = UIColor.init(red: 0, green: 0, blue: 110.0/255.0, alpha: 1.0)
        label.textColor = UIColor.white
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
}

