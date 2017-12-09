//
//  CardView.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 12/8/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class CardView: UIView {
    var label1:UILabel?
    var innerView:UIView?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        innerView = UIView.init(frame: frame)
        innerView?.backgroundColor = .white
        innerView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(innerView!)
        /*
        if #available(iOS 9.0, *)
        {
            innerView?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20.0).isActive = true
            innerView?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20.0).isActive = true
            innerView?.topAnchor.constraint(equalTo: self.topAnchor, constant: 20.0).isActive = true
            innerView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20.0).isActive = true
        }
        else
        {
            // Fallback for ios 8.0
            let leftC = NSLayoutConstraint(item: innerView!, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.inputView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 20)
            
            let topC = NSLayoutConstraint(item: innerView!, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.inputView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 20)
            
            let rightC = NSLayoutConstraint(item: innerView!, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.inputView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 20)
            
            let bottomC = NSLayoutConstraint(item: innerView!, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.inputView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 20)
            
            self.addConstraints([leftC,topC,rightC,bottomC])
        }
        */
        
        label1 = UILabel.init(frame:innerView!.frame)
        label1?.textAlignment = .center
        label1?.layer.borderColor = UIColor.black.cgColor
        label1?.layer.borderWidth = 2.0
        //label1?.backgroundColor = .blue
        innerView?.addSubview(label1!)
    }
    override func layoutSubviews() {
        let f = self.frame
        let f2 = CGRect(x: f.minX + 30, y: f.minY + 90, width: f.width - 60, height: f.height - 180)
        innerView!.frame = f2
        label1?.frame = CGRect(x: 0, y: 0, width: innerView!.frame.width, height: innerView!.frame.height)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
