//
//  gktextview.swift
//  uitextviewtest
//
//  Created by Jeremy on 12/8/19.
//  Copyright © 2019 Jeremy. All rights reserved.
//

import UIKit

class GKTextView:UITextView, UITextViewDelegate
{
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
    
    var transliterate = true
    let romanLetters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    let greekLetters = ["α","β","ψ","δ","ε","φ","γ","η","ι","ξ","κ","λ","μ","ν","ο","π","","ρ","σ","τ","θ","ω","ς","χ","υ","ζ","Α","Β","Ψ","Δ","Ε","Φ","Γ","Η","Ι","Ξ","Κ","Λ","Μ","Ν","Ο","Π","","Ρ","Σ","Τ","Θ","Ω","Σ","Χ","Υ","Ζ"]
    
    required override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        // Remove the padding top and left of the text view
        //self.textContainer.lineFragmentPadding = 0
        //self.textContainerInset = UIEdgeInsets.zero
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transliterate(roman:String) -> String?
    {
        assert(greekLetters.count == romanLetters.count, "Arrays must be equal length")
        
        if let index = romanLetters.firstIndex(of: roman)
        {
            return greekLetters[index]
        }
        return nil
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if transliterate
        {
            //transliterate for external bluetooth keyboards
            if let transliteratedText = transliterate(roman: text), let uirange = range.toTextRange(textInput: textView)
            {
                self.replace(uirange, withText: transliteratedText)
                return false //false prevents character from being added
            }
            return true
        }
        else
        {
            return true
        }
    }
    
    //https://stablekernel.com/creating-a-delightful-user-experience-with-ios-keyboard-shortcuts/
    override var keyCommands: [UIKeyCommand]? {
        
        return [
            //UIKeyCommand(title: "Rough Breathing", image: nil, action: #selector(extDiacriticKeyPressed), input: "1", modifierFlags: [], propertyList: [], alternates: [], discoverabilityTitle: "Rough Breathing", attributes: [], state: .on),
            
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
    
    func charactersBeforeCursor() -> String? {
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
        if let a = charactersBeforeCursor(), a.count > 0
        {
            var replaceLen = 0
            let b = diacriticPressed(accent: type, context: a, replaceLen: &replaceLen)

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
}

extension NSRange {
    //Translate NSRange to UITextRange
    func toTextRange(textInput:UITextInput) -> UITextRange? {
        if let rangeStart = textInput.position(from: textInput.beginningOfDocument, offset: location),
            let rangeEnd = textInput.position(from: rangeStart, offset: length) {
            return textInput.textRange(from: rangeStart, to: rangeEnd)
        }
        return nil
    }
}

