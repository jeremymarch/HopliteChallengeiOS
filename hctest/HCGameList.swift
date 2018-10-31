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
        //tableView.reloadData()
    }

    
    func getPlayerObject(playerID: Int, context:NSManagedObjectContext) -> NSManagedObject?
    {
        if playerID < 1
        {
            return nil
        }
        
        let request: NSFetchRequest<HCPlayer> = HCPlayer.fetchRequest()
        if #available(iOS 10.0, *) {
            request.entity = HCPlayer.entity()
        } else {
            request.entity = NSEntityDescription.entity(forEntityName: "HCPlayer", in: context)
        }
        let pred = NSPredicate(format: "(playerID = %d)", playerID)
        request.predicate = pred
        var results:[Any]?
        do {
            results = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
        } catch let error {
            NSLog("Error: %@", error.localizedDescription)
            return nil
        }
        if results != nil && results!.count > 0
        {
            return results?.first as? NSManagedObject
        }
        else
        {
            return nil
        }
    }
    
    struct HCGameRow : Codable {
        let gameID: Int64
        let player1: Int
        let player2: Int
        let topunit: Int
        let timelimit: Int
        let gamestate: Int
        
        enum CodingKeys : String, CodingKey {
            case gameID = "gameid"
            case player1 = "player1"
            case player2 = "player2"
            case topunit = "topunit"
            case timelimit = "timelimit"
            case gamestate = "gamestate"
        }
    }
    
    struct HCMoveRow : Codable {
        let moveID: Int64
        let gameID: Int64
        let askPlayerID: Int
        let answerPlayerID: Int
        let person: Int
        let number: Int
        let tense: Int
        let voice: Int
        let mood: Int
        let verbID: Int
        
        enum CodingKeys : String, CodingKey {
            case moveID = "moveid"
            case gameID = "gameid"
            case askPlayerID = "askPlayerID"
            case answerPlayerID = "answerPlayerID"
            case person = "person"
            case number = "number"
            case tense = "tense"
            case voice = "voice"
            case mood = "mood"
            case verbID = "verbID"
        }
    }
    
    struct HCPlayerRow : Codable {
        let playerID: Int
        let playerName: String
        
        enum CodingKeys : String, CodingKey {
            case playerID = "playerid"
            case playerName = "playername"
        }
    }

    func saveSyncedGames(games:[HCGameRow])
    {
        let moc = DataManager.shared.backgroundContext!
        
        for game in games
        {
            let object = NSEntityDescription.insertNewObject(forEntityName: "HCGame", into: moc) as! HCGame
            
            object.gameID = Int64(game.gameID)
            object.topUnit = Int16(game.topunit)
            object.timeLimit = Int16(game.timelimit)
            object.player1ID = Int32(game.player1)
            object.player2ID = Int32(game.player2)
            object.gameState = 1
        }

        do {
            try moc.save()
            print("saved moc")
        } catch {
            print("couldn't save game")
        }
        
        //print("count: \(getGameCount())")
    }
    
    
    func saveSyncedMoves(moves:[HCMoveRow])
    {
        let moc = DataManager.shared.backgroundContext!
        
        for move in moves
        {
             let moveObj = NSEntityDescription.insertNewObject(forEntityName: "HCMoves", into: moc) as! HCMoves
             moveObj.gameID = Int64(move.gameID)
             moveObj.moveID = Int64(move.moveID)
             moveObj.verbID = Int32(move.verbID)
             moveObj.person = Int16(move.person)
             moveObj.number = Int16(move.number)
             moveObj.tense = Int16(move.tense)
             moveObj.voice = Int16(move.voice)
             moveObj.mood = Int16(move.mood)
            moveObj.askPlayerID = Int32(move.askPlayerID)
            moveObj.answerPlayerID = Int32(move.answerPlayerID)
        }
        
        do {
            try moc.save()
            print("saved moc")
        } catch {
            print("couldn't save move")
        }
        
        //print("count: \(getGameCount())")
    }
    
    func saveSyncedPlayers(players:[HCPlayerRow])
    {
        let moc = DataManager.shared.backgroundContext!
        
        for player in players
        {
            let playerObj = NSEntityDescription.insertNewObject(forEntityName: "HCPlayer", into: moc) as! HCPlayer
            playerObj.playerID = Int32(player.playerID)
            playerObj.userName = player.playerName
        }
        
        do {
            try moc.save()
            print("saved moc")
        } catch {
            print("couldn't save player")
        }
        
        //print("count: \(getGameCount())")
    }
    
    struct HCSyncResponse : Codable {
        /*
        struct Meta : Codable {
            let updated: Int
            enum CodingKeys : String, CodingKey {
                case updated = "updated"
            }
        }*/

        //let meta: Meta
        let status:Int
        let lastUpdated:Int
        let requestLastUpdated:Int
        let gameRows: [HCGameRow]
        let moveRows: [HCMoveRow]
        let playerRows: [HCPlayerRow]
    }
    
    func processResponse(requestParams:Dictionary<String, String>, responseData:Data)->Bool
    {
        print("getupdates response 222: [\(String(decoding: responseData, as: UTF8.self))] end")
        
        let decoder = JSONDecoder()
        do {
            let rows = try decoder.decode(HCSyncResponse.self, from: responseData)
            print("games: \(rows.gameRows.count)")
            if rows.status != 1
            {
                return false
            }
            saveSyncedGames(games: rows.gameRows)
            saveSyncedPlayers(players: rows.playerRows)
            saveSyncedMoves(moves: rows.moveRows)
            
            
            print("returned lastUpdated \(rows.lastUpdated)")
            setLastUpdated(lastUpdated: Int32(rows.lastUpdated))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                print("here222")
                self.tableView.reloadData()
            }
            
        } catch let error {
            print("hc sync codeable error: \(error.localizedDescription)")
            return false
        }

        
        return true
        /*
        do {
            //create json object from data
            if let json = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
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
        */
    }
    
    /* using swift generics, only iOS 10+
    func getWordObjectOrNew<T: NSManagedObject>(hqid: Int, type:T, context:NSManagedObjectContext) -> NSManagedObject
    {
        if let w = getWordObject(hqid: hqid, type:type, context:context)
        {
            return w
        }
        else
        {
            let entity = NSEntityDescription.entity(forEntityName: type.entity.name!, in: context)
            return NSManagedObject(entity: entity!, insertInto: context)
        }
    }
    
    func getWordObject<T: NSManagedObject>(hqid: Int, type:T, context:NSManagedObjectContext) -> NSManagedObject?
    {
        let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.entity = T.entity()
        let pred = NSPredicate(format: "(hqid = %d)", hqid)
        fetchRequest.predicate = pred
        var results:[Any]?
        do {
            results = try context.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        } catch let error {
            NSLog("Error: %@", error.localizedDescription)
            return nil
        }
        if results != nil && results!.count > 0
        {
            return results?.first as? NSManagedObject
        }
        else
        {
            return nil
        }
    }
    */
    
    func getCoreDataObjectOrNew(globalID: Int, entityType:String, context:NSManagedObjectContext) -> NSManagedObject?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityType)
        fetchRequest.predicate = NSPredicate(format: "globalID = %d", globalID)
        var results:[Any]?
        do {
            results = try context.fetch(fetchRequest)
        } catch let error {
            NSLog("Error: %@", error.localizedDescription)
            return nil
        }
        
        if results != nil && results!.count > 0
        {
            return results?.first as? NSManagedObject
        }
        else
        {
            let entity = NSEntityDescription.entity(forEntityName: entityType, in: context)
            return NSManagedObject(entity: entity!, insertInto: context)
        }
    }
    
    func getLastUpdated() -> Int32
    {
        let moc = DataManager.shared.backgroundContext!
        
        let request: NSFetchRequest<HCMeta> = HCMeta.fetchRequest()
        if #available(iOS 10.0, *) {
            request.entity = HCMeta.entity()
        } else {
            request.entity = NSEntityDescription.entity(forEntityName: "HCMeta", in: moc)
        }
        let pred = NSPredicate(format: "(metaID = %d)", 1)
        request.predicate = pred
        var results:[Any]?
        do {
            results = try moc.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
        } catch let error {
            NSLog("Error: %@", error.localizedDescription)
            return 0
        }
        if results != nil && results!.count > 0
        {
            let h = results?.first as? HCMeta
            return h!.lastUpdated
        }
        else
        {
            return 0
        }
    }
    
    func setLastUpdated(lastUpdated:Int32)
    {
        let moc = DataManager.shared.backgroundContext!
        
        let request: NSFetchRequest<HCMeta> = HCMeta.fetchRequest()
        if #available(iOS 10.0, *) {
            request.entity = HCMeta.entity()
        } else {
            request.entity = NSEntityDescription.entity(forEntityName: "HCMeta", in: moc)
        }
        let pred = NSPredicate(format: "(metaID = %d)", 1)
        request.predicate = pred
        var results:[Any]?
        do {
            results = try moc.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
        } catch let error {
            NSLog("Error: %@", error.localizedDescription)
        }
        var metaObj:HCMeta?
        if results != nil && results!.count > 0
        {
            metaObj = results?.first as? HCMeta
        }
        else
        {
            metaObj = NSEntityDescription.insertNewObject(forEntityName: "HCMeta", into: moc) as? HCMeta
        }
        metaObj?.metaID = 1
        metaObj?.lastUpdated = lastUpdated
        
        do {
            try moc.save()
            print("saved moc")
        } catch {
            print("couldn't save player")
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
 
         1 moves needs to pull answers too
         2 we need to pull by timestamp because game scores will be updated...
         3 make move table, so we can see that.
         4 add unique constraint
         
         insert or update? for all
         */
        let timestamp = getLastUpdated()
        
        NSLog("Time: \(timestamp)")
        
        print("getupdates 222")
        let url = "https://philolog.us/hc.php"
        let parameters:Dictionary<String, String> = ["type":"getupdates","playerID": String(vUserID),"lastGlobalGameID":String(1),"lastGobalMoveID":String(1),"lastUpdated":String(timestamp)]
        
        NetworkManager.shared.sendReq(urlstr: url, requestData: parameters, queueOnFailure:false, processResult:processResponse)
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
        configureCell(cell, gameID: Int(gw.gameID.description)!, opponentID:Int(gw.player2ID.description)!)
        
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, gameID:Int, opponentID:Int) {
        //cell.textLabel!.text = event.timestamp!.description
        //cell.textLabel!.text = "\(gw.hqid.description) \(gw.lemma!.description)"
        let moc = DataManager.shared.backgroundContext!
        if let p = getPlayerObject(playerID: opponentID, context: moc) as? HCPlayer
        {
            cell.textLabel!.text = "\(gameID) versus \(p.userName ?? "?")"
        }
        else
        {
            cell.textLabel!.text = "\(gameID) versus ?"
        }
    
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


