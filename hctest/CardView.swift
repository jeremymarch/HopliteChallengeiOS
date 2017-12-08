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
        self.backgroundColor = .red
        label1 = UILabel.init(frame:frame)
        label1?.textAlignment = .center
        //label1?.backgroundColor = .blue
        self.addSubview(label1!)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
