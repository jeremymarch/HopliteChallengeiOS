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

    func testDiacritics()
    {
        let precomposed = "\u{1FB1}"        //alpha with precomposed macron
        let combining = "\u{03B1}\u{0304}"  //alpha with combining macron

        //1. not same when compared literally
        let res = precomposed.compare(combining, options: NSString.CompareOptions.literal, range: nil, locale: nil)
        XCTAssertNotEqual(res, ComparisonResult.orderedSame)
        
        
        //2. same when compared insensitively
        let res2 = precomposed.compare(combining, options: NSString.CompareOptions.diacriticInsensitive, range: nil, locale: nil)
        XCTAssertEqual(res2, ComparisonResult.orderedSame)
        
        
        //3. this compares insensitively
        XCTAssertEqual(precomposed, combining)
    }
    
    func testVerbs()
    {
        var print_lines = true
        
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "new", ofType: "txt")!
        let contents = try! String(contentsOfFile: path)
        let rows = contents.split(separator:"\n")
        XCTAssertEqual(rows.count, 34852)
        if rows.count != 34852 {
            return
        }
        var line = 1
        for verb_num in 0...126 {
        
            //let verb = Verb2.init(verbid: verb_num)
            let vf = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: verb_num)
            
            var isOida:Bool = false
            
            if verb_num == 118 || verb_num == 119 {
                print_lines = true
                isOida = true
            }
            else {
                print_lines = false
                isOida = false
            }
            
            /*if verb.present == "οἶδα" || verb.present == "σύνοιδα"
            {
                isOida = true
            }*/
            
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
                        if mood == .infinitive || mood == .participle
                        {
                            continue
                        }
                        else if mood != .indicative && (tense == .perfect || tense == .pluperfect || tense == .imperfect || (tense == .future && mood != .optative))
                        {
                            if isOida && tense == .perfect && voice == .active {
                                
                            }
                            else {
                                continue
                            }
                        }
                        /*else if isOida && mood != .indicative && (tense == .pluperfect || tense == .imperfect || (tense == .future && mood != .optative))
                        {
                            continue
                        }*/

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
                        if print_lines {
                            print("\(line) - \(sec)")
                        }
                        XCTAssertEqual(String(rows[line]), sec, "line: \(line). verb: \(vf.verbid) \(vf.person) \(vf.number) \(vf.tense) \(vf.voice) \(vf.mood) \(isOida)")
                        
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
                                
                                if (form == "")
                                {
                                    form = "NF"
                                }
                                if (form_d == "")
                                {
                                    form_d = "NDF"
                                }
                                let label = String.init(format: "%d%@", (person.rawValue + 1), (number == .singular) ? "s" : "p")
                                
                                let x = "\(label): \(form) ; \(form_d)"
                                if print_lines {
                                    print("\t\(line) - \(x)")
                                }
                                
                                let is_equal_insensitive = x.compare(String(rows[line]), options: NSString.CompareOptions.diacriticInsensitive, range: nil, locale: nil)
                                XCTAssertEqual(is_equal_insensitive, ComparisonResult.orderedSame)
                                
                                let is_equal_literal = x.compare(String(rows[line]), options: NSString.CompareOptions.literal, range: nil, locale: nil)
                                XCTAssertEqual(is_equal_literal, ComparisonResult.orderedSame)
                                
                                XCTAssertEqual(String(rows[line]), x, "line: \(line). verb: \(vf.verbid) \(vf.person) \(vf.number) \(vf.tense) \(vf.voice) \(vf.mood)")
                                
                                if String(rows[line]) != x {
                                    return
                                }
                                line += 1
                            }
                        }
                    }
                }
                
            }
            //next verb
            line += 1
        }
        
    }
    
}
