//
//  ViewController.swift
//  hctest
//
//  Created by Jeremy March on 3/4/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate  {
    var kb:KeyboardViewController? = nil
    var label1 = UILabel()
    var label2 = UILabel()
    let stemLabel = UILabel()
    let textView = UITextView()
    let continueButton = UIButton()
    let headerView = UIView()
    let timerLabel = HCTimer() //UILabel()
    let quitButton = UIButton()
    let scoreLabel = UILabel()
    let mfLabel = UILabel()
    let checkImg = UIImage(named:"greencheck.png")
    let xImg = UIImage(named:"redx.png")
    let checkXView = UIImageView()
    
    let life1 = UIImageView()
    let life2 = UIImageView()
    let life3 = UIImageView()
    
    var label1Top:NSLayoutConstraint?
    var stemLabelTop:NSLayoutConstraint?
    var textViewTop:NSLayoutConstraint?
    var label2Top:NSLayoutConstraint?
    var a:Bool = true
    
    var timeFontSize:CGFloat = 24.0
    var fontSize:CGFloat = 30.0
    var greekFontSize:CGFloat = 40.0
    let hcblue:UIColor = UIColor(colorLiteralRed: 0.0, green: 0.47, blue: 1.0, alpha: 1.0)
    let hcorange:UIColor = UIColor(colorLiteralRed: 1.0, green: 0.2196, blue: 0.0, alpha: 1.0)
    let testColors:Bool = false
    
    let animateDuration:TimeInterval = 0.4
    
    var askOrAnswer:Bool = true
    var mfPressed:Bool = false
    var blockContinueButton:Bool = false
    var checkXXOffset:NSLayoutConstraint? = nil
    
    let vs:VerbSequence = VerbSequence()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let m = VerbForm(person:0, number:0, tense:0, voice:0, mood:0, verb:4)
        //NSLog("here: \(m.getForm())")
        
        textView.delegate = self
        
        //these 3 lines prevent undo/redo/paste from displaying above keyboard on ipad
        if #available(iOS 9.0, *)
        {
            let item : UITextInputAssistantItem = textView.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            timeFontSize = 24.0;
            fontSize = 30.0;
            greekFontSize = 40.0;
        }
        else //if UIDevice.current.userInterfaceIdiom == .phone
        {
            switch UIScreen.main.nativeBounds.height
            {
            case 480:       //iPhone Classic
                timeFontSize = 20.0
                fontSize = 24.0
                greekFontSize = 28.0
                
            case 960:       //iPhone 4 or 4S
                timeFontSize = 20.0
                fontSize = 24.0
                greekFontSize = 28.0
                
            case 1136:      //iPhone 5 or 5S or 5C
                timeFontSize = 22.0
                fontSize = 24.0
                greekFontSize = 32.0
                
            case 1334:      //iPhone 6 or 6S
                timeFontSize = 22.0
                fontSize = 28.0
                greekFontSize = 36.0
                
            case 2208:      //iPhone 6+ or 6S+
                timeFontSize = 24.0
                fontSize = 28.0
                greekFontSize = 36.0
                
            default:
                timeFontSize = 22.0
                fontSize = 24.0
                greekFontSize = 32.0
            }
        }
        
        let greekFont = UIFont(name: "NewAthenaUnicode", size: greekFontSize)
        let headerFont = UIFont(name: "HelveticaNeue-Light", size: timeFontSize)
        let stemFont = UIFont(name: "HelveticaNeue-Light", size: fontSize)
        let continueFont = UIFont(name: "HelveticaNeue", size: fontSize)
        
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false;
        headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 6.0).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.0, constant: 52.0).isActive = true
        headerView.backgroundColor = UIColor.white
        
        headerView.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false;
        timerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0.0).isActive = true
        timerLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -6.0).isActive = true
        timerLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.54, constant: 0.0).isActive = true
        timerLabel.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        timerLabel.backgroundColor = UIColor.white
        timerLabel.textColor = UIColor.black
        timerLabel.text = "30.00 sec"
        timerLabel.textAlignment = NSTextAlignment.right
        timerLabel.font = headerFont
        
        headerView.addSubview(quitButton)
        quitButton.translatesAutoresizingMaskIntoConstraints = false;
        quitButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0.0).isActive = true
        quitButton.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 6.0).isActive = true
        quitButton.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.54, constant: 0.0).isActive = true
        quitButton.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        quitButton.backgroundColor = UIColor.white
        quitButton.setTitleColor(UIColor.black, for: [])
        quitButton.setTitle("X", for: [])
        quitButton.titleLabel?.font = headerFont
        quitButton.layer.borderWidth = 2.0
        quitButton.layer.borderColor = UIColor.gray.cgColor
        quitButton.layer.cornerRadius = 4.0

        
        headerView.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false;
        scoreLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0.0).isActive = true
        scoreLabel.leftAnchor.constraint(equalTo: quitButton.rightAnchor, constant: 6.0).isActive = true
        scoreLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.54, constant: 0.0).isActive = true
        scoreLabel.widthAnchor.constraint(equalToConstant: 90.0).isActive = true
        scoreLabel.backgroundColor = UIColor.white
        scoreLabel.textColor = UIColor.black
        scoreLabel.text = "109939"
        scoreLabel.textAlignment = NSTextAlignment.left
        scoreLabel.font = headerFont
        
        headerView.addSubview(mfLabel)
        mfLabel.translatesAutoresizingMaskIntoConstraints = false;
        mfLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0.0).isActive = true
        mfLabel.rightAnchor.constraint(equalTo: timerLabel.leftAnchor, constant: -6.0).isActive = true
        mfLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.54, constant: 0.0).isActive = true
        mfLabel.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        mfLabel.backgroundColor = UIColor.white
        mfLabel.textColor = hcorange
        mfLabel.text = "MF"
        mfLabel.textAlignment = NSTextAlignment.center
        mfLabel.font = headerFont
        mfLabel.layer.borderWidth = 2.0
        mfLabel.layer.borderColor = hcorange.cgColor
        mfLabel.layer.cornerRadius = 4.0
        mfLabel.isHidden = true
        
        let life1i = UIImage(named:"Life4X.png")
        headerView.addSubview(life1)
        life1.translatesAutoresizingMaskIntoConstraints = false;
        life1.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0).isActive = true
        life1.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -6.0).isActive = true
        life1.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        life1.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        life1.image = life1i
        
        headerView.addSubview(life2)
        life2.translatesAutoresizingMaskIntoConstraints = false;
        life2.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0).isActive = true
        life2.rightAnchor.constraint(equalTo: life1.leftAnchor, constant: -4.0).isActive = true
        life2.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        life2.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        life2.image = life1i
        
        headerView.addSubview(life3)
        life3.translatesAutoresizingMaskIntoConstraints = false;
        life3.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0).isActive = true
        life3.rightAnchor.constraint(equalTo: life2.leftAnchor, constant: -4.0).isActive = true
        life3.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        life3.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        life3.image = life1i
        
        view.addSubview(label1)
        label1.translatesAutoresizingMaskIntoConstraints = false;
        label1.textAlignment = NSTextAlignment.center
        
        label1Top = label1.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0)
        label1Top?.isActive = true
        
        label1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        label1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        label1.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.22).isActive = true
        label1.backgroundColor = UIColor.white
        label1.font = greekFont
        
        
        view.addSubview(stemLabel)
        stemLabel.translatesAutoresizingMaskIntoConstraints = false;
        stemLabel.textAlignment = NSTextAlignment.center
        stemLabelTop = stemLabel.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 0.0)
        stemLabelTop?.isActive = true
        stemLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        stemLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        stemLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08).isActive = true
        stemLabel.textColor = UIColor.gray
        stemLabel.backgroundColor = UIColor.white
        stemLabel.text = "1st pl. aor. act. ind."
        stemLabel.font = stemFont

        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false;
        textView.textAlignment = NSTextAlignment.center
        textViewTop = textView.topAnchor.constraint(equalTo: stemLabel.bottomAnchor, constant: 0.0)
        textViewTop?.isActive = true
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        textView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.22).isActive = true
        textView.backgroundColor = UIColor.white
        textView.font = greekFont
        
        view.addSubview(label2)
        label2.translatesAutoresizingMaskIntoConstraints = false;
        label2.textAlignment = NSTextAlignment.center
        label2Top = label2.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0.0)
        label2Top?.isActive = true
        label2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        label2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        label2.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.22).isActive = true
        label2.backgroundColor = UIColor.white
        label2.font = greekFont
        
        view.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false;
        continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6.0).isActive = true
        continueButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        continueButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        continueButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.0, constant:60.0).isActive = true
        continueButton.backgroundColor = hcblue
        continueButton.layer.cornerRadius = 2.0
        continueButton.setTitle("Continue", for: [])
        continueButton.titleLabel?.textColor = UIColor.white
        continueButton.titleLabel?.font = continueFont
        
        view.addSubview(checkXView)
        checkXView.translatesAutoresizingMaskIntoConstraints = false
        checkXView.image = checkImg
        checkXView.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        checkXView.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        view.addConstraint(NSLayoutConstraint(item: checkXView, attribute:NSLayoutAttribute.centerY , relatedBy: NSLayoutRelation.equal, toItem: textView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
        checkXXOffset = NSLayoutConstraint(item: checkXView, attribute:NSLayoutAttribute.centerX , relatedBy: NSLayoutRelation.equal, toItem: textView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 00.0)
        view.addConstraint(checkXXOffset!)
        checkXView.isHidden = true
        
        kb = KeyboardViewController() //kb needs to be member variable, can't be local to just this function
        kb?.appExt = false
        textView.inputView = kb?.view
        
        continueButton.addTarget(self, action: #selector(continuePressed(button:)), for: .touchUpInside)
        
        timerLabel.countDownTime = 30
        timerLabel.countDown = true
        timerLabel.startTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTimeOut), name: NSNotification.Name(rawValue: "HCTimeOut"), object: nil)
        
        vs.DBInit2()
        
        start()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateLabelUp()
    {
        label1.text = ""
        stemLabel.text = ""
        textView.text = ""
        
        label2Top?.isActive = false
        label2Top = label2.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0)
        label2Top?.isActive = true
        view.bringSubview(toFront: self.label2)
        
        UIView.animate(withDuration: animateDuration, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
            
        }, completion: {
            (value: Bool) in
            
            self.stemLabelTop?.isActive = false
            self.stemLabelTop = self.stemLabel.topAnchor.constraint(equalTo: self.label2.bottomAnchor, constant: 0.0)
            self.stemLabelTop?.isActive = true
            
            self.label1Top?.isActive = false
            self.label1Top = self.label1.topAnchor.constraint(equalTo: self.textView.bottomAnchor, constant: 0.0)
            self.label1Top?.isActive = true
            
            var temp:UILabel?
            temp = self.label2
            self.label2 = self.label1
            self.label1 = temp!
            
            var tempCon:NSLayoutConstraint?
            tempCon = self.label2Top
            self.label2Top = self.label1Top
            self.label1Top = tempCon!
            self.askForForm()
        })
    }
    
    func animatetextViewUp()
    {
        label1.text = ""
        stemLabel.text = ""
        
        self.textViewTop?.isActive = false
        self.textViewTop = self.textView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 0.0)
        self.textViewTop?.isActive = true
        
        view.bringSubview(toFront: self.textView)
        
        UIView.animate(withDuration: animateDuration, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
            
        }, completion: {
            (value: Bool) in
            
            self.label1.text = self.textView.text
            self.textView.text = ""
            
            self.textViewTop?.isActive = false
            self.textViewTop = self.textView.topAnchor.constraint(equalTo: self.stemLabel.bottomAnchor, constant: 0.0)
            self.textViewTop?.isActive = true
            self.askForForm()
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
        positionCheckX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //http://stackoverflow.com/questions/12591192/center-text-vertically-in-a-uitextview
        //see below
        textView.addObserver(self, forKeyPath: "contentSize", options: [.new], context: nil)
        
        //addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }
    
    //http://stackoverflow.com/questions/12591192/center-text-vertically-in-a-uitextview
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let tv = object as! UITextView
        var topCorrect:CGFloat  = (tv.bounds.size.height - tv.contentSize.height * tv.zoomScale) / 2.0;
        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect )
        //NSLog(@"content: %f, %f, %f", topCorrect, [tv bounds].size.height, [tv contentSize].height);
        tv.contentInset = UIEdgeInsetsMake(topCorrect,0,0,0)
    }
    
    func printVerbs()
    {
        var vf:VerbForm?
        var s:String?
        var count = 0
        
        for v in 0...NUM_VERBS
        {
            for t in 0...NUM_TENSES
            {
                for voice in 0...NUM_VOICES
                {
                    for mood in 0...NUM_MOODS
                    {
                        /*
                         if (!isOida && m != INDICATIVE && (g1 == PERFECT || g1 == PLUPERFECT || g1 == IMPERFECT || g1 == FUTURE))
                         continue;
                         else if (isOida && m != INDICATIVE && (g1 == PLUPERFECT || g1 == IMPERFECT || g1 == FUTURE))
                         continue;
                         */
                        for person in 0...NUM_PERSONS
                        {
                            for number in 0...NUM_NUMBERS
                            {
                                var z:Int = Int(v)
                                vf = VerbForm(person: UInt8(person), number: UInt8(number), tense: UInt8(t), voice: UInt8(voice), mood: UInt8(mood), verb: z)
                                s = vf?.getForm()
                                if s != nil && (s?.characters.count)! > 0
                                {
                                    label1.text = s
                                    count += 1
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        NSLog("Count: \(count)")
    }
    
    //this lets us catch the enter key
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"
        {
            enterKeyPressed()
            // Return FALSE so that the final '\n' character doesn't get added
            return false;
        }
        else if text == "MF"
        {
            mfKeyPressed()
            // Return FALSE so that the final '\n' character doesn't get added
            return false;
        }
        
        // For any other character return TRUE so that the text gets added to the view
        return true
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
                att.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: fontSize)!, range: NSRange(location: start, length: b[i].characters.count))
            }
            start += b[i].characters.count + 1
        }
        return att
    }
    
    func enterKeyPressed()
    {
        timerLabel.stopTimer()
        checkAnswer()
    }
    
    func sizeOfString(v:UITextView) -> CGSize
    {
        let s: String = v.text
        let myString: NSString = s as NSString
        return myString.size(attributes: [NSFontAttributeName: v.font!])
    }
    
    func positionCheckX()
    {
        // 0 = center
        //set offset from end of text
        var offset:CGFloat = 0
        if textView.text.characters.count > 0
        {
            offset = (sizeOfString(v: textView).width / 2) + 20
        }
        //make sure it doesn't go off the screen
        if offset > textView.bounds.width / 2
        {
            offset = (textView.bounds.width / 2) - checkXView.bounds.width
        }
        checkXXOffset?.constant = offset
        //NSLog("Width: \(textView.bounds.width), \(sizeOfString(v: textView).width), \(offset)")
    }
    
    func checkAnswer()
    {
        textView.isEditable = false
        textView.isSelectable = false
        textView.resignFirstResponder()
        blockContinueButton = false
        
        positionCheckX()
        
        if vs.checkVerb(givenForm1: (vs.requestedForm?.getForm())!, enteredForm1: textView.text, mfPressed: false, time: "234") == true
        {
            NSLog("yes!")
            
            checkXView.image = checkImg
            checkXView.isHidden = false
            
        }
        else
        {
            textView.textColor = UIColor.gray
            showAnswer()
            NSLog("no!")
            checkXView.image = xImg
            checkXView.isHidden = false
        }
    }
    
    func continuePressed(button: UIButton) {
        checkXView.isHidden = true
        if blockContinueButton == false
        {
            blockContinueButton = true
            let b:Int = Int((vs.options?.repsPerVerb)!)
            
            if vs.seq == b
            {
                label2.text = ""
                textView.text = ""
                askForForm()
            }
            else
            {
                if label2.isHidden == true
                {
                    animatetextViewUp()
                }
                else
                {
                    animateLabelUp()
                }
            }
        }
    }
    
    func mfKeyPressed()
    {
        if mfPressed == false
        {
            mfPressed = true
            mfLabel.isHidden = false
            if vs.requestedForm?.getForm().contains(",") == false
            {
                timerLabel.stopTimer()
                checkAnswer()
            }
            else
            {
                //1.5 x the time
                let halfTime = timerLabel.countDownTime / 2
                timerLabel.startTime += halfTime
            }
        }
    }
    
    func start()
    {
        vs.reset()
        askForForm()
    }
    
    func askForForm()
    {
        vs.getNext()
        label1.text = vs.givenForm?.getForm()
        label1.isHidden = false
        //stemLabel.text = vs.requestedForm?.getDescription()
        stemLabel.attributedText = attributedDescription(orig: (vs.givenForm?.getDescription())!, new: (vs.requestedForm?.getDescription())!)
        label2.isHidden = true
        label2.text = vs.requestedForm?.getForm()
        textView.isEditable = true
        textView.isSelectable = true
        textView.textColor = UIColor.black
        textView.becomeFirstResponder()
        mfPressed = false
        mfLabel.isHidden = true
        timerLabel.startTimer()
    }
    
    func showAnswer()
    {
        label2.isHidden = false
    }
    
    func handleTimeOut()
    {
        NSLog("time out")
        
        checkAnswer()
    }
    

}

