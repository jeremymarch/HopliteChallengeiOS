//
//  NetworkManager.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 6/3/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SystemConfiguration

class NetworkManager {
    
    // MARK: - Properties
    
    static let shared = NetworkManager()
    
    // MARK: -
    
    // Initialization
    
    private init() {
        
    }
    
    func dictToJSONString(data:Dictionary<String, String>) -> String?
    {
        var jsonStr:String?
        do {
            let jsonData:Data = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            jsonStr = String(data: jsonData, encoding: .utf8)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        return jsonStr
    }
    
    func sendReq(urlstr:String, requestData:Dictionary<String, String>, queueOnFailure:Bool, processResult: @escaping (Dictionary<String, String>, Data)->Bool )
    {
        //let parameters:Dictionary<String, String> = ["wordid": String(wordid), "lang": String(theLang), "device":UIDevice.current.identifierForVendor!.uuidString, "agent":"iOS \(UIDevice.current.systemVersion)",  "screen":"\(UIScreen.main.nativeBounds.height) x \(UIScreen.main.nativeBounds.width)"]
        
        var newDict = requestData //make a mutable copy
        
        let utcTimestamp = Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: utcTimestamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //Set timezone that you want
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //format compatible with mysql
        
        let dateString = dateFormatter.string(from: date)
        //print(dateString)
        
        //get generic properties
        var realVersion = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        {
            realVersion = version
        }
        newDict["appversion"] = realVersion
        newDict["device"] = UIDevice.current.identifierForVendor!.uuidString
        newDict["agent"] = "iOS \(UIDevice.current.systemVersion)"
        newDict["screen"] = "\(UIScreen.main.nativeBounds.height) x \(UIScreen.main.nativeBounds.width)"
        newDict["accessdate"] = dateString
        newDict["error"] = ""
        
        let isReachable = isNetworkReachable()
        
        if !isReachable
        {
            newDict["error"] = newDict["error"]! + "*0*"
        }
        
        guard let poststr = dictToJSONString(data: newDict) else
        {
            return
        }
        
        if isReachable
        {
            //print("yes is reachable")
            let url = URL(string: urlstr)! //change to url type
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            var queue = getQueue()
            queue.append(poststr)
            var toSend = "["
            toSend += queue.joined(separator: ",")
            toSend += "]"
            
            print("tosend: " + toSend)
            request.httpBody = toSend.data(using: String.Encoding.utf8)
            
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    //add poststr to requestqueue
                    //print("error sending request")
                    //print(error!.localizedDescription)
                    
                    newDict["error"] = "*1* (\(error!.localizedDescription)) "
                    
                    guard let poststr = self.dictToJSONString(data: newDict) else
                    {
                        return
                    }
                    
                    if queueOnFailure
                    {
                        self.addToRequestQueue(req:poststr)
                    }
                    return
                }
                
                guard let data = data else {
                    return
                }
                //self.clearQueue()
                //process returned data, clear queue if successful, else add to queue
                if processResult(newDict, data) == true
                {
                    self.clearQueue()
                }
                else
                {
                    newDict["error"] = "*2*"
                    
                    guard let poststr = self.dictToJSONString(data: newDict) else
                    {
                        return
                    }
                    
                    if queueOnFailure
                    {
                        self.addToRequestQueue(req:poststr)
                    }
                    //print("nope")
                }
                
            })
            task.resume()
        }
        else if queueOnFailure
        {
            //print("not reachable")
            addToRequestQueue(req:poststr)
        }
    }
 
    func clearQueue() {
        let context = DataManager.shared.backgroundContext
        
        let deleteFetch = NSFetchRequest<RequestQueue>(entityName: "RequestQueue")
        //this caused issues about readonly db on ios 9 and 10
        /*
         if #available(iOS 9.0, *) {
         let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch as! NSFetchRequest<NSFetchRequestResult>)
         do {
         try context?.execute(deleteRequest)
         try context?.save()
         } catch {
         print ("There was an error clearing the queue")
         }
         } else {
         */
        // Fallback for iOS 8
        deleteFetch.entity = NSEntityDescription.entity(forEntityName: "RequestQueue", in: context!)
        deleteFetch.includesPropertyValues = false
        do {
            if let results = try context?.fetch(deleteFetch) {
                for result in results {
                    context?.delete(result)
                }
                try context?.save()
            }
        } catch {
            //print("error clearing queue")
        }
        //}
    }
    
    func getQueue() -> [String]
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RequestQueue")
        if #available(iOS 10.0, *) {
            request.entity = RequestQueue.entity()
        } else {
            request.entity = NSEntityDescription.entity(forEntityName: "RequestQueue", in: DataManager.shared.mainContext!)
        }
        var results: [RequestQueue]? = nil
        do {
            results =
                try DataManager.shared.mainContext?.fetch(request ) as? [RequestQueue]
            
        } catch let error {
            // Handle error
            NSLog("Error: %@", error.localizedDescription)
            return []
        }
        
        var r:[String] = []
        
        if results != nil
        {
            for res in results!
            {
                r.append(res.data!)
            }
        }
        return r
    }
    
    func addToRequestQueue(req:String)
    {
        let moc = DataManager.shared.backgroundContext!
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "RequestQueue", into: moc) as! RequestQueue
        object.data = req
        
        do {
            try moc.save()
            //print("saved moc")
        } catch {
            //print("couldn't save poststr")
        }
    }
    
    func isNetworkReachable() -> Bool
    {
        func testReachabilityFlags(with flags: SCNetworkReachabilityFlags) -> Bool {
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
            let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
            
            return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
        }
        
        //https://marcosantadev.com/network-reachability-swift/
        // Optional binding since `SCNetworkReachabilityCreateWithName` return an optional object
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "philolog.us") else
        {
            return false
        }
        
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        
        if !testReachabilityFlags(with: flags) {
            // Device doesn't have internet connection
            return false
        }
        /*
         #if os(iOS)
         // It's available just for iOS because it's checking if the device is using mobile data
         if flags.contains(.isWWAN) {
         // Device is using mobile data
         }
         #endif
         */
        // At this point we are sure that the device is using Wifi since it's online and without using mobile data
        return true
    }
}
