//
//  AccentsViewController.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 11/11/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class AccentsViewController: UIViewController {
    var accentLabel:AccentTextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accentLabel = AccentTextField.init(frame: .zero)
        
        accentLabel?.text = "Nothing to show"
        accentLabel?.textAlignment = .center
        accentLabel?.backgroundColor = .red  // Set background color to see if label is centered
        accentLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(accentLabel!)
        
        let widthConstraint = NSLayoutConstraint(item: accentLabel!, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 250)
        
        let heightConstraint = NSLayoutConstraint(item: accentLabel!, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        
        let xConstraint = NSLayoutConstraint(item: accentLabel!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yConstraint = NSLayoutConstraint(item: accentLabel!, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
