//
//  VerbForm.swift
//  hctest
//
//  Created by Jeremy March on 3/4/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

//https://www.uraimo.com/2016/04/07/swift-and-c-everything-you-need-to-know/#arrays-and-structs

import Foundation

protocol VerbFormParamDescription  {
    var description: String { get }
}

class VerbForm {
    
    typealias VerbFormParam = UInt8
    
    enum Person: VerbFormParam, CaseIterable, VerbFormParamDescription {
        case first = 0
        case second = 1
        case third = 2
        case unset = 3
        
        var description: String {
            switch self {
            case .first:
                return "First"
            case .second:
                return "Second"
            case .third:
                return "Third"
            case .unset:
                return "Unset"
            }
        }
    }
    
    enum Number: VerbFormParam, CaseIterable, VerbFormParamDescription {
        case singular = 0
        //case dual = 2 //remember to filter this out
        case plural = 1
        case unset = 3
        
        var description: String {
            switch self {
            case .singular:
                return "Singular"
            //case .dual:
            //    return "Dual"
            case .plural:
                return "Plural"
            case .unset:
                return "Unset"
         
            }
        }
    }
    
    enum Tense: VerbFormParam, CaseIterable, VerbFormParamDescription {
        case present = 0
        case imperfect = 1
        case future = 2
        case aorist = 3
        case perfect = 4
        case pluperfect = 5
        case unset = 6
        
        var description: String {
            switch self {
            case .present:
                return "Present"
            case .imperfect:
                return "Imperfect"
            case .future:
                return "Future"
            case .aorist:
                return "Aorist"
            case .perfect:
                return "Perfect"
            case .pluperfect:
                return "Pluperfect"
            case .unset:
                return "Unset"
            }
        }
    }
    
    enum Voice: VerbFormParam, CaseIterable, VerbFormParamDescription {
        case active = 0
        case middle = 1
        case passive = 2
        case unset = 3
        
        var description: String {
            switch self {
            case .active:
                return "Active"
            case .middle:
                return "Middle"
            case .passive:
                return "Passive"
            case .unset:
                return "Unset"
            }
        }
    }
    
    enum Mood: VerbFormParam, CaseIterable, VerbFormParamDescription {
        case indicative = 0
        case subjunctive = 1
        case optative = 2
        case imperative = 3
        case infinitive = 4 //not really a mood, here for convenience
        case participle = 5 //not really a mood, here for convenience
        case unset = 6
        
        var description: String {
            switch self {
            case .indicative:
                return "Indicative"
            case .subjunctive:
                return "Subjunctive"
            case .optative:
                return "Optative"
            case .imperative:
                return "Imperative"
            case .infinitive:
                return "Infinitive"
            case .participle:
                return "Participle"
            case .unset:
                return "Unset"
            }
        }
    }
    
    var person:Person = .unset
    //var person:UInt8 = 0
    var number:Number = .unset
    var tense:Tense = .unset
    var voice:Voice = .unset
    var mood:Mood = .unset
    var verbid:Int = 0

    init(_ person:UInt8, _ number:UInt8, _ tense:UInt8, _ voice:UInt8, _ mood:UInt8, verb:Int) {
        setPerson(person)
        setNumber(number)
        setTense(tense)
        setVoice(voice)
        setMood(mood)
        self.verbid = verb
    }
    
    init(_ person:Person, _ number:Number, _ tense:Tense, _ voice:Voice, _ mood:Mood, verb:Int) {
        self.setParams(person, number, tense, voice, mood, verb:verb)
    }
    
    func setParams(_ person:Person, _ number:Number, _ tense:Tense, _ voice:Voice, _ mood:Mood, verb:Int)
    {
        self.person = person
        self.number = number
        self.tense = tense
        self.voice = voice
        self.mood = mood
        self.verbid = verb
    }
    
    func copyVF(_ vf:VerbForm)
    {
        self.person = vf.person
        self.number = vf.number
        self.tense = vf.tense
        self.voice = vf.voice
        self.mood = vf.mood
        self.verbid = vf.verbid
    }
    
    func getVerbFormD() -> VerbFormD
    {
        var vf1 = VerbFormD()
        vf1.person = person.rawValue
        vf1.number = number.rawValue
        vf1.tense = tense.rawValue
        vf1.voice = voice.rawValue
        vf1.mood = mood.rawValue
        vf1.verbid = Int32(verbid)
        
        return vf1
    }
    
    func setPerson(_ person:UInt8)
    {
        switch person {
        case 0:
            self.person = .first
        case 1:
            self.person = .second
        case 2:
            self.person = .third
        default:
            self.person = .unset
            //fatalError("Invalid Person")
        }
    }
    
    func setNumber(_ number:UInt8)
    {
        switch number {
        case 0:
            self.number = .singular
        case 1:
            self.number = .plural
        //case 2:
        //    self.number = .dual
        default:
            self.number = .unset
            //fatalError("Invalid Person")
        }
    }
    
    func setTense(_ tense:UInt8)
    {
        switch tense {
        case 0:
            self.tense = .present
        case 1:
            self.tense = .imperfect
        case 2:
            self.tense = .future
        case 3:
            self.tense = .aorist
        case 4:
            self.tense = .perfect
        case 5:
            self.tense = .pluperfect
        default:
            self.tense = .unset
            //fatalError("Invalid Person")
        }
    }
    
    func setVoice(_ voice:UInt8)
    {
        switch voice {
        case 0:
            self.voice = .active
        case 1:
            self.voice = .middle
        case 2:
            self.voice = .passive
        default:
            self.voice = .unset
            //fatalError("Invalid Person")
        }
    }
    
    func setMood(_ mood:UInt8)
    {
        switch mood {
        case 0:
            self.mood = .indicative
        case 1:
            self.mood = .subjunctive
        case 2:
            self.mood = .optative
        case 3:
            self.mood = .imperative
        case 4:
            self.mood = .infinitive
        default:
            self.mood = .unset
            //fatalError("Invalid Person")
        }
    }
    
    func setFromVFD(verbFormd:VerbFormD) -> Void
    {
        setPerson(verbFormd.person)
        setNumber(verbFormd.number)
        setTense(verbFormd.tense)
        setVoice(verbFormd.voice)
        setMood(verbFormd.mood)
        
        verbid = Int(verbFormd.verbid)
    }
    
    var form:String {
        get {
            return getForm(decomposed: false)
        }
    }
    
    var decomposedForm:String {
        get {
            return getForm(decomposed: true)
        }
    }
    
    var description:String {
        get {
            return getDescription()
        }
    }
    
    func getVoiceDescription() -> String
    {
        var vf = getVerbFormD()
        let x = getVoiceDescription2(&vf)
        if x == 0
        {
            return "Active"
        }
        else if x == 1
        {
            return "Middle"
        }
        else if x == 2
        {
            return "Passive"
        }
        else if x == 3
        {
            return "Middle/Passive"
        }
        else
        {
            return ""
        }
    }
    
    func allParamsAreSet() -> Bool
    {
        if person == .unset || number == .unset || tense == .unset || voice == .unset || mood == .unset
        {
            return false
        }
        return true
    }
    
    func getForm(decomposed:Bool) -> String
    {
        if !allParamsAreSet()
        {
            return ""
        }
        
        let bufferSize:Int = 500
        var buffer = [Int8](repeating: 0, count: bufferSize)
        
        var vf = getVerbFormD()
        
        let x = getForm2(&vf, &buffer, Int32(bufferSize), true, decomposed)
        if x != 0
        {
            //let data = Data(bytes:buffer2, count:bufferSize)
            //let s = String(data: data, encoding: String.Encoding.utf8)
            let s = String(cString: buffer)
            
            //NSLog("len: \(s.characters.count)")
        
            return s.replacingOccurrences(of: ", ", with: ",\n")
        }
        else
        {
            return ""
        }
    }
    
    func getDescription() -> String
    {
        if !allParamsAreSet()
        {
            return ""
        }
        
        let bufferSize:Int = 500
        var buffer = [Int8](repeating: 0, count: bufferSize)
        
        var vf = getVerbFormD()
        
        getAbbrevDescription2(&vf, &buffer, Int32(bufferSize))
        //let data = Data(bytes:buffer2, count:bufferSize)
        //let s = String(data: data, encoding: String.Encoding.utf8)
        let s = String(cString: buffer)
        
        //NSLog("len: \(s.characters.count)")
        
        return s
    }
}
