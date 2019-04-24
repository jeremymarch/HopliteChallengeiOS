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
    var verbId:Int32 = 0
    var verbClass:UInt32 = 0
    var HQUnit:UInt8 = 0
    var hqVerbID:Int32 = 0
    let dash = "—"//let dash = "–"
    
    enum HQVerb: Int32 {
        case paideuw = 0
        case pempw = 1
        case keleuw = 2
        case luw = 3
        case graphw = 4
        case thuw = 5
        case pauw = 6
        case phulattw = 7
        case didaskw = 8
        case ethelw = 9
        case thaptw = 10
        case tattw = 11
        case archw = 12
        case blaptw = 13
        case peithw = 14
        case prattw = 15
        case douleuw = 16
        case kwluw = 17
        case politeuw = 18
        case choreuw = 19
        case kleptw = 20
        case leipw = 21
        case swzw = 22
        case agw = 23
        case hkw = 24
        case adikew = 25
        case nikaw = 26
        case poiew = 27
        case pimaw = 28
        case aggellw = 29
        case axiow = 30
        case dhlow = 31
        case kalew = 32
        case menw = 33
        case teleutaw = 34
        case akouw = 35
        case apodechomai = 36
        case ballw = 37
        case boulomai = 38
        case dechomai = 39
        case lambanw = 40
        case paschw = 41
        case anatithhmi = 42
        case apodidwmi = 43
        case aphisthmi = 44
        case didwmi = 45
        case isthmi = 46
        case kathisthmi = 47
        case kataluw = 48
        case tithhmi = 49
        case philew = 50
        case phobeomai = 51
    }
    
    init(verbid:Int)
    {
        let mirror = Mirror(reflecting: verbs)
        
        for (_, value) in mirror.children
        {
            if value is Verb && (value as! Verb).hqid == UInt32(verbid)
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
                hqVerbID = Int32(v.hqid)
            }
        }
    }
    
    func verbsForUnit(unit:Int, andUnder:Bool) -> [Int32]
    {
        var verbs:[Int32] = []
        switch unit {
        case 0:
            verbs.append(contentsOf:[0,1])
        case 1:
            verbs.append(contentsOf:[2,3])
        case 2:
            verbs.append(contentsOf:[3,4])
        default:
            verbs.append(contentsOf:[0])
        }
        return verbs;
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
