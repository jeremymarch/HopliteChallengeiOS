//
//  HCGame.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 5/24/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//for android:
//https://stackoverflow.com/questions/33053765/how-to-make-a-wheel-picker

class HCGameViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var lemmaLabel:UITextField?
    var pickerEnabled = true
    var kb:KeyboardViewController? = nil
    let person = ["1st","2nd","3rd"]
    let number = ["sing.", "pl."]
    let tense = ["pres.","imperf.","fut.","aor.","perf.","plup."]
    let voice = ["act.","mid.","pass."]
    let mood = ["ind.", "subj.", "opt.", "imper."]
    let picker = UIPickerView()
    var pickerPerson = 0
    var pickerNumber = 0
    var pickerTense = 0
    var pickerVoice = 0
    var pickerMood = 0
    var pickerSelected = [ 0, 1, 0, 1, 0 ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(picker)
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        picker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        unlockPicker()
    }
    
    func lockPicker()
    {
        pickerEnabled = false
        picker.isUserInteractionEnabled = false
        picker.reloadAllComponents()
    }
    
    func unlockPicker()
    {
        pickerEnabled = true
        picker.isUserInteractionEnabled = true
        picker.reloadAllComponents()
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
            /*
            switch component  {
            case 0:
                selectedRow = pickerPerson
            case 1:
                selectedRow = pickerNumber
            case 2:
                selectedRow = pickerTense
            case 3:
                selectedRow = pickerVoice
            case 4:
                selectedRow = pickerMood
            default:
                selectedRow = 0
            }
 */
        }
        
        switch component  {
        case 0:
            return person[selectedRow]
        case 1:
            return number[selectedRow]
        case 2:
            return tense[selectedRow]
        case 3:
            return voice[selectedRow]
        case 4:
            return mood[selectedRow]
        default:
            return ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
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

