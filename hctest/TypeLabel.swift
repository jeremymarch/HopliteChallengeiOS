//
//  TypeLabel.swift
//  hctest
//
//  Created by Jeremy March on 3/12/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation
import UIKit

class TypeLabel: UILabel {
    var str:String? = nil
    var steps:Int = 0
    var timerDisplayLink:CADisplayLink?
    var startTime:CFTimeInterval = 0
    var duration:CFTimeInterval = 0
    var currentStep:Int = 0
    var att:NSMutableAttributedString? = nil
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func hide(duration:TimeInterval)
    {
        self.duration = duration
        currentStep = 0
        
        steps = (self.attributedText?.length)!
        
        startTime = CACurrentMediaTime()
        timerDisplayLink = CADisplayLink.init(target: self, selector: #selector(updateHideAtt))
        timerDisplayLink?.frameInterval = 1
        timerDisplayLink?.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
    }
    
    func type(newAttributedText:NSMutableAttributedString, duration:TimeInterval)
    {
        textColor = backgroundColor
        str = nil
        self.duration = duration
        currentStep = 0
        
        steps = newAttributedText.length
        att = newAttributedText
        
        startTime = CACurrentMediaTime()
        timerDisplayLink = CADisplayLink.init(target: self, selector: #selector(updateAtt))
        timerDisplayLink?.frameInterval = 1
        timerDisplayLink?.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
    }
    
    func type(newText:String, duration:TimeInterval)
    {
        textColor = backgroundColor
        str = newText
        self.duration = duration
        currentStep = 0
        
        att = NSMutableAttributedString.init(string: str!)
        
        //steps = (str?.characters.count)! //this doesn't work properly with macrons for some reason.  
        //this works:
        steps = (att?.length)!
        
        startTime = CACurrentMediaTime()
        timerDisplayLink = CADisplayLink.init(target: self, selector: #selector(update))
        timerDisplayLink?.frameInterval = 1
        timerDisplayLink?.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
    }

    func update()
    {
        let elapsedTime:CFTimeInterval = CACurrentMediaTime() - startTime
        //NSLog("steps: \(steps), duration: \(duration), elapsed: \(elapsedTime), \(elapsedTime / duration)")
        
        var newStep = Int(floor((Double(steps) * elapsedTime / duration)))
        if newStep > steps
        {
            newStep = steps
        }
        
        if newStep > currentStep
        {
            att?.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: newStep))
            self.attributedText = att
            currentStep = newStep
            
            if currentStep == steps
            {
                timerDisplayLink?.invalidate()
                timerDisplayLink?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
            }
        }
    }
    
    func updateAtt()
    {
        let elapsedTime:CFTimeInterval = CACurrentMediaTime() - startTime
        //NSLog("steps: \(steps), duration: \(duration), elapsed: \(elapsedTime), \(elapsedTime / duration)")
        
        var newStep = Int(floor((Double(steps) * elapsedTime / duration)))
        if newStep > steps
        {
            newStep = steps
        }
        
        if newStep > currentStep
        {
            att?.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray, range: NSRange(location: 0, length: newStep))
            self.attributedText = att
            currentStep = newStep
            
            if currentStep == steps
            {
                timerDisplayLink?.invalidate()
                timerDisplayLink?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
                //text = str
                //textColor = UIColor.black
                //att?.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: (str?.characters.count)!))
                //self.attributedText = att
            }
        }
    }
    
    func updateHideAtt()
    {
        let elapsedTime:CFTimeInterval = CACurrentMediaTime() - startTime
        //NSLog("steps: \(steps), duration: \(duration), elapsed: \(elapsedTime), \(elapsedTime / duration)")
        
        var newStep = Int(floor((Double(steps) * elapsedTime / duration)))
        if newStep > steps
        {
            newStep = steps
        }
        
        if newStep > currentStep
        {
            att?.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location: steps - newStep, length: newStep))
            self.attributedText = att
            currentStep = newStep
            
            if currentStep == steps
            {
                timerDisplayLink?.invalidate()
                timerDisplayLink?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
                text = ""
                attributedText = nil
                //textColor = UIColor.black
                //att?.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: (str?.characters.count)!))
                //self.attributedText = att
            }
        }
    }
}
