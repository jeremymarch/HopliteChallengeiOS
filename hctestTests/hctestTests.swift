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
    //var forms = [FormRow]()
    //var sections = [String]()
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
    /*
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
    */
    
    func testVerbs()
    {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "new", ofType: "txt")!
        let contents = try! String(contentsOfFile: path)
        let rows = contents.split(separator:"\n")
        XCTAssertEqual(rows.count, 34810)
        if rows.count != 34810 {
            return
        }
        var line = 1
        for verb_num in 0...527 {
        
            let verb = Verb2.init(verbid: verb_num)
            let vf = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: verb_num)
            
            var isOida:Bool = false
            if verb.present == "οἶδα" || verb.present == "σύνοιδα"
            {
                isOida = true
            }
            
            for tense in VerbForm.Tense.allCases
            {
                if tense == .unset { continue }
                vf.tense = tense
                
                for voice in VerbForm.Voice.allCases
                {
                    if voice == .unset { continue }
                    vf.voice = voice
                    for mood in VerbForm.Mood.allCases
                    {
                        if mood == .unset { continue }
                        vf.mood = mood
                        if (mood == .infinitive || mood == .participle)
                        {
                            continue
                        }
                        else if !isOida && mood != .indicative && (tense == .perfect || tense == .pluperfect || tense == .imperfect || (tense == .future && mood != .optative))
                        {
                            continue
                        }
                        else if isOida && mood != .indicative && (tense == .pluperfect || tense == .imperfect || (tense == .future && mood != .optative))
                        /*else if isOida && ((mood != .indicative && (tense == .pluperfect || tense == .imperfect)) && (tense == .future && (mood == .subjunctive || mood == .imperative)))*/
                            
                        {
                            continue
                        }

                        var s:String?
                        if voice == .active || tense == .aorist || tense == .future
                        {
                            s = "  " + tense.description + " " + vf.getVoiceDescription() + " " + mood.description
                        }
                        else if voice == .middle
                        {
                            //FYI: middle deponents do NOT have a passive voice.  H&Q page 316
                            s = "  " + tense.description + " " + vf.getVoiceDescription() + " " + mood.description
                        }

                        var voi = ""
                        if vf.voice == .middle && vf.mood == .imperative {
                            voi = "Middle"
                        }
                        else if vf.voice == .passive && vf.mood == .imperative {
                            voi = "Passive"
                        }
                        else if vf.getVoiceDescription() == "Middle/Passive" && vf.voice == .middle {
                            voi = "Middle (\(vf.getVoiceDescription()))"
                        }
                        else if vf.getVoiceDescription() == "Middle/Passive" && vf.voice == .passive {
                            voi = "Passive (\(vf.getVoiceDescription()))"
                        }
                        else {
                            voi = vf.getVoiceDescription()
                        }
                        let sec = "\(tense.description) \(voi) \(mood.description)"
                        XCTAssertEqual(String(rows[line]), sec)
                        if String(rows[line]) != sec {
                            return
                        }
                        line += 1
                        for number in VerbForm.Number.allCases
                        {
                            if number == .unset { continue }
                            vf.number = number
                            
                            for person in VerbForm.Person.allCases
                            {
                                if person == .unset { continue }
                                vf.person = person
                                
                                var form = vf.getForm(decomposed: false).replacingOccurrences(of: ",\n", with: ", ")
                                var form_d = vf.getForm(decomposed: true).replacingOccurrences(of: ",\n", with: ", ")
                                
                                if vf.mood == .imperative && vf.person == .first {
                                    form = "NF"
                                    form_d = "NDF"
                                }
                                
                                if (form != "")
                                {
                                    let label = String.init(format: "%d%@", (person.rawValue + 1), (number == .singular) ? "s" : "p")
                                    
                                    let x = "\(label): \(form) ; \(form_d)"
                                    print(x)
                                    
                                    XCTAssertEqual(String(rows[line]), x)
                                    if String(rows[line]) != x {
                                        return
                                    }
                                    line += 1
                                }
                            }
                        }
                    }
                }
                
            }
            line += 1
        }
        
    }
    
}
