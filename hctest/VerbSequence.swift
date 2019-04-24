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
    var givenForm = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: -1)
    var requestedForm = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: -1)
    
    var seq:Int = 1
    var score:Int32 = 0
    var lives:Int = 3
    var initialLives:Int = 3
    var units = [Int]()
    var gameId:Int = -1
    var isHCGame = false

    var topUnit = 1
    var repsPerVerb:Int32 = 3
    var verbIDs:[Int32] = [1]
    var persons:[Int32] = [0,1,2]
    var numbers:[Int32] = [0,1]
    var tenses:[Int32] = [0,1,2,3,4]
    var voices:[Int32] = [0,1,2]
    var moods:[Int32] = [0,1,2,3]
    var filterByUnit = 0
    var shuffle:Bool = true
    var paramsToChange = 2
    //var difficulty = 0
    
    //var gameConfigNew = VerbSeqOptionsNew()
    
    init() {
        //DBInit2()
        //self.givenForm =
        //self.requestedForm = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: 0)
        
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
        /*
        per = [0,1,2]
        num = [0,1]
        ten = [Tense.present.rawValue,Tense.imperfect.rawValue,Tense.future.rawValue,Tense.aorist.rawValue,Tense.perfect.rawValue,Tense.pluperfect.rawValue]
        voic = [0,1,2]
        moo = [0,1,2,3]
        vrbs = [0]
        repsPerVerb = 3
*/
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
    
    func setVSOptions()
    {
        setOptionsxx(self.persons, Int32(self.persons.count), self.numbers, Int32(self.numbers.count), self.tenses, Int32(self.tenses.count), self.voices, Int32(self.voices.count), self.moods, Int32(self.moods.count), self.verbIDs, Int32(self.verbIDs.count), self.shuffle, self.repsPerVerb, Int32(self.topUnit))
    }
    
    func reset()
    {
        //swiftResetVerbSeq();
        givenForm.verbid = -1
        requestedForm.verbid = -1
        lives = initialLives
        score = 0
    }
    
    func getNext() -> Int
    {
        var vf1 = givenForm.getVerbFormD()
        var vf2 = requestedForm.getVerbFormD()

        var a:Int32 = Int32(self.seq)
        
        let x = nextVS(&a, &vf1, &vf2)
        
        givenForm.setFromVFD(verbFormd: vf1)
        requestedForm.setFromVFD(verbFormd: vf2)

        self.seq = Int(a)

        print("Seq sw: \(self.seq)")
        return Int(x)
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
        
        if a == false && isHCGame == true
        {
            lives -= 1
        }
        else if isHCGame == false
        {
            lives = -1
        }
        print("score: \(self.score), lives: \(lives)")
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
    
    func DBInit()
    {
        let dbname:String = "hcdatadb.sqlite"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dbpath = documentsPath + "/" + dbname
        print("db: \(dbpath)")
        
        
        let cPath = UnsafeMutablePointer<Int8>(mutating: dbpath)
        print("swift db init")
        let ret = dbInit(cPath)
        if ret == false
        {
            print("Couldn't load sqlite db")
        }
    }
    
    /*
     make a string to send to libseq?
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

