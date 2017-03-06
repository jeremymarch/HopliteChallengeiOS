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
    
    init() {
        self.givenForm = VerbForm(person: 0, number: 0, tense: 0, voice: 0, mood: 0, verb: 1)
        self.requestedForm = VerbForm(person: 0, number: 0, tense: 0, voice: 0, mood: 0, verb: 1)
        self.reset()
        
        options = VerbSeqOptions()
        options?.repsPerVerb = 4
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
        
        let x = nextVerbSeq2(&a, &vf1, &vf2)
        
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
    }
}

