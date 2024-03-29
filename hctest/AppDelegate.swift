//
//  AppDelegate.swift
//  hctest
//
//  Created by Jeremy March on 3/4/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
import CoreData

enum HCInitMethod {
    case copyFromBundle
    case downloadFromCloud
    case copyJSONFromBundle
    case generateWithvsInit
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let dbfile = "hcdatadb1-5"
    let dbext = "sqlite"
    let dbname:String = "hcdatadb1-5.sqlite"
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let dbpath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + "hcdatadb1-5.sqlite"
    
    var window: UIWindow?
    
    var queryStatement: OpaquePointer? = nil
    /*
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        print("Device token: \(deviceTokenString)")
        
    }
    */
//http://stackoverflow.com/questions/34037274/shouldautorotate-not-working-with-navigation-controllar-swift-2
    //var shouldSupportAllOrientation = false
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return UIInterfaceOrientationMask.portrait
        }
        else
        {
            return UIInterfaceOrientationMask.all
        }
    }
    
    struct HQResponse : Codable {
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
    
    func processHQVocabDataSqlite(jsonData:Data)
    {
        NSLog("yay2")
        if let stringData = String(data: jsonData, encoding: String.Encoding.utf8) {
            print(stringData) //JSONSerialization
            do {
                let decoder = JSONDecoder()
                let rows = try decoder.decode(HQResponse.self, from: jsonData)
                
                if let db = openDatabase(dbpath: dbpath)
                {
                    tempPrepareInsert(db:db)
                }
                
                var highestTimestamp = 0;
                for row in rows.rows {
                    //print("Row: \(row.id), \(row.lemma), \(row.unit)")

                    if row.lastupdated > highestTimestamp
                    {
                        highestTimestamp = row.lastupdated
                    }
                    if tempInsertWord(hqid:row.id, unit:row.unit, lemma:row.lemma, present:row.present, future:row.future, aorist:row.aorist, perfect:row.perfect, perfectmid:row.perfectmid, aoristpass:row.aoristpass, def:row.def, pos:row.pos, note:row.note, seq:row.seq) == false
                    {
                        print("error inserting word")
                        break
                    }
                    
                }
                
                print("Updated: \(rows.meta.updated)")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // set up your background color view for selected table cells
        //https://stackoverflow.com/questions/2553746/how-to-change-the-blue-highlight-color-of-a-uitableviewcell
        let colorView = UIView()
        colorView.backgroundColor = GlobalTheme.rowHighlightBG
        // use UITableViewCell.appearance() to configure
        // the default appearance of all UITableViewCells in your app
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        
        //Initialize defaults
        if (UserDefaults.standard.object(forKey: "Levels") as? [Bool]) == nil
        {
            //by default set unit 2
            let toggleStates = [false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
            
            let defaults = UserDefaults.standard
            defaults.set(toggleStates, forKey: "Levels")
            defaults.synchronize()
        }
        
        let initMethodx:HCInitMethod = .copyFromBundle
        switch initMethodx
        {
        case .copyFromBundle:
            //abc
            print("nope")
        case .generateWithvsInit:
            //DispatchQueue.global(qos: .background).async {
            let v = VerbSequence()
            v.vsInit(vDBPath: dbpath)
            //}
        case .downloadFromCloud:
            datasync() //saves in core data
        case .copyJSONFromBundle:
            if let path = Bundle.main.path(forResource: "hqvocab", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    processHQVocabDataSqlite(jsonData:data)
                    print("file json ok")
                } catch let error as NSError {
                    print("file json error")
                    print(error.localizedDescription)
                }
            }
        default:
            print("not initialized")
        }

        if #available(iOS 10.0, *) {
            DataManager.shared.backgroundContext = self.persistentContainer.newBackgroundContext()
            DataManager.shared.mainContext = self.persistentContainer.viewContext
        }
        else
        {
            DataManager.shared.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            DataManager.shared.backgroundContext?.persistentStoreCoordinator = managedObjectContext.persistentStoreCoordinator
            DataManager.shared.mainContext = managedObjectContext
        }
        
        return true
    }
    
    func deleteAll()
    {
        let backgroundContext = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        if #available(iOS 10.0, *) {
            backgroundContext.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        }
        else
        {
            backgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        }
        
        let fetch: NSFetchRequest<HQWords> = NSFetchRequest(entityName: "HQWords")

        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetch as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            try backgroundContext.execute(batchDeleteRequest)
            
        } catch {
            // Error Handling
            print("Failed deleting")
        }
        do {
            try backgroundContext.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func getWordObjectOrNew(hqid: Int, context:NSManagedObjectContext) -> NSManagedObject
    {
        if let w = getWordObject(hqid: hqid, context:context)
        {
            return w
        }
        else
        {
            let entity = NSEntityDescription.entity(forEntityName: "HQWords", in: context)
            return NSManagedObject(entity: entity!, insertInto: context)
        }
    }
    
    func getWordObject(hqid: Int, context:NSManagedObjectContext) -> NSManagedObject?
    {
        if hqid < 1
        {
            return nil
        }

        let request: NSFetchRequest<HQWords> = HQWords.fetchRequest()
        if #available(iOS 10.0, *) {
            request.entity = HQWords.entity()
        } else {
            request.entity = NSEntityDescription.entity(forEntityName: "HQWords", in: context)
        }
        
        let pred = NSPredicate(format: "(hqid = %d)", hqid)
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
    
    func hqWordExists(id: Int) -> Bool {
        if #available(iOS 10.0, *) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HQWords")
            fetchRequest.predicate = NSPredicate(format: "hqid = %d", id)
            fetchRequest.includesSubentities = false
            
            var entitiesCount = 0
            
            do {
                entitiesCount = try managedObjectContext.count(for: fetchRequest)
            }
            catch {
                print("error executing fetch request: \(error)")
            }
            
            return entitiesCount > 0
        }
        else
        {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HQWords")
            fetchRequest.predicate = NSPredicate(format: "hqid = %d", id)
            
            var results: [NSManagedObject] = []
            
            do {
                results = try managedObjectContext.fetch(fetchRequest)
            }
            catch {
                print("error executing fetch request: \(error)")
            }
            
            return results.count > 0
        }
    }
    
    func stripAccent(lemma:String) -> String
    {
        var stripped = lemma.folding(options: .diacriticInsensitive, locale: .current)
        stripped = stripped.replacingOccurrences(of: "ς", with: "σ", options: NSString.CompareOptions.literal, range:nil)
        stripped = stripped.trimmingCharacters(in: CharacterSet(charactersIn: "\u{0304}\u{0301}\u{EB00}\u{2014} -,") as CharacterSet)
        return stripped.lowercased()
    }
    
    //https://www.raywenderlich.com/123579/sqlite-tutorial-swift
    func openDatabase(dbpath:String) -> OpaquePointer? {
        var db: OpaquePointer? = nil
        if sqlite3_open(dbpath, &db) == SQLITE_OK
        {
            print("Successfully opened connection to database at \(dbpath)")
        }
        else
        {
            print("Unable to open database. Verify that you created the directory described " +
                "in the Getting Started section.")
        }
        //to reset
        //sqlite3_exec(db, "UPDATE verbseq SET elapsedtime='1.23';", nil, nil, nil)
        return db
    }
    
    func tempPrepareInsert(db:OpaquePointer) -> Bool
    {
        let queryStatementString:String = "REPLACE INTO hqvocab (hqid,unit,lemma,present,future,aorist,perfect,perfectmid,aoristpass,def,pos,note,seq,sortkey) VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14);"
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK
        {
            print("word prepare ok")
            return true
        }
        else
        {
            print("word prepare failed")
            return false
        }
    }
    
    func tempInsertWord(hqid:Int, unit:Int, lemma:String, present:String, future:String, aorist:String, perfect:String, perfectmid:String, aoristpass:String, def:String, pos:String, note:String, seq:Int16) -> Bool
    {
        //https://stackoverflow.com/questions/28142226/sqlite-for-swift-is-unstable
        //let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
        sqlite3_bind_int(queryStatement, 1, Int32(hqid))
        sqlite3_bind_int(queryStatement, 2, Int32(unit))
        sqlite3_bind_text(queryStatement, 3, lemma, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(queryStatement, 4, present, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(queryStatement, 5, future, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(queryStatement, 6, aorist, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(queryStatement, 7, perfect, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(queryStatement, 8, perfectmid, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(queryStatement, 9, aoristpass, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(queryStatement, 10, def, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(queryStatement, 11, pos, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(queryStatement, 12, note, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(queryStatement, 13, Int32(seq))
        sqlite3_bind_text(queryStatement, 14, stripAccent(lemma: lemma), -1, SQLITE_TRANSIENT)
        
        if sqlite3_step(queryStatement) == SQLITE_DONE
        {
            print("inserted word")
        }
        else
        {
            print("word not inserted")
            sqlite3_finalize(queryStatement)
            return false
        }
        sqlite3_clear_bindings(queryStatement);
        sqlite3_reset(queryStatement);
        return true
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
                                    backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                                    //let backgroundContext = self.managedObjectContext
                                    //backgroundContext.mergePolicy = NSRollbackMergePolicy //needed or duplicates x2
                                    if #available(iOS 10.0, *) {
                                        backgroundContext.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
                                    }
                                    else
                                    {
                                        backgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator
                                    }
                                    //let entity = NSEntityDescription.entity(forEntityName: "HQWords", in: backgroundContext)
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }

    // MARK: - Core Data stack
    //https://stackoverflow.com/questions/22582020/crash-when-using-nsreadonlypersistentstoreoption
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        let appName = "hctest"
        
        let container = NSPersistentContainer(name: appName)
        let usePreloadedStore = false
        if (usePreloadedStore)
        {
            let seededData: String = appName
            var persistentStoreDescriptions: NSPersistentStoreDescription
            
            //let storeUrl = self.applicationDocumentsDirectory.appendingPathComponent("app_name.sqlite")
            //let storeURL = [[NSBundle mainBundle] URLForResource:@"philologus" withExtension:@"sqlite"];
            let storeURL = Bundle.main.url(forResource: appName, withExtension: "sqlite")
            /*
             if !FileManager.default.fileExists(atPath: (storeURL?.path)!) {
             let seededDataUrl = Bundle.main.url(forResource: seededData, withExtension: "sqlite")
             try! FileManager.default.copyItem(at: seededDataUrl!, to: storeURL!)
             
             }
             */
            print(storeURL!)
            //var options = NSMutableDictionary()
            //options[NSReadOnlyPersistentStoreOption] = true
            
            //container.persistentStoreCoordinator.addPersistentStore(ofType: , configurationName: , at: , options: )
            
            let d:NSPersistentStoreDescription = NSPersistentStoreDescription(url: storeURL!)
            d.setOption(true as NSObject, forKey: NSReadOnlyPersistentStoreOption)
            d.setOption(["journal_mode": "delete"] as NSObject, forKey: NSSQLitePragmasOption)
            container.persistentStoreDescriptions = [d]
            
            //persistentStoreDescriptions.setOption(true as NSObject, forKey: NSReadOnlyPersistentStoreOption)
            //container.persistentStoreCoordinator.
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                
                fatalError("Unresolved error \(error),")
            }
        })
        
        return container
    }()
    
    // iOS 9 and below
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "hctest", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        //let url = self.applicationDocumentsDirectory.appendingPathComponent("philolog_us.sqlite")
        let url = Bundle.main.url(forResource: "hctest", withExtension: "sqlite")!
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let opt = [ NSReadOnlyPersistentStoreOption: true as NSObject,
                    NSSQLitePragmasOption: ["journal_mode": "delete"] as NSObject,
                    NSMigratePersistentStoresAutomaticallyOption:false as NSObject,
                    NSInferMappingModelAutomaticallyOption:false as NSObject]
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: opt as Any as? [AnyHashable : Any])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        if #available(iOS 10.0, *) {
            let coordinator = self.persistentContainer.persistentStoreCoordinator
            var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            return managedObjectContext
        }
        else
        {
            let coordinator = self.persistentStoreCoordinator
            var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            return managedObjectContext
        }
    }()
    
    
    /*
     lazy var persistentContainer: NSPersistentContainer = {
     /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
     let container = NSPersistentContainer(name: "philolog_us")
     //container.persistentStoreDescriptions[0].setOption(, forKey: )
     container.persistentStoreDescriptions[0].setOption(true as NSObject, forKey: NSReadOnlyPersistentStoreOption)
     container.persistentStoreDescriptions[0].setOption(["journal_mode": "delete"] as NSObject!, forKey: NSSQLitePragmasOption)
     container.loadPersistentStores(completionHandler: { (storeDescription, error) in
     if let error = error as NSError? {
     // Replace this implementation with code to handle the error appropriately.
     // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     
     /*
     Typical reasons for an error here include:
     * The parent directory does not exist, cannot be created, or disallows writing.
     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
     * The device is out of space.
     * The store could not be migrated to the current model version.
     Check the error message to determine what the actual problem was.
     */
     fatalError("Unresolved error \(error), \(error.userInfo)")
     }
     })
     return container
     }()
     */
    // MARK: - Core Data Saving support
    
    func saveContext () {
        
        if #available(iOS 10.0, *) {
            
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                
            } else {
                // iOS 9.0 and below - however you were previously handling it
                if managedObjectContext.hasChanges {
                    do {
                        try managedObjectContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                        abort()
                    }
                }
            }
        }
    }
}

@available(iOS 10.0, *)
extension NSPersistentContainer {
    
    public convenience init(name: String, bundle: Bundle) {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else {
                fatalError("Unable to located Core Data model")
        }
        
        self.init(name: name, managedObjectModel: mom)
    }
}

//https://stackoverflow.com/questions/26784315/can-i-somehow-do-a-synchronous-http-request-via-nsurlsession-in-swift
extension URLSession {
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

