//
//  VerbSequenceTest.swift
//  HopliteChallenge
//
//  Created by Jeremy on 5/15/19.
//  Copyright © 2019 Jeremy March. All rights reserved.
//

import Foundation
/*
protocol VerbSeqProtocol {
    // protocol definition goes here
    var givenForm:VerbForm
    var requestedForm:VerbForm
    var state:VSState
}
*/

class VerbSequenceTest {
    var givenForm = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: -1)
    var requestedForm = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: -1)
    var state:VSState = .new
    
    func getNext() -> Int
    {
        return 0
    }
    
    func checkVerbNoSave(expectedForm:String, enteredForm:String, mfPressed:Bool) -> Bool
    {
        return true
    }
    
    func checkVerb(expectedForm:String, enteredForm:String, mfPressed:Bool, time:String) -> Bool
    {
        return true
    }
    
    func setVSOptions()
    {
    }
    
    func reset()
    {
    }
}
