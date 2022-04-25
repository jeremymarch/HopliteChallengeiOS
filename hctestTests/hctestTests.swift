//
//  hctestTests.swift
//  hctestTests
//
//  Created by Jeremy March on 3/23/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import XCTest
struct FormRow {
    var label = ""
    var form = ""
    var decomposedForm = ""
}

class hctestTests: XCTestCase {
    let persons = ["first", "second", "third"]
    let numbers = ["singular", "plural"]
    let tenses = ["Present", "Imperfect", "Future", "Aorist", "Perfect", "Pluperfect"]
    let voices = ["Active", "Middle", "Passive"]
    let moods = ["Indicative", "Subjunctive", "Optative", "Imperative"]
    
    let personsabbrev = ["1st", "2nd", "3rd"]
    let numbersabbrev = ["sing.", "pl."]
    let tensesabbrev = ["pres.", "imp.", "fut.", "aor.", "perf.", "plup."]
    let voicesabbrev = ["act.", "mid.", "pass."]
    let moodsabbrev = ["ind.", "subj.", "opt.", "imper."]
    
    var verbIndex:Int = -1
    var forms = [FormRow]()
    var sections = [String]()
    var sectionCounts = [Int]()
    var isExpanded:Bool = false
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func printVerb(verb:Verb2)
    {
        //let vf = VerbForm(person: 0, number: 0, tense: 0, voice: 0, mood: 0, verb: Int(verb.verbId))
        
        var isOida:Bool = false
        if verb.present == "οἶδα" || verb.present == "σύνοιδα"
        {
            isOida = true
        }
        
        for tense in 0..<NUM_TENSES
        {
            vf.tense = UInt8(tense)
            for voice in 0..<NUM_VOICES
            {
                for mood in 0..<NUM_MOODS
                {
                    let m:Int = Int(mood)
                    if !isOida && m != INDICATIVE && (tense == PERFECT || tense == PLUPERFECT || tense == IMPERFECT || (tense == FUTURE && m != OPTATIVE))
                    {
                        continue
                    }
                    else if isOida && m != INDICATIVE && (tense == PLUPERFECT || tense == IMPERFECT || tense == FUTURE)
                    {
                        continue
                    }
                    var s:String?
                    if voice == ACTIVE || tense == AORIST || tense == FUTURE
                    {
                        s = "  " + tenses[tense] + " " + voices[voice] + " " + moods[m]
                    }
                    else if voice == MIDDLE
                    {
                        //yes it's correct, middle deponents do not have a passive voice.  H&Q page 316
                        if  verb.isDeponent() == MIDDLE_DEPONENT || verb.isDeponent() == PASSIVE_DEPONENT || verb.isDeponent() == DEPONENT_GIGNOMAI || verb.present == "κεῖμαι"
                        {
                            s = "  " + tenses[tense] + " " + "Middle" + " " + moods[m]
                        }
                        else
                        {
                            s = "  " + tenses[tense] + " " + "Middle/Passive" + " " + moods[m]
                        }
                    }
                    else
                    {
                        continue; //skip passive if middle+passive are the same
                    }
                    var sectionCount = 0
                    for number in 0..<NUM_NUMBERS
                    {
                        for person in 0..<NUM_PERSONS
                        {
                            vf.person = UInt8(person)
                            vf.number = UInt8(number)
                            vf.tense = UInt8(tense)
                            vf.voice = UInt8(voice)
                            vf.mood = UInt8(mood)
                            
                            var form = vf.getForm(decomposed: false)
                            
                            if (form != "")
                            {
                                let label = String.init(format: "%d%@:", (person+1), (number == 0) ? "s" : "p")
                                form = form.replacingOccurrences(of: ", ", with: "\n")
                                
                                let row = FormRow(label: label, form: form, decomposedForm: vf.getForm(decomposed: true).replacingOccurrences(of: ", ", with: "\n"))
                                forms.append(row)
                                sectionCount += 1
                            }
                        }
                    }
                    if sectionCount > 0
                    {
                        sections.append(s!)
                        sectionCounts.append(sectionCount)
                    }
                }
            }
        }
    }
 
}
