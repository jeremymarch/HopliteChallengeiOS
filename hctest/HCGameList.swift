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
    var navTitle = "Hoplite Challenge"
    
    let checkImage = UIImage(named:"circlegreen.png")
    let xImage = UIImage(named:"circlered.png")

    @IBOutlet var newGameButton:UIButton!
    @IBOutlet var tableView:UITableView!

    let highlightSelectedRow = true
    let animatedScroll = false
    
    let highlightedRowBGColor = UIColor.init(red: 66/255.0, green: 127/255.0, blue: 237/255.0, alpha: 1.0)
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        // Do your job, when done:
        datasync()
        refreshControl.endRefreshing() //move to end of processResponse function?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //pull down to refresh
        //https://stackoverflow.com/questions/10291537/pull-to-refresh-uitableview-without-uitableviewcontroller
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
        
        newGameButton.addTarget(self, action: #selector(newGamePressed(button:)), for: .touchUpInside)
        
        login()
        self.navigationItem.title = navTitle + " (\(vUserID))"
        
        datasync()
        //tableView.reloadData()
    }

    func getPlayerObject(playerID: Int, context:NSManagedObjectContext) -> NSManagedObject?
    {
        let request: NSFetchRequest<HCPlayer> = HCPlayer.fetchRequest()
        if #available(iOS 10.0, *) {
            request.entity = HCPlayer.entity()
        } else {
            request.entity = NSEntityDescription.entity(forEntityName: "HCPlayer", in: context)
        }
        let pred = NSPredicate(format: "(globalID = %d)", playerID)
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
        let player1Lives: Int
        let player1Score: Int
        let player2: Int
        let player2Lives: Int
        let player2Score: Int
        let topunit: Int
        let timelimit: Int
        let gamestate: Int //0 player1's turn, 1, player2's turn, 2 player 1 won, 3 player 2 won, 4 game expired unfinished
        let lastUpdated: Int32
        
        enum CodingKeys : String, CodingKey {
            case gameID = "gameid"
            case player1 = "player1"
            case player1Lives = "player1Lives"
            case player1Score = "player1Score"
            case player2 = "player2"
            case player2Lives = "player2Lives"
            case player2Score = "player2Score"
            case topunit = "topunit"
            case timelimit = "timelimit"
            case gamestate = "gamestate"
            case lastUpdated = "lastUpdated"
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
        let answerText:String?
        let answerIsCorrect:Bool? //the json should give true, false, or null
        let answerTimedOut:Bool?
        let answerSeconds:String?
        
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
            case answerText = "answerText"
            case answerIsCorrect = "answerIsCorrect"
            case answerTimedOut = "answerTimedOut"
            case answerSeconds = "answerSeconds"
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
            //let object = NSEntityDescription.insertNewObject(forEntityName: "HCGame", into: moc) as! HCGame
            
            let object = getCoreDataObjectOrNew(globalID: Int(game.gameID), entityType:"HCGame", context:moc) as! HCGame
            
            object.globalID = Int64(game.gameID)
            object.topUnit = Int16(game.topunit)
            object.timeLimit = Int16(game.timelimit)
            object.player1ID = Int32(game.player1)
            object.player1Lives = Int16(game.player1Lives)
            object.player1Score = Int16(game.player1Score)
            object.player2ID = Int32(game.player2)
            object.player2Lives = Int16(game.player2Lives)
            object.player2Score = Int16(game.player2Score)
            object.lastUpdated = Int32(game.lastUpdated)
            object.gameState = Int16(game.gamestate)
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
             //let moveObj = NSEntityDescription.insertNewObject(forEntityName: "HCMoves", into: moc) as! HCMoves
            
            let moveObj = getMoveObjectOrNew(gameID: Int(move.gameID), globalID: Int(move.moveID), entityType:"HCMoves", context:moc) as! HCMoves
            
             moveObj.gameID = Int64(move.gameID)
             moveObj.globalID = Int64(move.moveID)
             moveObj.verbID = Int32(move.verbID)
             moveObj.person = Int16(move.person)
             moveObj.number = Int16(move.number)
             moveObj.tense = Int16(move.tense)
             moveObj.voice = Int16(move.voice)
             moveObj.mood = Int16(move.mood)
            moveObj.answerGiven = move.answerText
            if move.answerIsCorrect != nil
            {
                moveObj.isCorrect = Bool(move.answerIsCorrect!)
            }
            if move.answerTimedOut != nil
            {
                moveObj.timedOut = Bool(move.answerTimedOut!)
            }
            moveObj.time = move.answerSeconds

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
            //let playerObj = NSEntityDescription.insertNewObject(forEntityName: "HCPlayer", into: moc) as! HCPlayer
            
            let playerObj = getCoreDataObjectOrNew(globalID: Int(player.playerID), entityType:"HCPlayer", context:moc) as! HCPlayer
            playerObj.globalID = Int32(player.playerID)
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
            //print("games: \(rows.gameRows.count)")
            if rows.status != 1
            {
                return false
            }
            saveSyncedGames(games: rows.gameRows)
            saveSyncedPlayers(players: rows.playerRows)
            saveSyncedMoves(moves: rows.moveRows)
            
            
            print("returned lastUpdated \(rows.lastUpdated)")
            setLastUpdated(lastUpdated: Int32(rows.lastUpdated))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("Refreshed")
                NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "GameListFRCCache")
                self._fetchedResultsController = nil //needed for some reason
                self.tableView.reloadData()
            }
            
        } catch let error {
            print("hc sync codeable error: \(error.localizedDescription)")
            return false
        }

        return true
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
    
    func getMoveObjectOrNew(gameID:Int, globalID: Int, entityType:String, context:NSManagedObjectContext) -> NSManagedObject?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityType)
        fetchRequest.predicate = NSPredicate(format: "globalID = %d AND gameID = %d", globalID, gameID)
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
    
    func getLastMoveForGame(gameID:Int, penultimate:Bool) -> HCMoves?
    {
        let moc = DataManager.shared.backgroundContext!
        
        let request: NSFetchRequest<HCMoves> = HCMoves.fetchRequest()
        if #available(iOS 10.0, *) {
            request.entity = HCMoves.entity()
        } else {
            request.entity = NSEntityDescription.entity(forEntityName: "HCMoves", in: moc)
        }

        let pred = NSPredicate(format: "(gameID = %d)", gameID)
        request.predicate = pred
        let sortDescriptor = NSSortDescriptor(key: "globalID", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        if penultimate == true
        {
            request.fetchLimit = 2
        }
        else
        {
            request.fetchLimit = 1
        }
        var results:[Any]?
        do {
            results = try moc.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
        } catch let error {
            NSLog("Error: %@", error.localizedDescription)
            return nil
        }
        if results != nil && results!.count > 0
        {
            if penultimate == true
            {
                return results?.last as? HCMoves
            }
            else
            {
                return results?.first as? HCMoves
            }
        }
        else
        {
            return nil
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
            print("saved last updated")
        } catch {
            print("couldn't save last updated")
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
    
    @objc func newGamePressed(button: UIButton) {
        performSegue(withIdentifier: "showGameVCFromList", sender: button)
    }
    
    func login()
    {
        let defaults = UserDefaults.standard
        
        //defaults.set("jeremy", forKey: "UserName")
        //defaults.set(2, forKey: "UserID")
        //defaults.set("william", forKey: "UserName")
        
        if let a = UserDefaults.standard.object(forKey: "UserID") as! Int?
        {
            vUserID = a
            print("userID is: \(a)")
        }
        else
        {
            let newID = 1
            defaults.set(newID, forKey: "UserID")
            defaults.synchronize()
            vUserID = newID
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
        
        let sortDescriptor = NSSortDescriptor(key: "lastUpdated", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataManager.shared.mainContext!, sectionNameKeyPath: nil, cacheName: "GameListFRCCache")
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
    
    func isMyTurn(gamePlayer1:Int, myPlayerID:Int, gameState:Int) -> Bool
    {
        if (gamePlayer1 == myPlayerID && gameState == 0) || (gamePlayer1 != myPlayerID && gameState == 1)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let gw = fetchedResultsController.object(at: indexPath)
        
        let myTurn = isMyTurn(gamePlayer1:Int(gw.player1ID.description)!, myPlayerID:vUserID, gameState:Int(gw.gameState))
        
        var oppID:Int?
        if Int(gw.player1ID.description) == vUserID
        {
            oppID = Int(gw.player2ID.description)
        }
        else
        {
            oppID = Int(gw.player1ID.description)
        }
        
        configureCell(cell, gameID: Int(gw.globalID.description)!, myTurn:myTurn, opponentID:oppID!, state:Int(gw.gameState.description)!)
        
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, gameID:Int, myTurn:Bool, opponentID:Int, state:Int) {
        //cell.textLabel!.text = event.timestamp!.description
        //cell.textLabel!.text = "\(gw.hqid.description) \(gw.lemma!.description)"
        let moc = DataManager.shared.backgroundContext!
        if let p = getPlayerObject(playerID: opponentID, context: moc) as? HCPlayer
        {
            cell.textLabel!.text = "\(gameID) versus \(p.userName ?? "?"), (\(state))"
        }
        else
        {
            cell.textLabel!.text = "\(gameID) versus ?"
        }
        
        let isCorrect : UIImageView = cell.contentView.viewWithTag(105) as! UIImageView
        isCorrect.image = (myTurn == true) ? checkImage : xImage
        
        //cell.tag = Int(gw.wordid)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = highlightedRowBGColor
        cell.selectedBackgroundView = bgColorView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = fetchedResultsController.object(at: indexPath)
        let myTurn = isMyTurn(gamePlayer1:Int(object.player1ID), myPlayerID:vUserID, gameState:Int(object.gameState))
        
        if myTurn
        {
            performSegue(withIdentifier: "showGameVCFromList", sender: tableView)
        }
        else
        {
            performSegue(withIdentifier: "showMovesFromGameList", sender: tableView)
        }
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
        
        //searchTextField?.resignFirstResponder() //works for pad and phone
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if sender is UIButton //new game
        {
            print("new game!")
            if let vd = segue.destination as? HCGameViewController
            {
                vd.gameType = .hcgame
                vd.moveUserID = vUserID
                
                //fix me temporary
                if vUserID == 1
                {
                    vd.moveOpponentID = 2
                }
                else
                {
                    vd.moveOpponentID = 1
                }
            }
        }
        else if sender is UITableView
        {
            let indexPath = tableView.indexPathForSelectedRow
            let object = fetchedResultsController.object(at: indexPath!)
            
            if let vd = segue.destination as? HCGameViewController
            {
                print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
                //set gameid, moveid, userid
                let gameID = Int(object.globalID)
                if let move = getLastMoveForGame(gameID:gameID, penultimate:false)
                {
                    let moveID = move.globalID
                    vd.gameType = .hcgame
                    vd.moveUserID = vUserID
                    vd.globalGameID = gameID
                    vd.globalMoveID = Int(moveID)
                    vd.movePerson = Int(move.person)
                    vd.moveNumber = Int(move.number)
                    vd.moveTense = Int(move.tense)
                    vd.moveVoice = Int(move.voice)
                    vd.moveMood = Int(move.mood)
                    vd.moveVerbID = Int(move.verbID)
                    vd.gamePlayer1ID = Int(object.player1ID)
                    vd.gamePlayer2ID = Int(object.player2ID)
                    vd.moveOpponentID = (vd.gamePlayer1ID == vUserID) ? vd.gamePlayer2ID : vd.gamePlayer1ID
                    
                    //check the string for nil rather than bool or number because:
                    //https://stackoverflow.com/questions/42622638/how-to-represent-core-data-optional-scalars-bool-int-double-float-in-swift
                    if move.answerGiven != nil //it wasn't answered yet.
                    {
                        vd.moveAnswerText = move.answerGiven
                        vd.moveIsCorrect = move.isCorrect
                        vd.moveTime = move.time
                        vd.moveTimedOut = move.timedOut
                     
                        print("Already answered! \(vd.moveAnswerText)")
                    }
                    //if it has been answered then we also need to show
                    //what the previous form was.
                    //the move is always the "stem"
                    if moveID == 1
                    {
                        //get lemma
                        vd.lastPerson = 0
                        vd.lastNumber = 0
                        vd.lastTense = 0
                        vd.lastVoice = 0
                        vd.lastMood = 0
                    }
                    else if let penultimateMove = getLastMoveForGame(gameID:gameID, penultimate:true)
                    {
                        //get last correct form
                        vd.lastPerson = Int(penultimateMove.person)
                        vd.lastNumber = Int(penultimateMove.number)
                        vd.lastTense = Int(penultimateMove.tense)
                        vd.lastVoice = Int(penultimateMove.voice)
                        vd.lastMood = Int(penultimateMove.mood)
                        vd.lastAnswerText = penultimateMove.answerGiven
                        vd.lastIsCorrect = penultimateMove.isCorrect
                    }
                }
            }
            else if let vd = segue.destination as? MoveListViewController
            {
                print("bbbb")
                //just pass gameid
            }
        }
    }
}


