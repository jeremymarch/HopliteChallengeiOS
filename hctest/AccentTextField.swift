//
//  AccentTextField.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 11/12/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class AccentTextField: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        let pinchRecognizer = UIPanGestureRecognizer(target:self, action:#selector(handlePan))
        self.addGestureRecognizer(pinchRecognizer)
    }
    required override init(frame: CGRect) {
        super.init(frame: frame)
        NSLog("Pan test")
        self.isUserInteractionEnabled = true
        let pinchRecognizer = UIPanGestureRecognizer(target:self, action:#selector(handlePan))
        self.addGestureRecognizer(pinchRecognizer)
        NSLog("Pan test2")
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer)
    {
        NSLog("Pan")
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            let translation = gestureRecognizer.translation(in: self)
            // note: 'view' is optional and need to be unwrapped
            //gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            //gestureRecognizer.setTranslation(CGPoint.zero, in: self)
            
            NSLog("Translation: \(translation.x), \(translation.y)")
        }
        
    }
}
