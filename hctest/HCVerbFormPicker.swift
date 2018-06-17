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
 
        pickerSelected = [ person, number, tense, voice, mood ]
        pickerOrigSelected = [ person, number, tense, voice, mood ]
        
        selectRow(person, inComponent: 0, animated: false)
        selectRow(number, inComponent: 1, animated: false)
        selectRow(tense, inComponent: 2, animated: false)
        selectRow(voice, inComponent: 3, animated: false)
        selectRow(mood, inComponent: 4, animated: false)
        
        if locked
        {
            lockPicker()
        }
        else
        {
            unlockPicker()
        }
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow: Int, inComponent: Int)
    {
        pickerSelected[inComponent] = didSelectRow
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
