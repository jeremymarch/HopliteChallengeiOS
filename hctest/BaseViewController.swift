//
//  BaseViewController.swift
//  hctest
//
//  Created by Jeremy March on 3/14/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, SlideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        //let topViewController : UIViewController = self.navigationController!.topViewController!
        //print("View Controller is : \(topViewController) \n", terminator: "")
        switch (index) {
        case 0:
            self.openViewControllerBasedOnIdentifier("HopliteChallenge",p:"")
        case 1:
            //about
            self.openViewControllerBasedOnIdentifier("HopliteChallenge",p:"")
        case 2:
            //settings
            self.openViewControllerBasedOnIdentifier("Settings",p:"")
        case 3:
            self.openViewControllerBasedOnIdentifier("GameHistory",p:"")
        case 4:
            self.openViewControllerBasedOnIdentifier("Vocabulary",p:"verbs")
        case 5:
            self.openViewControllerBasedOnIdentifier("Accents",p:"")
        case 6:
            self.openViewControllerBasedOnIdentifier("Vocabulary",p:"")
        case 7:
            self.openViewControllerBasedOnIdentifier("CardView",p:"")
        case 8:
            self.openViewControllerBasedOnIdentifier("ExercisesView",p:"")
        case 9:
            self.openViewControllerBasedOnIdentifier("HCGame",p:"")
        case 10:
            self.openViewControllerBasedOnIdentifier("HCGameList",p:"")
        default:
            //NSLog("default")
            break
        }
    }
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String, p:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        let topViewController : UIViewController = self.navigationController!.topViewController!
        if topViewController.restorationIdentifier! == destViewController.restorationIdentifier!
        {
            //print("Same VC")
        }
        else
        {
            if strIdentifier == "Vocabulary"
            {
                let dest = destViewController as! VocabTableViewController
                if p == "verbs"
                {
                    //we can set these values before showing
                    dest.sortAlpha = false
                    dest.predicate = "LOWER(pos)=='verb'"
                    dest.selectedButtonIndex = 1
                    dest.filterViewHeightValue = 0.0
                    dest.navTitle = "Verbs"
                    dest.segueDest = "synopsis"
                }
                else
                {
                /*
                 //we can set these values before showing
                dest.sortAlpha = false
                dest.predicate = "LOWER(pos)=='verb'"
                dest.selectedButtonIndex = 1
                dest.filterViewHeightValue = 0.0
                dest.navTitle = "Verbs"
                dest.segueDest = "synopsis"
                */
                }
                self.navigationController!.pushViewController(dest, animated: true)
            }
            else if strIdentifier == "VerbList"
            {
                let dest = destViewController as! VocabTableViewController
                
 
                self.navigationController!.pushViewController(dest, animated: true)
            }
            else if strIdentifier == "HopliteChallenge"
            {
                let dest = destViewController as! HopliteChallenge
                dest.vs.isHCGame = false
                
                self.navigationController!.pushViewController(dest, animated: true)
            }
            else
            {
                self.navigationController!.pushViewController(destViewController, animated: true)
            }
        }
    }
    
    func addSlideMenuButton() {
        let btnShowMenu = UIButton(type: UIButton.ButtonType.system)
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControl.State())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    
    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return defaultMenuImage;
    }
    
    @objc func onSlideMenuButtonPressed(_ sender : UIButton){
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChild(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
        }, completion:nil)
    }
}
