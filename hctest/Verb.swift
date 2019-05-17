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
        case gignomai = 52
        case erchomai = 53
        case manthanw = 54
        case machomai = 55
        case metadidwmi = 56
        case metanistamai = 57
        
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
        case 0: //i.e. unit 1
            verbs.append(contentsOf:[])
        case 1:
            verbs.append(contentsOf:[0,1])
        case 2:
            verbs.append(contentsOf:[2,3])
        case 3:
            verbs.append(contentsOf:[4,5,6,7])
        case 4:
            verbs.append(contentsOf:[8,9,10,11])
        case 5:
            verbs.append(contentsOf:[12,13,14,15])
        case 6:
            verbs.append(contentsOf:[16,17,18,19])
        case 7:
            verbs.append(contentsOf:[20,21,22])
        case 8:
            verbs.append(contentsOf:[23,24])
        case 9:
            verbs.append(contentsOf:[25,26,27,28])
        case 10:
            verbs.append(contentsOf:[29,30,31,32,33,34])
        case 11:
            verbs.append(contentsOf:[35,36,37,38,39,40,41])
        case 12:
            verbs.append(contentsOf:[42,43,44,45,46,47,48,49,50,51])
        case 13:
            verbs.append(contentsOf:[52,53,54,55,56,57,58,59])
        case 14:
            verbs.append(contentsOf:[60,61,62,63,64,65,66,67,68,69,70,71,72])
        case 15:
            verbs.append(contentsOf:[73,74,75,76,/*77,78,*/79,80,81,82])
        case 16:
            verbs.append(contentsOf:[83,84,85,86,87,88,89,90,91])
        case 17:
            verbs.append(contentsOf:[92,93,94,95,96,97,98])
        case 18:
            verbs.append(contentsOf:[99,100,101,102,103,104,105,106,107,108,109])
        case 19:
            verbs.append(contentsOf:[110,111,112,113,114,115,116,117,118,119])
        case 20:
            verbs.append(contentsOf:[120,/*121,*/122,123,124,125/*,126*/])
        default:
            verbs.append(contentsOf:[])
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
