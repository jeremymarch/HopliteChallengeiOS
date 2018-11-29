//
//  HCVerbFormPicker.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 5/24/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//

import UIKit
//to disable certain component
//https://stackoverflow.com/questions/33860778/how-to-properly-disable-uipickerview-component-scrolling/33860779


class HCVerbFormPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    var pickerEnabled = true
    let arPerson = ["1st","2nd","3rd"]
    let arNumber = ["sing.", "pl."]
    let arTense = ["pres.","imperf.","fut.","aor.","perf.","plup."]
    let arVoice = ["act.","mid.","pass."]
    let arMood = ["ind.", "subj.", "opt.", "imper."]
    var pickerPerson = 0
    var pickerNumber = 0
    var pickerTense = 0
    var pickerVoice = 0
    var pickerMood = 0
    var pickerSelected = [ 0, 0, 0, 0, 0 ]
    var pickerOrigSelected = [ 0, 0, 0, 0, 0 ]
    var personLabel:[UILabel?] = [nil,nil,nil]
    var numberLabel:[UILabel?] = [nil,nil]
    var tenseLabel:[UILabel?] = [nil,nil,nil,nil,nil,nil]
    var voiceLabel:[UILabel?] = [nil,nil,nil]
    var moodLabel:[UILabel?] = [nil,nil,nil,nil]
    
    var maxChangedComponents = 5
    var highlightChanges = false
    var autoUnchangeFirstChanged = true //else prevent further changes after max
    
    override init(frame: CGRect){
        super.init(frame: frame)
        showsSelectionIndicator = true
        delegate = self
        dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setVerbForm(person:Int, number:Int, tense:Int, voice:Int, mood:Int, locked:Bool)
    {
        if person >= arPerson.count
        {
            assertionFailure("Set verb form out of range: person -> \(person)")
            return
        }
        if number >= arNumber.count
        {
            assertionFailure("Set verb form out of range: number -> \(number)")
            return
        }
        if tense >= arTense.count
        {
            assertionFailure("Set verb form out of range: tense -> \(tense)")
            return
        }
        if voice >= arVoice.count
        {
            assertionFailure("Set verb form out of range: voice -> \(voice)")
            return
        }
        if mood >= arMood.count
        {
            assertionFailure("Set verb form out of range: mood -> \(mood)")
            return
        }

        //needs to be before selection
        if locked
        {
            lockPicker()
        }
        else
        {
            unlockPicker()
        }
        
        pickerSelected = [ person, number, tense, voice, mood ]
        pickerOrigSelected = [ person, number, tense, voice, mood ]
        
        selectRow(person, inComponent: 0, animated: false)
        selectRow(number, inComponent: 1, animated: false)
        selectRow(tense, inComponent: 2, animated: false)
        selectRow(voice, inComponent: 3, animated: false)
        selectRow(mood, inComponent: 4, animated: false)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel
        if pickerLabel == nil
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Helvetica", size: 22)
            pickerLabel?.textAlignment = NSTextAlignment.center
            if pickerSelected[component] != pickerOrigSelected[component] && row != pickerOrigSelected[component] && highlightChanges
            {
                //pickerLabel?.font = UIFont(name: "Helvetica", size: 26)
                pickerLabel?.textColor = UIColor.red
            }
            
            var selectedRow = row
            if !pickerEnabled {
                selectedRow = pickerSelected[component]
            }
            
            switch component {
            case 0:
                pickerLabel?.text = arPerson[selectedRow]
                personLabel[row] = pickerLabel!
            case 1:
                pickerLabel?.text = arNumber[selectedRow]
                numberLabel[row] = pickerLabel!
            case 2:
                pickerLabel?.text = arTense[selectedRow]
                tenseLabel[row] = pickerLabel!
                //tenseLabel?.font = UIFont(name: "Helvetica", size: 26)
            case 3:
                pickerLabel?.text = arVoice[selectedRow]
                voiceLabel[row] = pickerLabel!
            case 4:
                pickerLabel?.text = arMood[selectedRow]
                moodLabel[row] = pickerLabel!
            default:
                pickerLabel?.text = ""
            }
        }
        return pickerLabel!
    }
    
    func restore()
    {
        setVerbForm(person: pickerOrigSelected[0], number: pickerOrigSelected[1], tense: pickerOrigSelected[2], voice: pickerOrigSelected[3], mood: pickerOrigSelected[3], locked: pickerEnabled)
    }
    
    func lockPicker()
    {
        pickerEnabled = false
        isUserInteractionEnabled = false
        reloadAllComponents()
    }
    
    func unlockPicker()
    {
        pickerEnabled = true
        isUserInteractionEnabled = true
        
        reloadAllComponents()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerEnabled
        {
            switch component {
            case 0:
                return 3
            case 1:
                return 2
            case 2:
                return 6
            case 3:
                return 3
            case 4:
                return 4
            default:
                return 0
            }
        }
        else
        {
            return 1
        }
    }
    /*
     now we use viewForRow, so this is no longer called
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var selectedRow = row
        if !pickerEnabled {
            selectedRow = pickerSelected[component]
        }
        
        switch component  {
        case 0:
            return arPerson[selectedRow]
        case 1:
            return arNumber[selectedRow]
        case 2:
            return arTense[selectedRow]
        case 3:
            return arVoice[selectedRow]
        case 4:
            return arMood[selectedRow]
        default:
            return ""
        }
    }
    */
    func getNumChanged() -> Int
    {
        var numChanged = 0
        for (index,_) in pickerSelected.enumerated()
        {
            if pickerSelected[index] != pickerOrigSelected[index]
            {
                numChanged += 1
            }
        }
        
        return numChanged
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow: Int, inComponent: Int)
    {
        pickerSelected[inComponent] = didSelectRow
        
        let numChanged = getNumChanged()
        if numChanged > maxChangedComponents
        {
            //print("too many: \(numChanged)")
            pickerSelected[inComponent] = pickerOrigSelected[inComponent]
            selectRow(pickerOrigSelected[inComponent], inComponent: inComponent, animated: true)
        }
        else
        {
            //print("not too many: \(numChanged)")
        }
        reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component  {
        case 0:
            return 50.0
        case 1:
            return 60.0
        case 2:
            return 80.0
        case 3:
            return 70.0
        case 4:
            return 80.0
        default:
            return 0.0
        }
    }
}
