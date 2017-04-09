//
//  VerbSequence.swift
//  hctest
//
//  Created by Jeremy March on 3/5/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation

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
    
    init() {
        self.givenForm = VerbForm(person: 0, number: 0, tense: 0, voice: 0, mood: 0, verb: 0)
        self.requestedForm = VerbForm(person: 0, number: 0, tense: 0, voice: 0, mood: 0, verb: 0)
        self.reset()
        
        options = VerbSeqOptions()
        options?.repsPerVerb = 4
        options?.degreesToChange = 2
        options?.isHCGame = true
        options?.numUnits = 20
        options?.practiceVerbID = -1
        options?.units = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)
}
    func getNext() -> Int
    {
        var vf1 = VerbFormD()
        var vf2 = VerbFormD()
        
        vf1.person = (givenForm?.person)!
        vf1.number = (givenForm?.number)!
        vf1.tense = (givenForm?.tense)!
        vf1.voice = (givenForm?.voice)!
        vf1.mood = (givenForm?.mood)!
        vf1.verbid = UInt32((givenForm?.verbid)!)
        
        vf2.person = (requestedForm?.person)!
        vf2.number = (requestedForm?.number)!
        vf2.tense = (requestedForm?.tense)!
        vf2.voice = (requestedForm?.voice)!
        vf2.mood = (requestedForm?.mood)!
        vf2.verbid = UInt32((requestedForm?.verbid)!)

        var a:Int32 = Int32(self.seq)
        
        let x = nextVerbSeq2(&a, &vf1, &vf2, &options!)
        
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
        
        self.seq = Int(a)

        NSLog("Seq: \(self.seq)")
        return Int(x)
    }
    
    func reset()
    {
        resetVerbSeq()
        lives = maxLives
        score = 0
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
        
        print(expectedForm1)
        print(enteredForm1)
        let newTime = time.replacingOccurrences(of: " sec", with: "")
        
        //pass c string: http://stackoverflow.com/questions/31378120/convert-swift-string-into-cchar-pointer
        let a = compareFormsCheckMFRecordResult(expectedBuffer, expectedLen, enteredBuffer, enteredLen, mfPressed, newTime, &vScore, &vLives)
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
        let ret = dbInit(cPath)
        if ret == false
        {
            NSLog("Couldn't load sqlite db")
        }
    }
    func setUnits(units:[Int])
    {
        var a = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        var i = 0
        for u in units
        {
            a[i] = u
            i += 1
        }
        //c int array is a tuple in swift, so translate array to tuple
        let t = (Int32(a[0]), Int32(a[1]), Int32(a[2]), Int32(a[3]), Int32(a[4]), Int32(a[5]), Int32(a[6]), Int32(a[7]), Int32(a[8]), Int32(a[9]), Int32(a[10]), Int32(a[11]), Int32(a[12]), Int32(a[13]), Int32(a[14]), Int32(a[15]), Int32(a[16]), Int32(a[17]), Int32(a[18]), Int32(a[19]))
        
        options?.units = t
        options?.numUnits = UInt8(i)
        self.units = units
    }
}

