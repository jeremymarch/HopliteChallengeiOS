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
        
        hcsync()
    }
    
    func hcsync()
    {
        let url = "https://philolog.us/hcsync.php"
        
        let parameters:Dictionary<String, String> = ["type":"sync","playerID": String(vUserID)]
        
        NetworkManager.shared.sendReq(urlstr: url, requestData: parameters)
    }
    
    func datasync()
    {
        //let time = NSDate.init()
        var timestamp = 0 //time.timeIntervalSince1970
        
        let d = UserDefaults.standard
        let time = d.object(forKey: "LastUpdated")
        if time != nil
        {
            timestamp = time as! Int
        }
        else
        {
            d.set(timestamp, forKey: "LastUpdated")
            d.synchronize()
        }
        NSLog("Time: \(timestamp)")
        
        NSLog("START REQUEST")
        //http://benscheirman.com/2017/06/ultimate-guide-to-json-parsing-with-swift-4/
        //https://stackoverflow.com/questions/32631184/the-resource-could-not-be-loaded-because-the-app-transport-security-policy-requi
        
        //with password:https://gist.github.com/n8armstrong/5c5c828f1b82b0315e24
        let urlString = URL(string: "https://philolog.us/hqjson.php?lastupdated=\(timestamp)")//https://philolog.us/hqvocab.php?unit=20&AndUnder=on&sort=alpha")
        NSLog("Start timestamp: \(timestamp)")
        if let url = urlString {
            //let session = NSURLSession(configuration: .defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    NSLog("boo")
                    NSLog(error!.localizedDescription)
                } else {
                    if let usableData = data {
                        NSLog("yay")
                        if let stringData = String(data: usableData, encoding: String.Encoding.utf8) {
                            print(stringData) //JSONSerialization
                            do {
                                let decoder = JSONDecoder()
                                let rows = try decoder.decode(HQResponse.self, from: usableData)
                                
                                NSLog("Updated: \(rows.meta.updated)")
                                
                                DispatchQueue.main.sync {
                                    //https://stackoverflow.com/questions/46956921/main-thread-checker-ui-api-called-on-a-background-thread-uiapplication-deleg
                                    let backgroundContext = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
                                    //backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                                    //let backgroundContext = self.managedObjectContext
                                    backgroundContext.mergePolicy = NSRollbackMergePolicy //needed or duplicates x2
                                    if #available(iOS 10.0, *) {
                                        backgroundContext.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
                                    }
                                    else
                                    {
                                        backgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator
                                    }
                                    let entity = NSEntityDescription.entity(forEntityName: "HQWords", in: backgroundContext)
                                    /*
                                     let countFetch: NSFetchRequest<HQWords> = NSFetchRequest(entityName: "HQWords")
                                     do {
                                     let newCount = try backgroundContext.count(for: countFetch)
                                     NSLog("count1 \(newCount)")
                                     } catch { }
                                     */
                                    //var count = 0
                                    var highestTimestamp = 0;
                                    for row in rows.rows {
                                        //print("Row: \(row.id), \(row.lemma), \(row.unit)")
                                        /*
                                         if self.hqWordExists(id:row.id)
                                         {
                                         NSLog("duplicate \(row.id)")
                                         continue
                                         }
                                         */
                                        if row.lastupdated > highestTimestamp
                                        {
                                            highestTimestamp = row.lastupdated
                                        }
                                        
                                        let newWord = self.getWordObjectOrNew(hqid:row.id, context:backgroundContext)
                                        
                                        
                                        newWord.setValue(self.stripAccent(lemma: row.lemma), forKey: "sortkey")
                                        
                                        newWord.setValue(row.id, forKey: "hqid")
                                        newWord.setValue(row.unit, forKey: "unit")
                                        newWord.setValue(row.lemma, forKey: "lemma")
                                        newWord.setValue(row.def, forKey: "def")
                                        newWord.setValue(row.pos, forKey: "pos")
                                        newWord.setValue(row.present, forKey: "present")
                                        newWord.setValue(row.future, forKey: "future")
                                        newWord.setValue(row.aorist, forKey: "aorist")
                                        newWord.setValue(row.perfect, forKey: "perfect")
                                        newWord.setValue(row.perfectmid, forKey: "perfectmid")
                                        newWord.setValue(row.aoristpass, forKey: "aoristpass")
                                        newWord.setValue(row.note, forKey: "note")
                                        newWord.setValue(row.lastupdated, forKey: "lastupdated")
                                        newWord.setValue(row.seq, forKey: "seq")
                                    }
                                    do {
                                        if backgroundContext.hasChanges
                                        {
                                            NSLog("has changes!")
                                            try backgroundContext.save()
                                            //NSLog("Count: \(count)")
                                            if highestTimestamp > timestamp
                                            {
                                                UserDefaults.standard.set(highestTimestamp, forKey: "LastUpdated")
                                                NSLog("New timestamp: \(highestTimestamp)")
                                            }
                                        }
                                    } catch let error as NSError {
                                        print("failed saving: \(error.localizedDescription)")
                                    }
                                    
                                    let countFetch: NSFetchRequest<HQWords> = NSFetchRequest(entityName: "HQWords")
                                    do {
                                        let newCount = try backgroundContext.count(for: countFetch)
                                        NSLog("count2 \(newCount)")
                                    } catch { }
                                }
                                
                            } catch let error as NSError {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
            task.resume()
        }
        NSLog("End REQUEST")
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

