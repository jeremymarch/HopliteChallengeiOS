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
    
    var verbIndex:Int = -1 //actually this is hqid
    var hqVerbID:Int32 = -1 //actually this is verb index!
    var forms = [FormRow]()
    var sections = [String]()
    var sectionCounts = [Int]()
    var isExpanded:Bool = false
    

    
    var attributesLabel: [NSAttributedString.Key: Any]? = nil
    var attributesPara: [NSAttributedString.Key: Any]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.tabStops = [NSTextTab(textAlignment: NSTextAlignment.left, location: 30, options: [:])]
        //paragraphStyle.headIndent = 180
        
        attributesLabel = [
            .font: UIFont(name: "HelveticaNeue", size: 17.0)!,
            .foregroundColor: UIColor.gray,
            .baselineOffset: 1.5 as NSNumber
        ]
            
        attributesPara = [
            .paragraphStyle: paragraphStyle
        ]
        
        let v = Verb2(verbid: verbIndex)
        hqVerbID = Int32(v.verbId)
        
        let t = UILabel()
        if v.present.count > 0
        {
            title = v.present
            t.text = v.present
        }
        else
        {
            title = v.future
            t.text = v.future
        }
        
        t.font = UIFont(name: "NewAthenaUnicode", size: 22)!
        self.navigationItem.titleView = t
        
        printVerb(verb: v)
        //tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        let practiceButton = UIBarButtonItem(title: "Practice", style: UIBarButtonItem.Style.plain, target: self, action: #selector
            (practiceVerb))
        self.navigationItem.rightBarButtonItem = practiceButton
        
        let pinchRecognizer = UIPinchGestureRecognizer(target:self, action:#selector(handlePinch))
        self.view.addGestureRecognizer(pinchRecognizer)
    }
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer)
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
    
    //override func viewWillDisappear(_ animated: Bool) {}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func printVerb(verb:Verb2)
    {
        sections.append("  Principal Parts")
        sectionCounts.append(1)
        let row = FormRow(label: "", form: verb.principalParts(seperator: " or"), decomposedForm: verb.principalParts(seperator: " or"))
        //let row = FormRow(label: "", form: "def", decomposedForm: "abc")
        forms.append(row)

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
                vf.voice = UInt8(voice)
                for mood in 0..<NUM_MOODS
                {
                    vf.mood = UInt8(mood)
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
                        s = "  " + tenses[tense] + " " + vf.getVoiceDescription() + " " + moods[m]
                    }
                    else if voice == MIDDLE
                    {
                        //yes it's correct, middle deponents do not have a passive voice.  H&Q page 316
                        s = "  " + tenses[tense] + " " + vf.getVoiceDescription() + " " + moods[m]
                    }
                    else
                    {
                        continue //skip passive if middle+passive are the same
                    }
                    var sectionCount = 0
                    for number in 0..<NUM_NUMBERS
                    {
                        for person in 0..<NUM_PERSONS
                        {
                            vf.person = UInt8(person)
                            vf.number = UInt8(number)
                            
                            var form = vf.getForm(decomposed: false)
                            
                            if (form != "")
                            {
                                let label = String.init(format: "%d%@:", (person+1), (number == 0) ? "s" : "p")
                                form = form.replacingOccurrences(of: ",\n", with: ",\n\t")
                                
                                let row = FormRow(label: label, form: form, decomposedForm: vf.getForm(decomposed: true).replacingOccurrences(of: ",\n", with: ",\n\t"))
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellName : String
        if indexPath.section == 0 && indexPath.row == 0
        {
            cellName = "VerbDetailPPCell"
        }
        else
        {
            cellName = "VerbDetailCell"
        }
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellName)!
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = true
        cell.backgroundColor = UIColor.clear
        cell.accessoryType = UITableViewCell.AccessoryType.none
        
        var index = 0
        for i in 0..<indexPath.section
        {
            index += sectionCounts[i]
        }
        index += indexPath.row
        
        if indexPath.section == 0 && indexPath.row == 0
        {
            let pp : UILabel = cell.contentView.viewWithTag(101) as! UILabel
            pp.text = forms[index].form
        }
        else
        {
            let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
            //let lblTitle2 : UILabel = cell.contentView.viewWithTag(102) as! UILabel
            
            if isExpanded == true
            {
                let attText = NSMutableAttributedString(string: forms[index].label + "\t" + forms[index].decomposedForm, attributes:attributesPara)
                attText.addAttributes(attributesLabel!, range: NSRange(location: 0, length: 3))
                
                lblTitle.attributedText = attText
                //lblTitle.text = forms[index].label + "\t" + forms[index].decomposedForm
            }
            else
            {
                let attText = NSMutableAttributedString(string: forms[index].label + "\t" + forms[index].form, attributes:attributesPara)
                attText.addAttributes(attributesLabel!, range: NSRange(location: 0, length: 3))
                
                lblTitle.attributedText = attText
                //lblTitle.text = forms[index].label + "\t" + forms[index].form
            }
            
            //lblTitle2.text = forms[index].label
        }
        return cell
    }
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        
        //performSegue(withIdentifier: "SegueToVerbDetail", sender: self)
    }
    */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionCounts[section]//verbsPerSection[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count//verbsPerSection.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.text = sections[section]
        
        //label.backgroundColor = UIColor.blue
        label.backgroundColor = UIColor.init(red: 0, green: 0, blue: 110.0/255.0, alpha: 1.0)
        label.textColor = UIColor.white
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }

    @objc func practiceVerb()
    {
        performSegue(withIdentifier: "SegueToHoplitePractice", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let hp = segue.destination as! HopliteChallenge
        hp.isGame = false
        hp.verbIDs.removeAll()
        hp.verbIDs.append( Int32(hqVerbID) )
        hp.fromVerbDetail = true
    }
}

