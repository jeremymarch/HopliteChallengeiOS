//
//  RetroHomeMenuViewController.swift
//  HopliteChallenge
//
//  Created by Jeremy on 3/4/19.
//  Copyright © 2019 Jeremy March. All rights reserved.
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
    
    //var isDBInitialized = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let upgradeRes = copyFileFromBundle(bundledDBName: (UIApplication.shared.delegate as! AppDelegate).dbfile, extForFile: (UIApplication.shared.delegate as! AppDelegate).dbext)
        
        if upgradeRes > 0
        {
            let alertController = UIAlertController(title: "Database Upgrade Error", message:
                "Error upgrading database: error code \(upgradeRes)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
        print("upgrade result: \(upgradeRes)")
        
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
    
    func needToUpgradeDB() -> Bool
    {
        if FileManager.default.fileExists(atPath: (UIApplication.shared.delegate as! AppDelegate).dbpath) {
            return false
        }
        else
        {
            return true
        }
    }
    
    //return -1: no need to upgrade
    //return 0: upgrade successful
    //else return error code
    func copyFileFromBundle(bundledDBName: String, extForFile: String) -> Int {
        
        //let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let previousVersionDBName = "hcdatadb"
        
        if needToUpgradeDB() == false
        {
            print("no need to upgrade db")
            return -1
        }
        else
        {
            print("need to upgrade db")
        }
        
        guard let dbInBundleURL = Bundle.main.url(forResource: bundledDBName, withExtension: extForFile) else {
            print("Source File not found.")
            return 81
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let newDBURL = documentsURL!.appendingPathComponent((UIApplication.shared.delegate as! AppDelegate).dbfile).appendingPathExtension((UIApplication.shared.delegate as! AppDelegate).dbext)
        
        //copy db from bundle to documents directory
        do {
            try FileManager.default.copyItem(at: dbInBundleURL, to: newDBURL)
        } catch {
            print("Unable to copy file")
            return 82
        }
        print("copied db from bundle")
        
        let previousVersionURL = documentsURL!.appendingPathComponent(previousVersionDBName).appendingPathExtension(extForFile)
        
        //if previous version exists, import it in, then delete it.
        if FileManager.default.fileExists(atPath: previousVersionURL.path)
        {
            let upgradeRes = upgradedb(previousVersionURL.path, newDBURL.path)
            if upgradeRes != 0
            {
                print("Error upgrading db. Error code: \(upgradeRes)")
                return Int(upgradeRes)
            }
            
            do {
                try FileManager.default.removeItem(at: previousVersionURL)
            } catch {
                print(error)
                return 83
            }
        }
        print("Finished upgrading db")
        return 0
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
            dvc.filterViewHeightValue = 0.0//40.0
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
