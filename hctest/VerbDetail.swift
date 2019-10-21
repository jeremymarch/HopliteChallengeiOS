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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true
            {
                GlobalTheme = (isDarkMode()) ? DarkTheme.self : DefaultTheme.self
                self.tableView.reloadData()
            }
        }
    }
    
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
        
        forms.append(row)

        let vf = VerbForm(.unset, .unset, .unset, .unset, .unset, verb: Int(verb.verbId))
        
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
                    else
                    {
                        continue //skip passive if middle+passive are the same
                    }
                    var sectionCount = 0
                    for number in VerbForm.Number.allCases
                    {
                        if number == .unset { continue }
                        vf.number = number
                        
                        for person in VerbForm.Person.allCases
                        {
                            if person == .unset { continue }
                            vf.person = person
                            
                            var form = vf.getForm(decomposed: false)
                            
                            if (form != "")
                            {
                                let label = String.init(format: "%d%@:", (person.rawValue + 1), (number == .singular) ? "s" : "p")
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
        label.backgroundColor = GlobalTheme.secondaryBG
        label.textColor = GlobalTheme.secondaryText
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
        hp.vs.isHCGame = false
        hp.vs.verbIDs.removeAll()
        //hp.vs.verbIDs.append( Int32(hqVerbID) )
        hp.practiceVerbID = Int(hqVerbID)
        hp.fromVerbDetail = true
    }
}

