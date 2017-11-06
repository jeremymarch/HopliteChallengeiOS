//
//  TypeLabel.swift
//  hctest
//
//  Created by Jeremy March on 3/12/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation
import UIKit

class TypeTextView: UITextView {
    var str:String? = nil
    var steps:Int = 0
    var timerDisplayLink:CADisplayLink?
    var startTime:CFTimeInterval = 0
    var duration:CFTimeInterval = 0
    var currentStep:Int = 0
    var att:NSMutableAttributedString? = nil
    var attTextColor:UIColor = UIColor.black
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    func hide(duration:TimeInterval)
    {
        self.duration = duration
        currentStep = 0
        
        att = NSMutableAttributedString.init(string: text)
        attributedText = att
        
        if self.attributedText != nil && (self.attributedText?.length)! > 0
        {
            steps = (self.attributedText?.length)!
            startTime = CACurrentMediaTime()
            timerDisplayLink = CADisplayLink.init(target: self, selector: #selector(updateHideAtt))
            timerDisplayLink?.frameInterval = 1
            timerDisplayLink?.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
        }
        else
        {
            self.attributedText = nil
            self.text = ""
        }
    }
    
    func type(newAttributedText:NSMutableAttributedString, duration:TimeInterval)
    {
        if newAttributedText.length < 1
        {
            return
        }
        textColor = backgroundColor
        str = nil
        self.duration = duration
        currentStep = 0
        
        steps = newAttributedText.length
        att = newAttributedText
        
        startTime = CACurrentMediaTime()
        timerDisplayLink = CADisplayLink.init(target: self, selector: #selector(update))
        timerDisplayLink?.frameInterval = 1
        timerDisplayLink?.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
    }
    
    func type(newText:String, duration:TimeInterval)
    {
        if newText.count > 0
        {
            type(newAttributedText:NSMutableAttributedString.init(string: newText), duration:duration)
        }
    }
    
    func update()
    {
        var elapsedTime:CFTimeInterval = CACurrentMediaTime() - startTime
        //NSLog("steps: \(steps), duration: \(duration), elapsed: \(elapsedTime), \(elapsedTime / duration)")
        
        if elapsedTime > duration
        {
            elapsedTime = duration
        }
        
        var newStep = Int(floor((Double(steps) * elapsedTime / duration)))
        if newStep > steps
        {
            newStep = steps
        }
        
        if newStep > currentStep
        {
            att?.addAttribute(NSForegroundColorAttributeName, value: attTextColor, range: NSRange(location: 0, length: newStep))
            self.attributedText = att
            currentStep = newStep
            
            if currentStep == steps
            {
                timerDisplayLink?.invalidate()
                timerDisplayLink?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
            }
        }
    }
    
    func updateHideAtt()
    {
        var elapsedTime:CFTimeInterval = CACurrentMediaTime() - startTime
        //NSLog("steps: \(steps), duration: \(duration), elapsed: \(elapsedTime), \(elapsedTime / duration)")
        
        if elapsedTime > duration
        {
            elapsedTime = duration
        }
        
        var newStep = Int(floor((Double(steps) * elapsedTime / duration)))
        if newStep > steps
        {
            newStep = steps
        }
        
        if newStep > currentStep
        {
            att?.addAttribute(NSForegroundColorAttributeName, value: backgroundColor as Any, range: NSRange(location: steps - newStep, length: newStep))
            self.attributedText = att
            currentStep = newStep
            
            if currentStep == steps
            {
                timerDisplayLink?.invalidate()
                timerDisplayLink?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
                text = ""
                attributedText = nil
                timerDisplayLink = nil
            }
        }
    }
}
