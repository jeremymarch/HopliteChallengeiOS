//
//  TypeLabel.swift
//  hctest
//
//  Created by Jeremy March on 3/12/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation
import UIKit

/* another way to do this: https://github.com/cl7/CLTypingLabel/blob/master/Example/CLTypingLabel/ViewController.swift
 */

class TypeLabel: UILabel {
    var str:String? = nil
    var steps:Int = 0
    var timerDisplayLink:CADisplayLink?
    var startTime:CFTimeInterval = 0
    var duration:CFTimeInterval = 0
    var currentStep:Int = 0
    var att:NSMutableAttributedString? = nil
    var attTextColor:UIColor = UIColor.black
    var onComplete:( ()->Void )? = nil
    var after:Double = 0.0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func hide(duration:TimeInterval, after:Double, onComplete: @escaping ()->Void )
    {
        self.onComplete = onComplete
        self.after = after
        hide(duration:duration)
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
            timerDisplayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        }
        else
        {
            self.attributedText = nil
            self.text = ""
            self.att = nil
        }
    }

    func type(newAttributedText:NSMutableAttributedString, duration:TimeInterval)
    {
        self.type2(newAttributedText:newAttributedText, duration:duration, after:0.0, onComplete:nil)
    }
    
    func type2(newAttributedText:NSMutableAttributedString, duration:TimeInterval, after:Double, onComplete: (()->Void)?) /*optional closures are escaping by default*/
    {
        if newAttributedText.length < 1
        {
            return
        }
        self.after = after
        self.onComplete = onComplete
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
    
    func type(newText:String, duration:TimeInterval )
    {
        type(newText:newText, duration:duration, after:0.0, onComplete: nil)
    }
    
    func type(newText:String, duration:TimeInterval, after:Double, onComplete: (()->Void)?)
    {
        if newText.count > 0
        {
            type2(newAttributedText:NSMutableAttributedString.init(string: newText), duration:duration, after: after, onComplete: onComplete)
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
                if onComplete != nil
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.after) {
                        self.onComplete!()
                        self.onComplete = nil
                    }
                }
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
                if onComplete != nil
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.after) {
                        self.onComplete!()
                        self.onComplete = nil
                    }
                }
            }
        }
    }
}
