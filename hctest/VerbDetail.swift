//
//  VerbDetail.swift
//  hctest
//
//  Created by Jeremy March on 3/15/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
struct FormRow {
    var label = ""
    var form = ""
    var decomposedForm = ""
}

class VerbDetailViewController: UITableViewController {
    
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
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = Verb2(verbid: verbIndex)
        
        if v.present.characters.count > 0
        {
            title = v.present
        }
        else
        {
            title = v.future
        }
        printVerb(verb: v)
        //tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        let backButton = UIBarButtonItem(title: "Practice", style: UIBarButtonItemStyle.plain, target: self, action: #selector
            (practiceVerb))
        self.navigationItem.rightBarButtonItem = backButton
        
        let pinchRecognizer = UIPinchGestureRecognizer(target:self, action:#selector(handlePinch))
        self.view.addGestureRecognizer(pinchRecognizer)
    }
    
    func handlePinch(sender: UIPinchGestureRecognizer)
    {
        //NSLog("Scale: %.2f | Velocity: %.2f",sender.scale, sender.velocity);
        let thresholdVelocity:CGFloat  = 0 //4.0;
        
        if sender.scale > 1 && sender.velocity > thresholdVelocity
        {
            if isExpanded == false
            {
                //NSLog("expand")
                isExpanded = true
                tableView.reloadData()
            }
        }
        else if sender.velocity < -thresholdVelocity
        {
            if isExpanded == true
            {
                //NSLog("unexpand")
                isExpanded = false
                tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let att = [ NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 18)! ]
        self.navigationController?.navigationBar.titleTextAttributes = att
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        let att = [ NSFontAttributeName: UIFont(name: "NewAthenaUnicode", size: 22)! ]
        self.navigationController?.navigationBar.titleTextAttributes = att
    }
    
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
                    let m:Int = Int(mood)
                    if !isOida && m != INDICATIVE && (tense == PERFECT || tense == PLUPERFECT || tense == IMPERFECT || tense == FUTURE)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "VerbDetailCell")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = true
        cell.backgroundColor = UIColor.clear
        cell.accessoryType = UITableViewCellAccessoryType.none
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let lblTitle2 : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        
        var index = 0
        for i in 0..<indexPath.section
        {
            index += sectionCounts[i]
        }
        index += indexPath.row
        
        if isExpanded == true
        {
            lblTitle.text = forms[index].decomposedForm
        }
        else
        {
            lblTitle.text = forms[index].form
        }
        
        lblTitle2.text = forms[index].label
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        
        performSegue(withIdentifier: "SegueToVerbDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionCounts[section]//verbsPerSection[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count//verbsPerSection.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.text = sections[section]
        
        label.backgroundColor = UIColor.blue
        label.textColor = UIColor.white
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }

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

