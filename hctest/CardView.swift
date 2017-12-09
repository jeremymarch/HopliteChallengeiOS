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
    var label2:UILabel?
    var innerView:UIView?
    var frontView:UIView?
    var backView:UIView?
    private var showingBack = false
    
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
        self.backgroundColor = UIColor.clear
        innerView = UIView.init(frame: frame)
        frontView = UIView.init(frame: frame)
        backView = UIView.init(frame: frame)
        innerView?.backgroundColor = .white
        frontView?.backgroundColor = .white
        backView?.backgroundColor = .white
        innerView?.translatesAutoresizingMaskIntoConstraints = false
        frontView?.translatesAutoresizingMaskIntoConstraints = false
        backView?.translatesAutoresizingMaskIntoConstraints = false
        frontView?.isUserInteractionEnabled = false //allows tap to pass through
        backView?.isUserInteractionEnabled = false
        
        frontView?.layer.borderColor = UIColor.black.cgColor
        frontView?.layer.borderWidth = 2.0
        backView?.layer.borderColor = UIColor.black.cgColor
        backView?.layer.borderWidth = 2.0

        self.addSubview(innerView!)
        self.addSubview(frontView!)
        //self.addSubview(backView!)
        
        //frontView?.contentMode = .scaleAspectFit
        //backView?.contentMode = .scaleAspectFit
        //frontView.spanSuperview()
        
        //https://stackoverflow.com/questions/39519102/ios-card-flip-animation
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(flip))
        singleTap.numberOfTapsRequired = 1
        innerView?.addGestureRecognizer(singleTap)
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
        label1?.font = UIFont(name: "NewAthenaUnicode", size: 28)
        
        label2 = UILabel.init(frame:innerView!.frame)
        label2?.textAlignment = .center
        label2?.font = UIFont(name: "NewAthenaUnicode", size: 28)
        
        //label1?.backgroundColor = .blue
        frontView?.addSubview(label1!)
        backView?.addSubview(label2!)
    }
    
    @objc func flip() {
        print("flip")
        let toView = showingBack ? frontView : backView
        let fromView = showingBack ? backView : frontView
        UIView.transition(from: fromView!, to: toView!, duration: 0.6, options: .transitionFlipFromRight, completion: nil)
        toView!.translatesAutoresizingMaskIntoConstraints = false
        //toView!.spanSuperview()
        showingBack = !showingBack
    }
    
    override func layoutSubviews() {
        let f = self.frame
        let f2 = CGRect(x: f.minX + 30, y: f.minY + 90, width: f.width - 60, height: f.height - 180)
        innerView!.frame = f2
        frontView!.frame = f2
        backView!.frame = f2
        label1?.frame = CGRect(x: 0, y: 0, width: innerView!.frame.width, height: innerView!.frame.height)
        label2?.frame = CGRect(x: 0, y: 0, width: innerView!.frame.width, height: innerView!.frame.height)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
