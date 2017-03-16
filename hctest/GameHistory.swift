//
//  GameHistory.swift
//  hctest
//
//  Created by Jeremy March on 3/15/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class GameHistoryViewController: UITableViewController {
    
    /**
     *  Array containing menu options
     */
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
     *  Delegate of the MenuVC
     */
    var delegate : SlideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("games history loaded")
        tableView?.delegate = self
        tableView?.dataSource = self
        title = "Game History"
        //tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateArrayMenuOptions()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func updateArrayMenuOptions(){
        NSLog("update array")
        arrayMenuOptions.append(["title":"Home", "icon":"HomeIcon"])
        arrayMenuOptions.append(["title":"Play", "icon":"PlayIcon"])
        
        tableView.reloadData()
        NSLog("update array2")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "GameHistoryCell")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        //let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        
        //imgIcon.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
        lblTitle.text = arrayMenuOptions[indexPath.row]["title"]!
        
        NSLog("menu: \(arrayMenuOptions[indexPath.row]["title"]!)")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        //self.onCloseMenuClick(btn)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("rows: \(arrayMenuOptions.count)")
        return arrayMenuOptions.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
}

