//
//  VerbForm.swift
//  hctest
//
//  Created by Jeremy March on 3/4/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

//https://www.uraimo.com/2016/04/07/swift-and-c-everything-you-need-to-know/#arrays-and-structs

import Foundation

class VerbForm {
    var person:UInt8 = 0
    var number:UInt8 = 0
    var tense:UInt8 = 0
    var voice:UInt8 = 0
    var mood:UInt8 = 0
    var verbid:Int = 0
    
    init(person:UInt8, number:UInt8, tense:UInt8, voice:UInt8, mood:UInt8, verb:Int) {
        self.person = person
        self.number = number
        self.tense = tense
        self.voice = voice
        self.mood = mood
        self.verbid = verb
    }
    
    func getForm(decomposed:Bool) -> String
    {
        let bufferSize:Int = 500
        var buffer = [Int8](repeating: 0, count: bufferSize)
        
        //let v = verbs
        //var a = v[1][1]
        
        var vf = VerbFormD()
        vf.person = UInt8(self.person)
        vf.number = UInt8(self.number)
        vf.tense = UInt8(self.tense)
        vf.voice = UInt8(self.voice)
        vf.mood = UInt8(self.mood)
        vf.verbid = UInt32(self.verbid)
        
        let x = getForm2(&vf, &buffer, Int32(bufferSize), true, decomposed)
        if x != 0
        {
            //let data = Data(bytes:buffer2, count:bufferSize)
            //let s = String(data: data, encoding: String.Encoding.utf8)
            let s = String(cString: buffer)
            
            //NSLog("len: \(s.characters.count)")
        
            return s
        }
        else
        {
            return ""
        }
    }
    
    func getDescription() -> String
    {
        let bufferSize:Int = 500
        var buffer2 = [Int8](repeating: 0, count: bufferSize)
        
        var vf = VerbFormD()
        vf.person = UInt8(self.person)
        vf.number = UInt8(self.number)
        vf.tense = UInt8(self.tense)
        vf.voice = UInt8(self.voice)
        vf.mood = UInt8(self.mood)
        vf.verbid = UInt32(self.verbid)
        
        getAbbrevDescription2(&vf, &buffer2, Int32(bufferSize))
        //let data = Data(bytes:buffer2, count:bufferSize)
        //let s = String(data: data, encoding: String.Encoding.utf8)
        let s = String(cString: buffer2)
        
        //NSLog("len: \(s.characters.count)")
        
        return s
    }
}
