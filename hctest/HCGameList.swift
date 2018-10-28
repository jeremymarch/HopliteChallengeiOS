//
//  HCGameList.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 6/17/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//

import UIKit
import CoreData
/*
protocol HCGameChooserDelegate {
    func setSelectedGame(gameID: Int)
    func onDismissGameChooser()
}
*/
class HCGameListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    let hcblue:UIColor = UIColor(red: 0.0, green: 0.47, blue: 1.0, alpha: 1.0)
    let hcLightBlue:UIColor = UIColor(red: 140/255.0, green: 220/255.0, blue: 255/255.0, alpha: 1.0)
    let hcDarkBlue:UIColor = UIColor.init(red: 0, green: 0, blue: 110.0/255.0, alpha: 1.0)
    var vUserID = -1
    var navTitle = "Game List"

    @IBOutlet var tableView:UITableView!

    let highlightSelectedRow = true
    let animatedScroll = false
    
    let highlightedRowBGColor = UIColor.init(red: 66/255.0, green: 127/255.0, blue: 237/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = navTitle
        login()
        
        datasync()
        tableView.reloadData()
    }
    
    struct HCGameSyncResponse : Codable {
        struct Meta : Codable {
            let updated: Int
            enum CodingKeys : String, CodingKey {
                case updated = "updated"
            }
        }
        struct Row : Codable {
            let id: Int
            let lemma: String
            let unit: Int
            let def: String
            let pos: String
            let present:String
            let future:String
            let aorist:String
            let perfect:String
            let perfectmid:String
            let aoristpass:String
            let note:String
            let lastupdated:Int
            let seq:Int16
            enum CodingKeys : String, CodingKey {
                case id
                case lemma = "l"
                case unit = "u"
                case def = "d"
                case pos = "ps"
                case present = "p"
                case future = "f"
                case aorist = "a"
                case perfect = "pe"
                case perfectmid = "pm"
                case aoristpass = "ap"
                case note = "n"
                case lastupdated = "up"
                case seq = "s"
            }
        }
        let meta: Meta
        let rows: [Row]
    }
    
    func proc(newDict:Dictionary<String, String>, data:Data)->Bool
    {
        print("getupdates response 222: [\(String(decoding: data, as: UTF8.self))] end")
        do {
            //create json object from data
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                print("getupdates response: \(json)")
                
                if let statusResult = json["status"] as? Int {
                    if statusResult == 1
                    {
                        if let id:Int = json["gameID"] as? Int
                        {
                            print("game created.  id: " + String(id))
                            //addGame(game:newDict, gameID:id)
                        }
                        return true;
                    }
                    else
                    {
                        return false
                    }
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
            
        } catch let error {
            print("make json obj \(error.localizedDescription)")
            return false
        }
    }
    
    func datasync()
    {
        /*
         See list of available players to challenge.
         
         Challenge random opponent?
         0.5 get available players
         
         1. create game and make first move.
            Insert and retrieve new globalGameID with opposing player's ID and the game parameters.
            Insert first move with form requested.
            Send push notification to opponent
         
         2. Get updates:
            select games where globalGameIDs > lastStoredGameID and player1 = me or player2 = me;
            select moves where globalMoveIDs > lastStoredMoveID
            select userIDs of any users in the above
         
         3. answer move
            update row where globalMoveID = x
         
         4. make next move
            insert into moves set gameid = globalgameID
         
         
         xxxselect moves where globalGameID in (my list of active games), pull all higher move ids | where I am a player
 
         */
        print("getupdates 222")
        let url = "https://philolog.us/hc.php"
        let parameters:Dictionary<String, String> = ["type":"getupdates","playerID": String(vUserID),"lastGlobalGameID":String(1),"lastGobalMoveID":String(1)]
        
        NetworkManager.shared.sendReq(urlstr: url, requestData: parameters, queueOnFailure:false, processResult:proc)
    }
    
    func login()
    {
        let defaults = UserDefaults.standard
        defaults.set(1, forKey: "UserID")
        defaults.set("jeremy", forKey: "UserName")
        //defaults.set(2, forKey: "UserID")
        //defaults.set("william", forKey: "UserName")
        defaults.synchronize()
        
        if let a = UserDefaults.standard.object(forKey: "UserID") as! Int?
        {
            vUserID = a
            print("userID is: \(a)")
        }
    }
    
    func getGameCount() -> Int
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HCGame")
        do {
            let count = try DataManager.shared.mainContext?.count(for:fetchRequest)
            return count!
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        NSLog("FRC Count: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
        //return (fetchedResultsController.fetchedObjects?.count)!
    }
    
    var fetchedResultsController: NSFetchedResultsController<HCGame> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<HCGame> = HCGame.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        //let appDel = UIApplication.shared.delegate as! AppDelegate
        
        let sortDescriptor = NSSortDescriptor(key: "gameID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataManager.shared.mainContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<HCGame>? = nil
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let gw = fetchedResultsController.object(at: indexPath)
        configureCell(cell, lemma: gw.gameID.description)
        
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, lemma:String) {
        //cell.textLabel!.text = event.timestamp!.description
        //cell.textLabel!.text = "\(gw.hqid.description) \(gw.lemma!.description)"
            cell.textLabel!.text = lemma
        
    
        //cell.tag = Int(gw.wordid)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = highlightedRowBGColor
        cell.selectedBackgroundView = bgColorView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let btn = UIButton(type: UIButtonType.custom)
        //btn.tag = indexPath.row
        /*
        if delegate != nil
        {
            let object = fetchedResultsController.object(at: indexPath)
            let wordid = Int(object.hqid)
            delegate?.setSelectedVerb(verbID: wordid)
            //close
            self.presentingViewController?.dismiss(animated: true, completion:delegate?.onDismissVerbChooser)
        }
        else
        {
            performSegue(withIdentifier: "ShowVocabDetail", sender: self)
        }
        */
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
        /*
        searchTextField?.resignFirstResponder() //works for pad and phone
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let indexPath = tableView.indexPathForSelectedRow
        let object = fetchedResultsController.object(at: indexPath!)
        let wordid = Int(object.hqid)
        let vd = segue.destination as! VocabDetailViewController
        vd.hqid = wordid
 */
    }
}

