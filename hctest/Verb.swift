//
//  Verb.swift
//  hctest
//
//  Created by Jeremy March on 3/15/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation

class Verb2 {
    var present:String = ""
    var future:String = ""
    var aorist:String = ""
    var perfect:String = ""
    var perfMid:String = ""
    var aoristPass:String = ""
    var verbId:UInt32 = 0
    var verbClass:UInt32 = 0
    var HQUnit:UInt8 = 0
    let dash = "–"
    
    init(verbid:Int)
    {
        let mirror = Mirror(reflecting: verbs)
        
        for (_, value) in mirror.children
        {
            if value is Verb && (value as! Verb).verbid == UInt32(verbid)
            {
                let v = value as! Verb
                present = String(cString: v.present)
                future = String(cString: v.future)
                aorist = String(cString: v.aorist)
                perfect = String(cString: v.perf)
                perfMid = String(cString: v.perfmid)
                aoristPass = String(cString: v.aoristpass)
                verbId = v.verbid
                HQUnit = v.hq
                verbClass = v.verbclass
            }
        }
    }
    
    func principalParts(seperator:String) -> String
    {
        var innerSeperator:String = " or "
        if seperator != ""
        {
            innerSeperator = seperator
        }
        var sa = [String]()
        sa.append(present != "" ? present.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        sa.append(future != "" ? future.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        sa.append(aorist != "" ? aorist.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        sa.append(perfect != "" ? perfect.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        sa.append(perfMid != "" ? perfMid.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        sa.append(aoristPass != "" ? aoristPass.replacingOccurrences(of: ",", with: innerSeperator) : dash)
        
        return sa.joined(separator: ", ")
    }
    
    func isDeponent() -> Int
    {
        return Int(deponentType2(Int32(verbId)))
    }
}
