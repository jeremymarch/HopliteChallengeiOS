//
//  VerbSequence.swift
//  hctest
//
//  Created by Jeremy March on 3/5/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

//in case we want to try storing libseq verbseqoptions object here
//https://stackoverflow.com/questions/24746397/how-can-i-convert-an-array-to-a-tuple
//https://codereview.stackexchange.com/questions/84476/array-to-tuple-in-swift/84528#84528


import Foundation

enum Tense:Int32 {
    case present = 0
    case imperfect = 1
    case future = 2
    case aorist = 3
    case perfect = 4
    case pluperfect = 5
}

enum VSState
{
    case error
    case new
    case rep
    case gameover
}

//test
class VerbSequence {
    var givenForm = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: -1)
    var requestedForm = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: -1)
    
    var state:VSState = .new
    var seq:Int = 1
    var score:Int32 = 0
    var lives:Int = 3
    var initialLives:Int = 3
    var units = [Int32]()
    var gameId:Int = -1
    var isHCGame = false
    var currentVerb = 0

    var topUnit = 1
    var maxRepsPerVerb:Int32 = 4
    var repNum:Int32 = -1
    var verbIDs:[Int32] = []
    var persons:[Int32] = [0,1,2]
    var numbers:[Int32] = [0,1]
    var tenses:[Int32] = [0,1,2,3,4]
    var voices:[Int32] = [0,1,2]
    var moods:[Int32] = [0,1,2,3]
    var filterByUnit = 0
    var shuffle:Bool = true
    var paramsToChange = 2
    
    init() {
        state = .new
    }
    
    func setVSOptions()
    {
        state = .new
        swSetVerbSeqOptions(self.persons, Int32(self.persons.count), self.numbers, Int32(self.numbers.count), self.tenses, Int32(self.tenses.count), self.voices, Int32(self.voices.count), self.moods, Int32(self.moods.count), self.verbIDs, Int32(self.verbIDs.count), self.units, Int32(self.units.count), self.shuffle, self.maxRepsPerVerb, Int32(self.topUnit), isHCGame)
    }
    
    func reset()
    {
        swvsReset(isHCGame);
        lives = initialLives
        score = 0
        state = .new
    }
    
    func getNext() -> VSState
    {
        var vf1 = givenForm.getVerbFormD()
        var vf2 = requestedForm.getVerbFormD()

        let x = swvsNext(&vf1, &vf2)
        
        givenForm.setFromVFD(verbFormd: vf1)
        requestedForm.setFromVFD(verbFormd: vf2)

        switch x
        {
        case 0:
            self.state = .error
            return .error
        case 1:
            self.state = .new
            return .new
        case 2:
            self.state = .rep
            return .rep
        case 3:
            self.state = .gameover
            return .gameover
        default:
            self.state = .error
            return .error
        }
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
        let a = compareFormsCheckMF(expectedBuffer, expectedLen, enteredBuffer, enteredLen, mfPressed)

        return a
    }
    
    func checkVerb(expectedForm:String, enteredForm:String, mfPressed:Bool, time:String) -> Bool
    {
        var vScore:Int32 = 0
        var vLives:Int32 = 0
        var expectedLen:Int32 = 0
        let expectedForm1 = stringToUtf16(s: expectedForm, len: &expectedLen)
        let expectedBuffer = UnsafeMutablePointer<UInt16>(mutating: expectedForm1)
        
        var enteredLen:Int32 = 0
        let enteredForm1 = stringToUtf16(s: enteredForm, len: &enteredLen)
        let enteredBuffer = UnsafeMutablePointer<UInt16>(mutating: enteredForm1)
        
        //print(expectedForm1)
        //print(enteredForm1)
        let newTime = time.replacingOccurrences(of: " sec", with: "")
        
        //pass c string:
        //http://stackoverflow.com/questions/31378120/convert-swift-string-into-cchar-pointer
        let isCorrect = swvsCompareFormsRecordResult(expectedBuffer, expectedLen, enteredBuffer, enteredLen, mfPressed, newTime, &vScore, &vLives)
        self.score = vScore
        self.lives = Int(vLives)
        
        if isCorrect == false && isHCGame == true
        {
            if self.lives < 1
            {
                self.state = .gameover
            }
        }

        print("score: \(self.score), lives: \(lives)")
        return isCorrect
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
    
    func vsInit() -> Int
    {
        let dbname:String = "hcdatadb.sqlite"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dbpath = documentsPath + "/" + dbname
        print("db: \(dbpath)")
        
        
        let cPath = UnsafeMutablePointer<Int8>(mutating: dbpath)
        print("swift db init")
        let ret = swvsInit(cPath)
        if ret != 0
        {
            print("Couldn't initialize sqlite db")
        }
        return Int(ret)
    }
    
    func vsClose()
    {
        vsClose();
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

