//
//  VerbSequence.swift
//  hctest
//
//  Created by Jeremy March on 3/5/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation

enum Tense:Int32 {
    case present = 0
    case imperfect = 1
    case future = 2
    case aorist = 3
    case perfect = 4
    case pluperfect = 5
}

//test
class VerbSequence {
    var givenForm:VerbForm?
    var requestedForm:VerbForm?
    var options:VerbSeqOptions?
    var seq:Int = 1
    var score:Int32 = 0
    var lives:Int = 3
    var maxLives:Int = 3
    var units = [Int]()
    var gameId:Int = -1
    var vVerbIDs:[Int] = []
    
    var per:[Int32] = [0,1,2]
    var num:[Int32] = [0,1]
    var ten:[Int32] = [Tense.imperfect.rawValue,Tense.future.rawValue,Tense.aorist.rawValue,Tense.perfect.rawValue,Tense.pluperfect.rawValue]
    var voic:[Int32] = [0,1,2]
    var moo:[Int32] = [3]
    var vrbs:[Int32] = [3]
    var _shuffle:Bool = true
    var repsPerVerb:Int32 = 3
    
    init() {
        //DBInit2()
        self.givenForm = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: -1)
        self.requestedForm = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: 0)
        //self.reset()

        /*
        options = VerbSeqOptions()
        options?.repsPerVerb = 4
        options?.degreesToChange = 2
        options?.isHCGame = true
        options?.numUnits = 20
        options?.practiceVerbID = -1
        options?.units = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)
        
        externalSetUnits("19,20")
        */
        
        //defaults:
        per = [0,1,2]
        num = [0,1]
        ten = [Tense.present.rawValue,Tense.imperfect.rawValue,Tense.future.rawValue,Tense.aorist.rawValue,Tense.perfect.rawValue,Tense.pluperfect.rawValue]
        voic = [0,1,2]
        moo = [0,1,2,3]
        vrbs = [0]
        repsPerVerb = 3

        //setVSOptions(persons:per, numbers:num, tenses:ten, voices:voic, moods:moo, verbs:vrbs, shuffle:_shuffle,reps: repsPerVerb)
        
        /*
         game mode:
         reset: set level
         get: score, lives, verb forms, compare
         
         practice mode:
         reset: set custom verb/forms
         get: verb forms, compare
         
         two-player:
         receive prompt vf, check answer
 */
}
    
    func setVSOptions(persons:[Int32], numbers:[Int32], tenses:[Int32], voices:[Int32], moods:[Int32], verbs:[Int32], shuffle:Bool, reps:Int32)
    {
        per = persons
        num = numbers
        ten = tenses
        voic = voices
        moo = moods
        vrbs = verbs
        _shuffle = shuffle
        repsPerVerb = reps
        
        setOptionsxx(persons, Int32(persons.count), numbers, Int32(numbers.count), tenses, Int32(tenses.count), voices, Int32(voices.count), moods, Int32(moods.count), verbs, Int32(verbs.count), shuffle, reps)
    }
    
    func getNext() -> Int
    {
        //var vf1 = VerbFormD()
        //var vf2 = VerbFormD()
        /*
        vf1.person = (givenForm?.person)!.rawValue
        vf1.number = (givenForm?.number)!
        vf1.tense = (givenForm?.tense)!
        vf1.voice = (givenForm?.voice)!
        vf1.mood = (givenForm?.mood)!
        vf1.verbid = Int32((givenForm?.verbid)!)
        */
        var vf1 = givenForm!.getVerbFormD()
        var vf2 = requestedForm!.getVerbFormD()
        /*
        vf2.person = (requestedForm?.person)!.rawValue
        vf2.number = (requestedForm?.number)!
        vf2.tense = (requestedForm?.tense)!
        vf2.voice = (requestedForm?.voice)!
        vf2.mood = (requestedForm?.mood)!
        vf2.verbid = Int32((requestedForm?.verbid)!)
*/
        var a:Int32 = Int32(self.seq)
        
        let x = nextVS(&a, &vf1, &vf2)
        
        givenForm?.setFromVFD(verbFormd: vf1)
        requestedForm?.setFromVFD(verbFormd: vf2)
        /*
        givenForm?.person = vf1.person
        givenForm?.number = vf1.number
        givenForm?.tense = vf1.tense
        givenForm?.voice = vf1.voice
        givenForm?.mood = vf1.mood
        givenForm?.verbid = Int(vf1.verbid)
        
        requestedForm?.person = vf2.person
        requestedForm?.number = vf2.number
        requestedForm?.tense = vf2.tense
        requestedForm?.voice = vf2.voice
        requestedForm?.mood = vf2.mood
        requestedForm?.verbid = Int(vf2.verbid)
        */
        self.seq = Int(a)

        NSLog("Seq sw: \(self.seq)")
        return Int(x)
    }
    
    func reset()
    {
        //swiftResetVerbSeq();
        givenForm?.verbid = -1
        lives = maxLives
        score = 0
    }

    func checkVerbNoSave(expectedForm:String, enteredForm:String, mfPressed:Bool) -> Bool
    {
        var expectedLen:Int32 = 0
        let expectedForm1 = stringToUtf16(s: expectedForm, len: &expectedLen)
        let expectedBuffer = UnsafeMutablePointer<UInt16>(mutating: expectedForm1)
        
        var enteredLen:Int32 = 0
        let enteredForm1 = stringToUtf16(s: enteredForm, len: &enteredLen)
        let enteredBuffer = UnsafeMutablePointer<UInt16>(mutating: enteredForm1)
        
        //pass c string: http://stackoverflow.com/questions/31378120/convert-swift-string-into-cchar-pointer
        let a = checkVFResultNoSave(expectedBuffer, expectedLen, enteredBuffer, enteredLen, mfPressed)

        return a
    }
    
    func checkVerb(expectedForm:String, enteredForm:String, mfPressed:Bool, time:String) -> Bool
    {
        var vScore:Int32 = self.score
        var vLives:Int32 = Int32(self.lives)
        var expectedLen:Int32 = 0
        let expectedForm1 = stringToUtf16(s: expectedForm, len: &expectedLen)
        let expectedBuffer = UnsafeMutablePointer<UInt16>(mutating: expectedForm1)
        
        var enteredLen:Int32 = 0
        let enteredForm1 = stringToUtf16(s: enteredForm, len: &enteredLen)
        let enteredBuffer = UnsafeMutablePointer<UInt16>(mutating: enteredForm1)
        
        //print(expectedForm1)
        //print(enteredForm1)
        let newTime = time.replacingOccurrences(of: " sec", with: "")
        
        //pass c string: http://stackoverflow.com/questions/31378120/convert-swift-string-into-cchar-pointer
        let a = checkVFResult(expectedBuffer, expectedLen, enteredBuffer, enteredLen, mfPressed, newTime, &vScore, &vLives)
        self.score = vScore
        
        if a == false && options?.isHCGame == true
        {
            lives -= 1
        }
        else if options?.isHCGame == false
        {
            lives = -1
        }
        NSLog("score: \(self.score), lives: \(lives)")
        return a
    }
    
    func stringToUtf16(s:String, len: inout Int32) -> [UInt16]
    {
        len = 0
        var buffer = [UInt16]()
        for l in s.utf16
        {
            buffer.append(l)
            len += 1
        }
        return buffer
    }
    
    func DBInit2()
    {
        let dbname:String = "hcdatadb.sqlite"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dbpath = documentsPath + "/" + dbname
        NSLog("db: \(dbpath)")
        
        
        let cPath = UnsafeMutablePointer<Int8>(mutating: dbpath)
        NSLog("swift db init")
        let ret = dbInit(cPath)
        if ret == false
        {
            NSLog("Couldn't load sqlite db")
        }
    }
    /*
    func setUnits(units:[Int])
    {
        var s:String = ""
        //var a = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        //var i = 0
        for u in units
        {
            s = s + "," + String(u)
            //a[i] = u
            //i += 1
        }
        //c int array is a tuple in swift, so translate array to tuple
        //let t = (Int32(a[0]), Int32(a[1]), Int32(a[2]), Int32(a[3]), Int32(a[4]), Int32(a[5]), Int32(a[6]), Int32(a[7]), Int32(a[8]), Int32(a[9])
            /*
            , Int32(a[10]), Int32(a[11]), Int32(a[12]), Int32(a[13]), Int32(a[14]), Int32(a[15]), Int32(a[16]), Int32(a[17]), Int32(a[18]), Int32(a[19]))
        */
        //options?.units = s
        //options?.numUnits = UInt8(i)
        //let s2 = s.cString(using: .utf8)
        //externalSetUnits(s2)
        self.units = units
    }
 */
}

