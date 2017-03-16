//
//  VerbDetail.swift
//  hctest
//
//  Created by Jeremy March on 3/15/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class VerbDetailViewController: UIViewController {
    
    var verbIndex:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verbs"
        
        let backButton = UIBarButtonItem(title: "Practice", style: UIBarButtonItemStyle.plain, target: self, action: #selector
            (practiceVerb))
        self.navigationItem.rightBarButtonItem = backButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    /*
    func printVerb(verb:Verb2)
    {
        let vf = VerbForm(person: 0, number: 0, tense: 0, voice: 0, mood: 0, verb: Int(verb.verbId))

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
                    if !isOida && mood != INDICATIVE && (tense == PERFECT || tense == PLUPERFECT || tense == IMPERFECT || tense == FUTURE)
                    {
                        continue
                    }
                    else if isOida && mood != INDICATIVE && (tense == PLUPERFECT || tense == IMPERFECT || tense == FUTURE)
                    {
                        continue
                    }
                    var s:String?
                    if voice == ACTIVE || tense == AORIST || tense == FUTURE
                    {
                        s = "  " + tenses[tense] + " " + voices[voice] + " " + moods[mood]
                    }
                    else if voice == MIDDLE
                    {
                        //yes it's correct, middle deponents do not have a passive voice.  H&Q page 316
                        if  verb.isDeponent() == MIDDLE_DEPONENT || verb.isDeponent() == PASSIVE_DEPONENT || verb.isDeponent() == DEPONENT_GIGNOMAI || verb.present == "κεῖμαι"
                        {
                            s = "  " + tenses[tense] + " " + "Middle" + " " + moods[mood]
                        }
                        else
                        {
                            s = "  " + tenses[tense] + " " + "Middle/Passive" + " " + moods[mood]
                        }
                    }
                    else
                    {
                        continue; //skip passive if middle+passive are the same
                    }

                    for number in 0..<NUM_NUMBERS
                    {
                        for person in 0..<NUM_PERSONS
                        {
                            vf.number = UInt8(number)
                            vf.person = UInt8(person)
                            vf.mood = UInt8(mood)
                            
                            var form = vf.getForm(decomposed: false)
                            
                            if (form != "")
                            {
                                let label = String.init(format: "%d%s:", (person+1), (number == 0) ? "s" : "p")
                                form = form.replacingOccurrences(of: ", ", with: "\n")
                                    
                            }
                        }
                    }
                }
                
            }
        }
        
    }
*/
    func practiceVerb()
    {
        performSegue(withIdentifier: "SegueToHoplitePractice", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let hp = segue.destination as! HopliteChallenge
        hp.isGame = false
        hp.practiceVerbId = verbIndex
    }
}

