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
    @IBOutlet var aboutButton:UIButton? = nil
    @IBOutlet var hopliteLabel:UILabel? = nil
    
    var isDBInitialized = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        playButton?.isHidden = true
        practiceButton?.isHidden = true
        playHistoryButton?.isHidden = true
        practiceHistoryButton?.isHidden = true
        
        DispatchQueue.global(qos: .background).async {
            let v = VerbSequence()
            if v.vsInit() == 0
            {
                self.isDBInitialized = true
                DispatchQueue.main.async {
                    self.playButton?.isHidden = false
                    self.practiceButton?.isHidden = false
                    self.playHistoryButton?.isHidden = false
                    self.practiceHistoryButton?.isHidden = false
                }
            }
        }
        */
        // Do any additional setup after loading the view.
        
        settingsButton?.layer.borderColor = UIColor.init(red: 0.0, green: 0.0, blue: 110.0, alpha: 1.0).cgColor
        settingsButton?.layer.borderWidth = 2.0
        settingsButton?.layer.cornerRadius = 5.0
        
        aboutButton?.layer.borderColor = UIColor.init(red: 0.0, green: 0.0, blue: 110.0, alpha: 1.0).cgColor
        aboutButton?.layer.borderWidth = 2.0
        aboutButton?.layer.cornerRadius = 5.0
        aboutButton?.isHidden = true
        
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
            //performSegue(withIdentifier: "HCSettingsSegue", sender: self)
        }
    }
    
    @objc func playButtonPressed(sender:UIButton)
    {
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "HopliteChallenge2") as? HopliteChallenge
        {
            dvc.vs.isHCGame = true
            self.navigationController?.pushViewController(dvc, animated: true)
        }
    }
    
    @objc func playHistoryButtonPressed(sender:UIButton)
    {
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "GameHistory") as? GameHistoryViewController
        {
            dvc.isHCGame = true
            self.navigationController?.pushViewController(dvc, animated: true)
        }
    }
    
    @objc func practiceButtonPressed(sender:UIButton)
    {
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "HopliteChallenge2") as? HopliteChallenge
        {
            dvc.vs.isHCGame = false
            self.navigationController?.pushViewController(dvc, animated: true)
        }
    }
    
    @objc func practiceHistoryButtonPressed(sender:UIButton)
    {
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "GameHistory") as? GameHistoryViewController
        {
            dvc.isHCGame = false
            self.navigationController?.pushViewController(dvc, animated: true)
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
            dvc.filterViewHeightValue = 30.0
            dvc.navTitle = "H&Q Verbs"
            dvc.segueDest = "synopsis"
            self.navigationController?.pushViewController(dvc, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        let indexPath = tableView.indexPathForSelectedRow
        //let id = indexPath.
        
        if let gr = segue.destination as? GameResultsViewController
        {
            let gameid = games[(indexPath?.row)!].id
            let score = games[(indexPath?.row)!].score
            
            gr.gameid = gameid
            if score < 0
            {
                gr.isHCGame = false
            }
            else
            {
                gr.isHCGame = true
            }
        } */
    }

}
