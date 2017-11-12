//
//  HCSettings.swift
//  hctest
//
//  Created by Jeremy March on 3/17/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class HCSettingsViewController: UITableViewController {
    
    var toggleStates = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        
        let def = UserDefaults.standard.object(forKey: "Levels")
        if def != nil
        {
            var i = 0
            for d in def as! [Bool]
            {
                toggleStates[i] = d
                i += 1
            }
        }
        else
        {
            let d = UserDefaults.standard
            d.set(toggleStates, forKey: "Levels")
            d.synchronize()
        }
        
        title = "Settings"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        cell.accessoryType = UITableViewCellAccessoryType.none
        
        let switchView = UISwitch()
        cell.accessoryView = switchView
        switchView.setOn(toggleStates[indexPath.row], animated: true)
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        
        lblTitle.text = "Unit \((indexPath.row + 1))"
        
        return cell
    }
    
    @objc func switchChanged(sender:UIView)
    {
        let switch1 = sender as! UISwitch
        let indexPath = tableView.indexPath(for: switch1.superview as! UITableViewCell)
        let on = switch1.isOn
        
        toggleStates[(indexPath?.row)!] = on
        
        let defaults = UserDefaults.standard
        defaults.set(toggleStates, forKey: "Levels")
        defaults.synchronize()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        
        //performSegue(withIdentifier: "SegueToVerbDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.text = "  Unit \(section + 1)"
        
        label.backgroundColor = UIColor.blue
        label.textColor = UIColor.white
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    */
    /*
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
 */
}

