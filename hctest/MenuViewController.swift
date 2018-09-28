//
//  MenuViewController.swift
//  hctest
//
//  Created by Jeremy March on 3/14/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /**
     *  Array to display menu options
     */
    @IBOutlet var tblMenuOptions : UITableView?
    
    /**
     *  Transparent button to hide menu
     */
    @IBOutlet var btnCloseMenuOverlay : UIButton?
    
    /**
     *  Array containing menu options
     */
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
     *  Menu button which was tapped to display the menu
     */
    var btnMenu : UIButton!
    
    /**
     *  Delegate of the MenuVC
     */
    var delegate : SlideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblMenuOptions?.delegate = self
        tblMenuOptions?.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateArrayMenuOptions()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func updateArrayMenuOptions(){
        arrayMenuOptions.append(["title":"Play", "icon":"HomeIcon"])
        arrayMenuOptions.append(["title":"About", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"Settings", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"Game History", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"Verb List", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"Accents", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"Vocabulary", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"Cards", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"Exercises", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"Game", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"Game List", "icon":"PlayIcon"])
        
        tblMenuOptions!.reloadData()
    }
    
    @IBAction func onCloseMenuClick(_ button:UIButton!) {
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            let index = Int32(button.tag)
            //if(button == self.btnCloseMenuOverlay){
            //    index = -1
            //}
            //NSLog("menu click \(index)")
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        //let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        
        //imgIcon.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
        lblTitle.text = arrayMenuOptions[indexPath.row]["title"]!
        
        //NSLog("menu: \(arrayMenuOptions[indexPath.row]["title"]!)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.tag = indexPath.row
        self.onCloseMenuClick(btn)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //NSLog("rows: \(arrayMenuOptions.count)")
        return arrayMenuOptions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
}
