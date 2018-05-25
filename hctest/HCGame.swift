//
//  HCGame.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 5/24/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//

import UIKit
import CoreData

//for android:
//https://stackoverflow.com/questions/33053765/how-to-make-a-wheel-picker

class HCGameViewController: UIViewController {
    @IBOutlet var lemmaLabel:UITextField?
    var kb:KeyboardViewController? = nil
    let picker = HCVerbFormPicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(picker)
        
        picker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        picker.setVerbForm(person: 2, number: 1, tense: 5, voice: 2, mood: 3, locked: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}

