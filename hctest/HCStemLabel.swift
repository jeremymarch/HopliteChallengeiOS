//
//  HCStemLabel.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 5/25/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//

import UIKit

class HCStemLabel: UILabel {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func hide(duration:TimeInterval)
    {
        self.duration = duration
        currentStep = 0
        
        if att != nil && (att?.length)! > 0 //self.attributedText != nil && (self.attributedText?.length)! > 0
        {
            steps = (att?.length)!
            startTime = CACurrentMediaTime()
            timerDisplayLink = CADisplayLink.init(target: self, selector: #selector(updateHideAtt))
            timerDisplayLink?.frameInterval = 1
            timerDisplayLink?.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
        }
        else
        {
            self.attributedText = nil
            self.text = ""
            self.att = nil
        }
    }
    
    func setVerbForm(person:Int, number:Int, tense:Int, voice:Int, mood:Int, locked:Bool)
    {
        text = "\(person) \(number)..."
    }
    
    func attributedDescription(orig:String, new:String) -> NSMutableAttributedString
    {
        var a = orig.components(separatedBy: " ")
        var b = new.components(separatedBy: " ")
        
        let att = NSMutableAttributedString.init(string: new)
        var start = 0
        for i in 0...4
        {
            if a[i] != b[i]
            {
                att.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "HelveticaNeue-Bold", size: 14)!, range: NSRange(location: start, length: b[i].count))
            }
            start += b[i].count + 1
        }
        return att
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
            att?.addAttribute(NSAttributedStringKey.foregroundColor, value: attTextColor, range: NSRange(location: 0, length: newStep))
            self.attributedText = att
            currentStep = newStep
            
            if currentStep == steps
            {
                timerDisplayLink?.invalidate()
                timerDisplayLink?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
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
            att?.addAttribute(NSAttributedStringKey.foregroundColor, value: backgroundColor as Any, range: NSRange(location: steps - newStep, length: newStep))
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
