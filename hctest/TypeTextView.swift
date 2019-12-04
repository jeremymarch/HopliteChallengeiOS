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
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
    }
    
//https://stablekernel.com/creating-a-delightful-user-experience-with-ios-keyboard-shortcuts/
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "1", modifierFlags: [], action: #selector(extDiacriticKeyPressed), discoverabilityTitle: "Rough Breathing"),
            UIKeyCommand(input: "2", modifierFlags: [], action: #selector(extDiacriticKeyPressed), discoverabilityTitle: "Smooth Breathing"),
            UIKeyCommand(input: "3", modifierFlags: [], action: #selector(extDiacriticKeyPressed), discoverabilityTitle: "Acute"),
            UIKeyCommand(input: "4", modifierFlags: [], action: #selector(extDiacriticKeyPressed), discoverabilityTitle: "Grave"),
            UIKeyCommand(input: "5", modifierFlags: [], action: #selector(extDiacriticKeyPressed), discoverabilityTitle: "Circumflex"),
            UIKeyCommand(input: "6", modifierFlags: [], action: #selector(extDiacriticKeyPressed), discoverabilityTitle: "Macron"),
            UIKeyCommand(input: "7", modifierFlags: [], action: #selector(extDiacriticKeyPressed), discoverabilityTitle: "Breve"),
            UIKeyCommand(input: "8", modifierFlags: [], action: #selector(extDiacriticKeyPressed), discoverabilityTitle: "Iota Subscript"),
            UIKeyCommand(input: "9", modifierFlags: [], action: #selector(extDiacriticKeyPressed), discoverabilityTitle: "Diaeresis")]
    }

    @objc func extDiacriticKeyPressed(sender: UIKeyCommand) {
        switch (sender.input)
        {
        case "1":
            print("Rough Breathing Pressed")
        default:
            print("other key Pressed")
        }
        
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
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
            timerDisplayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
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
        timerDisplayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
    }
    
    func type(newText:String, duration:TimeInterval)
    {
        if newText.count > 0
        {
            type(newAttributedText:NSMutableAttributedString.init(string: newText), duration:duration)
        }
    }
    
    @objc func update()
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
            att?.addAttribute(NSAttributedString.Key.foregroundColor, value: attTextColor, range: NSRange(location: 0, length: newStep))
            self.attributedText = att
            currentStep = newStep
            
            if currentStep == steps
            {
                timerDisplayLink?.invalidate()
                timerDisplayLink?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            }
        }
    }
    
    @objc func updateHideAtt()
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
            att?.addAttribute(NSAttributedString.Key.foregroundColor, value: backgroundColor as Any, range: NSRange(location: steps - newStep, length: newStep))
            self.attributedText = att
            currentStep = newStep
            
            if currentStep == steps
            {
                timerDisplayLink?.invalidate()
                timerDisplayLink?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
                text = ""
                attributedText = nil
                timerDisplayLink = nil
            }
        }
    }
}
