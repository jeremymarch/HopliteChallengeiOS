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
    var kb:HopliteChallengeKB?
    let unicodeMode = 3
    
    let COMBINING_GRAVE =            0x0300
    let COMBINING_ACUTE =            0x0301
    let COMBINING_CIRCUMFLEX =       0x0342//0x0302
    let COMBINING_MACRON =           0x0304
    let COMBINING_BREVE =            0x0306
    let COMBINING_DIAERESIS =        0x0308
    let COMBINING_SMOOTH_BREATHING = 0x0313
    let COMBINING_ROUGH_BREATHING =  0x0314
    let COMBINING_IOTA_SUBSCRIPT =   0x0345
    let EM_DASH =                    0x2014
    let LEFT_PARENTHESIS =           0x0028
    let RIGHT_PARENTHESIS =          0x0029
    let SPACE =                      0x0020
    let EN_DASH =                    0x2013
    let HYPHEN =                     0x2010
    let COMMA =                      0x002C
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
    }
    
    func setKB(kb:HopliteChallengeKB)
    {
        self.kb = kb
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
            UIKeyCommand(input: "9", modifierFlags: [], action: #selector(extDiacriticKeyPressed), discoverabilityTitle: "Diaeresis"),
            UIKeyCommand(input: "0", modifierFlags: [], action: #selector(extDiacriticKeyPressed), discoverabilityTitle: "Parentheses")]
    }

    @objc func extDiacriticKeyPressed(sender: UIKeyCommand) {
        let i = sender.input
        
        var diacritic = -1
        switch ( i! )
        {
        case "1":
            diacritic = 5 //rough
        case "2":
            diacritic = 6 //smooth
        case "3":
            diacritic = 1 //acute
        case "4":
            diacritic = 3 //grave
        case "5":
            diacritic = 2 //circumflex
        case "6":
            diacritic = 4 //macron
        case "7":
            diacritic = 10//breve
        case "8":
            diacritic = 7//iota subscript
        case "9":
            diacritic = 9//diaeresis
        case "0":
            diacritic = 8//parens
        default:
            return
        }
        //self.kb!.sendButton(button: a)
        accentChar(type: diacritic)
        //self.kb!.diacriticPressed(accent: a)
    }
    
    func characterBeforeCursor() -> String? {
        // get the cursor position
        if let cursorRange = selectedTextRange {
            // get the position one character before the cursor start position
            //if let newPosition = position(from: cursorRange.start, offset: -2) {
                let range = textRange(from: beginningOfDocument, to: cursorRange.start)
                return text(in: range!)
            //}
        }
        return nil
    }
    
    func rangeBeforeCursor(replaceLen:Int) -> UITextRange? {
        // get the cursor position
        if let cursorRange = selectedTextRange {
            // get the position one character before the cursor start position
            if let newPosition = position(from: cursorRange.start, offset: -replaceLen) {
                let range = textRange(from: newPosition, to: cursorRange.start)
                return range
            }
        }
        return nil
    }
    
    func accentChar(type:Int)
    {
        if let a = characterBeforeCursor(), a.count > 0
        {
            var replaceLen = 0
            let b = diacriticPressed(accent: type, context: a, replaceLen: &replaceLen)
            //insertText(b)4
            if let range = rangeBeforeCursor(replaceLen: replaceLen)
            {
                replace(range, withText: b)
            }
        }
    }
    
    func diacriticPressed(accent:Int, context:String, replaceLen:inout Int) -> String
    {
        assert(context.count > 0, "Cannot accent empty string")
        assert(unicodeMode == 3, "Invalid Unicode Mode for Hoplite Challenge")
        if context.count < 1
        {
            return ""
        }
        //accentSyllable(&context?.utf16, context.count, &context.count, 1, false);
        /*
         let bufferSize = 200
         var nameBuf = [Int8](repeating: 0, count: bufferSize) // Buffer for C string
         nameBuf[0] = Int8(context![context!.index(before: context!.endIndex)])
         accentSyllableUtf8(&nameBuf, 1, false)
         let name = String(cString: nameBuf)
         */
        
        let combiningChars = [COMBINING_BREVE,COMBINING_GRAVE,COMBINING_ACUTE,COMBINING_CIRCUMFLEX,COMBINING_MACRON,COMBINING_DIAERESIS,COMBINING_SMOOTH_BREATHING,COMBINING_ROUGH_BREATHING,COMBINING_IOTA_SUBSCRIPT]
        
        // 1. make a buffer for the C string
        let bufferSize16 = 12 //5 is max, for safety
        var buffer16 = [UInt16](repeating: 0, count: bufferSize16)
        
        // 2. figure out how many characters to send
        var lenToSend = 1
        let maxCombiningChars = 5
        for a in (context.unicodeScalars).reversed()
        {
            if lenToSend < maxCombiningChars && combiningChars.contains(Int(a.value))
            {
                lenToSend += 1
            }
            else
            {
                break
            }
        }
        
        replaceLen = lenToSend
        print(replaceLen)
        // 3. fill the buffer
        let suf = context.unicodeScalars.suffix(lenToSend)
        var j = 0
        for i in (1...lenToSend).reversed()
        {
            buffer16[j] = UInt16(suf[suf.index(suf.endIndex, offsetBy: -i)].value)
            j += 1
        }
        var len16:Int32 = Int32(lenToSend)

        //print("len: \(len16), accent pressed, umode: \(unicodeMode)")
        
        accentSyllable(&buffer16, 0, &len16, Int32(accent), true, Int32(unicodeMode))
        
        return String(utf16CodeUnits: buffer16, count: Int(len16))
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
