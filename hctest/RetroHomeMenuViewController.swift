//
//  RetroHomeMenuViewController.swift
//  HopliteChallenge
//
//  Created by Jeremy on 3/4/19.
//  Copyright © 2019 Jeremy March. All rights reserved.
//

import UIKit

class RetroHomeMenuViewController: UIViewController {
    @IBOutlet var playButton:UIButton? = nil
    @IBOutlet var playHistoryButton:UIButton? = nil
    @IBOutlet var practiceButton:UIButton? = nil
    @IBOutlet var practiceHistoryButton:UIButton? = nil
    @IBOutlet var verbFormsButton:UIButton? = nil
    @IBOutlet var settingsButton:UIButton? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        settingsButton?.layer.borderColor = UIColor.init(red: 0.0, green: 0.0, blue: 110.0, alpha: 1.0).cgColor
        settingsButton?.layer.borderWidth = 2.0
        settingsButton?.layer.cornerRadius = 5.0
        
        playButton?.addTarget(self, action: #selector(playButtonPressed), for: UIControl.Event.touchUpInside)
        playHistoryButton?.addTarget(self, action: #selector(playHistoryButtonPressed), for: UIControl.Event.touchUpInside)
        practiceButton?.addTarget(self, action: #selector(practiceButtonPressed), for: UIControl.Event.touchUpInside)
        practiceHistoryButton?.addTarget(self, action: #selector(practiceHistoryButtonPressed), for: UIControl.Event.touchUpInside)
        verbFormsButton?.addTarget(self, action: #selector(verbFormsButtonPressed), for: UIControl.Event.touchUpInside)
        settingsButton?.addTarget(self, action: #selector(settingsButtonPressed), for: UIControl.Event.touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func settingsButtonPressed(sender:UIButton)
    {
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "Settings") as? HCSettingsViewController
        {
            self.navigationController?.pushViewController(dvc, animated: true)
        }
    }
    
    @objc func playButtonPressed(sender:UIButton)
    {
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "HopliteChallenge2") as? HopliteChallenge
        {
            dvc.vs.isHCGame = true
            self.navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    @objc func playHistoryButtonPressed(sender:UIButton)
    {
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "GameHistory") as? GameHistoryViewController
        {
            dvc.isHCGame = true
            self.navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    @objc func practiceButtonPressed(sender:UIButton)
    {
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "HopliteChallenge2") as? HopliteChallenge
        {
            dvc.vs.isHCGame = false
            self.navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    @objc func practiceHistoryButtonPressed(sender:UIButton)
    {
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "GameHistory") as? GameHistoryViewController
        {
            dvc.isHCGame = false
            self.navigationController?.pushViewController(dvc, animated: false)
        }
    }
    //let dest = destViewController as! VocabTableViewController
    @objc func verbFormsButtonPressed(sender:UIButton)
    {
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "Vocabulary") as? VocabTableViewController
        {
            //we can set these values before showing
            dvc.sortAlpha = false
            dvc.predicate = "pos=='Verb'"
            dvc.selectedButtonIndex = 1
            dvc.filterViewHeightValue = 0.0
            dvc.navTitle = "H&Q Verbs"
            dvc.segueDest = "synopsis"
            self.navigationController?.pushViewController(dvc, animated: true)
        }
    }

}
