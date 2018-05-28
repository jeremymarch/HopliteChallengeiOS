//
//  HCGame.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 5/24/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//

import UIKit

class HCGameViewController: UIViewController, UITextViewDelegate  {
    var kb:KeyboardViewController? = nil
    var gameOverLabel = UILabel()
    var label1 = TypeLabel()
    var label2 = TypeLabel()
    let stemLabel = HCVerbFormPicker()// TypeLabel()
    let textView = TypeTextView()
    let continueButton = UIButton()
    let headerView = UIView()
    let timerLabel = HCTimer()
    let quitButton = UIButton(type: UIButtonType.custom) as UIButton
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
    var textViewTop2:NSLayoutConstraint?
    var label2Top:NSLayoutConstraint?
    
    var timeFontSize:CGFloat = 24.0
    var fontSize:CGFloat = 30.0
    var greekFontSize:CGFloat = 40.0
    let hcblue:UIColor = UIColor(red: 0.0, green: 0.47, blue: 1.0, alpha: 1.0)
    let hcorange:UIColor = UIColor(red: 1.0, green: 0.2196, blue: 0.0, alpha: 1.0)
    let testColors:Bool = false
    
    let animateDuration:TimeInterval = 0.4
    
    var askOrAnswer:Bool = true
    var mfPressed:Bool = false
    var checkXXOffset:NSLayoutConstraint? = nil
    var checkXYOffset:NSLayoutConstraint? = nil
    var isGame:Bool = true
    var practiceVerbId:Int = -1
    let typingDelay:TimeInterval = 0.03
    var blockPinch:Bool = true
    var isExpanded:Bool = false
    
    let vs:VerbSequence = VerbSequence()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vs.options?.practiceVerbID = Int32(practiceVerbId)
        //vs.options?.units = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)
        //vs.options?.numUnits = 20
        vs.options?.isHCGame = isGame
        
        //these 3 lines prevent undo/redo/paste from displaying above keyboard on ipad
        if #available(iOS 9.0, *)
        {
            let item : UITextInputAssistantItem = textView.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        }
        
        var timerLabelWidth:CGFloat = 110.0
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            timeFontSize = 24.0
            fontSize = 30.0
            greekFontSize = 40.0
            timerLabelWidth = 130.0
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
                greekFontSize = 30.0
                
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
        
        var headerHeight:CGFloat = 52.0
        var topHeaderRowHeightMultiple:CGFloat = 0.54
        let lifeSize:CGFloat = 20.0
        
        timerLabel.countDownTime = 30
        timerLabel.countDown = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleTimeOut), name: NSNotification.Name(rawValue: "HCTimeOut"), object: nil)
        
        if isGame == false
        {
            headerHeight = 36.0
            topHeaderRowHeightMultiple = 1.0
            timerLabel.countDown = false
        }
        
        let greekFont = UIFont(name: "NewAthenaUnicode", size: greekFontSize)
        let headerFont = UIFont(name: "HelveticaNeue-Light", size: timeFontSize)
        let stemFont = UIFont(name: "HelveticaNeue-Light", size: fontSize)
        let continueFont = UIFont(name: "HelveticaNeue", size: fontSize)
        
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 6.0).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.0, constant: headerHeight).isActive = true
        headerView.backgroundColor = UIColor.white
        
        headerView.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0.0).isActive = true
        timerLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -6.0).isActive = true
        timerLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: topHeaderRowHeightMultiple, constant: 0.0).isActive = true
        timerLabel.widthAnchor.constraint(equalToConstant: timerLabelWidth).isActive = true
        timerLabel.backgroundColor = UIColor.white
        timerLabel.textColor = UIColor.black
        timerLabel.reset()
        timerLabel.textAlignment = NSTextAlignment.right
        timerLabel.font = headerFont
        
        headerView.addSubview(quitButton)
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        quitButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0.0).isActive = true
        quitButton.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 6.0).isActive = true
        quitButton.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        quitButton.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        quitButton.backgroundColor = UIColor.white
        //quitButton.setTitleColor(UIColor.black, for: [])
        //quitButton.setTitle("X", for: [])
        //quitButton.titleLabel?.font = headerFont
        
        quitButton.layer.borderWidth = 2.0
        quitButton.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0).cgColor
        quitButton.layer.cornerRadius = 4.0
        quitButton.imageEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4)
        
        let image = UIImage(named: "hamburger.png") as UIImage?
        quitButton.setImage(image, for: .normal)
        
        if practiceVerbId < 0
        {
            quitButton.addTarget(self, action: #selector(menuButtonPressed), for: UIControlEvents.touchUpInside)
        }
        else
        {
            //pop controller to go back to verb detail
            quitButton.addTarget(self, action: #selector(goBackToVerbDetail), for: UIControlEvents.touchUpInside)
        }
        
        headerView.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0.0).isActive = true
        scoreLabel.leftAnchor.constraint(equalTo: quitButton.rightAnchor, constant: 8.0).isActive = true
        scoreLabel.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: topHeaderRowHeightMultiple, constant: 0.0).isActive = true
        scoreLabel.widthAnchor.constraint(equalToConstant: 90.0).isActive = true
        scoreLabel.backgroundColor = UIColor.white
        scoreLabel.textColor = UIColor.black
        scoreLabel.text = "0"
        scoreLabel.textAlignment = NSTextAlignment.left
        scoreLabel.font = headerFont
        
        headerView.addSubview(gameOverLabel)
        gameOverLabel.translatesAutoresizingMaskIntoConstraints = false
        gameOverLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0).isActive = true
        gameOverLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -6.0).isActive = true
        gameOverLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        gameOverLabel.widthAnchor.constraint(equalToConstant: 130.0).isActive = true
        gameOverLabel.backgroundColor = UIColor.white
        gameOverLabel.textColor = UIColor.red
        gameOverLabel.text = "Game Over"
        gameOverLabel.textAlignment = NSTextAlignment.right
        gameOverLabel.font = headerFont
        gameOverLabel.isHidden = true
        
        headerView.addSubview(mfLabel)
        mfLabel.translatesAutoresizingMaskIntoConstraints = false
        mfLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0.0).isActive = true
        mfLabel.rightAnchor.constraint(equalTo: timerLabel.leftAnchor, constant: -6.0).isActive = true
        mfLabel.heightAnchor.constraint(equalToConstant: 34.0).isActive = true
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
        life1.translatesAutoresizingMaskIntoConstraints = false
        life1.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0).isActive = true
        life1.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -6.0).isActive = true
        life1.heightAnchor.constraint(equalToConstant: lifeSize).isActive = true
        life1.widthAnchor.constraint(equalToConstant: lifeSize).isActive = true
        life1.image = life1i
        
        headerView.addSubview(life2)
        life2.translatesAutoresizingMaskIntoConstraints = false
        life2.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0).isActive = true
        life2.rightAnchor.constraint(equalTo: life1.leftAnchor, constant: -4.0).isActive = true
        life2.heightAnchor.constraint(equalToConstant: lifeSize).isActive = true
        life2.widthAnchor.constraint(equalToConstant: lifeSize).isActive = true
        life2.image = life1i
        
        headerView.addSubview(life3)
        life3.translatesAutoresizingMaskIntoConstraints = false
        life3.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0).isActive = true
        life3.rightAnchor.constraint(equalTo: life2.leftAnchor, constant: -4.0).isActive = true
        life3.heightAnchor.constraint(equalToConstant: lifeSize).isActive = true
        life3.widthAnchor.constraint(equalToConstant: lifeSize).isActive = true
        life3.image = life1i
        
        view.addSubview(label1)
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.textAlignment = NSTextAlignment.center
        
        label1Top = label1.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0)
        label1Top?.isActive = true
        
        label1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        label1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        label1.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.22).isActive = true
        label1.backgroundColor = UIColor.white
        label1.font = greekFont
        label1.lineBreakMode = .byWordWrapping // or NSLineBreakMode.ByWordWrapping
        label1.numberOfLines = 0
        
        view.addSubview(stemLabel)
        stemLabel.translatesAutoresizingMaskIntoConstraints = false
        //stemLabel.textAlignment = NSTextAlignment.center
        stemLabelTop = stemLabel.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 0.0)
        stemLabelTop?.isActive = true
        stemLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        stemLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        stemLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.16).isActive = true
        //stemLabel.attTextColor = UIColor.gray
        //stemLabel.backgroundColor = UIColor.white
        //stemLabel.text = ""
        //stemLabel.font = stemFont
        
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = NSTextAlignment.center
        textViewTop = textView.topAnchor.constraint(equalTo: stemLabel.bottomAnchor, constant: 0.0)
        textViewTop?.isActive = true
        textViewTop2 = textView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0)
        textViewTop2?.isActive = false
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        textView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.22).isActive = true
        textView.backgroundColor = UIColor.white
        textView.font = greekFont
        textView.delegate = self
        
        view.addSubview(label2)
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.textAlignment = NSTextAlignment.center
        label2Top = label2.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0.0)
        label2Top?.isActive = true
        label2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        label2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        label2.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.22).isActive = true
        label2.backgroundColor = UIColor.white
        label2.font = greekFont
        label2.lineBreakMode = .byWordWrapping // or NSLineBreakMode.ByWordWrapping
        label2.numberOfLines = 0
        
        view.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6.0).isActive = true
        continueButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        continueButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        continueButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.0, constant:60.0).isActive = true
        continueButton.backgroundColor = hcblue
        continueButton.layer.cornerRadius = 2.0
        continueButton.setTitle("Play", for: [])
        continueButton.titleLabel?.textColor = UIColor.white
        continueButton.titleLabel?.font = continueFont
        //continueButton.isEnabled = false
        //continueButton.isHidden = true
        
        view.addSubview(checkXView)
        checkXView.translatesAutoresizingMaskIntoConstraints = false
        checkXView.image = checkImg
        checkXView.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        checkXView.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        
        
        checkXYOffset = NSLayoutConstraint(item: checkXView, attribute:NSLayoutAttribute.centerY , relatedBy: NSLayoutRelation.equal, toItem: textView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0)
        view.addConstraint(checkXYOffset!)
        checkXXOffset = NSLayoutConstraint(item: checkXView, attribute:NSLayoutAttribute.centerX , relatedBy: NSLayoutRelation.equal, toItem: textView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 00.0)
        view.addConstraint(checkXXOffset!)
        checkXView.isHidden = true
        
        kb = KeyboardViewController() //kb needs to be member variable, can't be local to just this function
        kb?.appExt = false
        
        var portraitHeight:CGFloat = 222.0
        var landscapeHeight:CGFloat = 157.0
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            portraitHeight = 340.0
            landscapeHeight = 290.0
        }
        else
        {
            //for iphone 5s and narrower
            if UIScreen.main.nativeBounds.width < 641
            {
                portraitHeight = 200.0
                landscapeHeight = 186.0
            }
            else //larger iPhones
            {
                portraitHeight = 222.0
                landscapeHeight = 157.0
            }
        }
        kb?.heightOverride = portraitHeight
        kb?.unicodeMode = 3 //hc mode
        textView.inputView = kb?.view
        let keys: [[String]] = [["MF", "῾", "᾿", "´", "˜", "¯", "ͺ", "enter"],
                                ["ς", "ε", "ρ", "τ", "υ", "θ", "ι", "ο", "π"],
                                ["α", "σ", "δ", "φ", "γ", "η", "ξ", "κ", "λ"],
                                ["ζ", "χ", "ψ", "ω", "β", "ν", "μ" , "( )", "BK" ]]
        kb?.accentBGColor = UIColor.init(red: 103/255.0, green: 166/255.0, blue: 234/255.0, alpha: 1.0)
        kb?.accentBGColorDown = UIColor.init(red: 103/255.0, green: 166/255.0, blue: 234/255.0, alpha: 1.0)
        kb?.accentTextColor = UIColor.black
        kb?.accentTextColorDown = UIColor.black
        kb?.setButtons(keys: keys) //has to be after set as inputView
        
        continueButton.addTarget(self, action: #selector(continuePressed(button:)), for: .touchUpInside)
        
        if isGame == false
        {
            scoreLabel.isHidden = true
            life1.isHidden = true
            life2.isHidden = true
            life3.isHidden = true
            timerLabel.countDown = false
        }
        
        let pinchRecognizer = UIPinchGestureRecognizer(target:self, action:#selector(handlePinch))
        self.view.addGestureRecognizer(pinchRecognizer)
        NSLog("hc dbinit")
        vs.DBInit2()
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        //    self.start()
        //}
    }
    
    //this doesn't work if used in nav controller, so this is blocked in appDelegate
    override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func menuButtonPressed(sender:UIButton)
    {
        if isGame && timerLabel.isRunning == true //vs.lives > 0
        {
            let isFirstResp = textView.isFirstResponder
            textView.resignFirstResponder()
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to quit this game?", preferredStyle: .alert)
            
            let no = UIAlertAction(title: "Cancel", style: .cancel, handler: { alert in
                if isFirstResp == true
                {
                    self.textView.becomeFirstResponder()
                }
            })
            
            let yes = UIAlertAction(title: "Yes", style: .default, handler: { alert in
                self.timerLabel.stopTimer()
                self.checkAnswer()
                //self.onSlideMenuButtonPressed(sender)
            })
            
            alert.addAction(yes)
            alert.addAction(no)
            
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            textView.resignFirstResponder()
            if timerLabel.isRunning == true
            {
                timerLabel.stopTimer()
                checkAnswer()
            }
            //self.onSlideMenuButtonPressed(sender)
        }
    }
    
    @objc func goBackToVerbDetail()
    {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func animateLabelUp()
    {
        label1.text = ""
        //stemLabel.text = ""
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
            self.label1 = temp! as! TypeLabel
            
            var tempCon:NSLayoutConstraint?
            tempCon = self.label2Top
            self.label2Top = self.label1Top
            self.label1Top = tempCon!
            self.view.bringSubview(toFront:self.checkXView)
            self.view.layoutIfNeeded()
            self.askForForm(erasePreviousForm: false)
        })
    }
    
    func animatetextViewUp()
    {
        label1.text = ""
        //stemLabel.text = ""
        
        self.textViewTop?.isActive = false
        //self.textViewTop = self.textView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 0.0)
        self.textViewTop2?.isActive = true
        
        view.bringSubview(toFront: self.textView)
        
        UIView.animate(withDuration: animateDuration, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
            
        }, completion: {
            (value: Bool) in
            
            self.label1.textColor = UIColor.black
            //self.label1.text = self.textView.text
            let a = NSMutableAttributedString.init(string: self.textView.text)
            self.label1.attributedText = a
            self.label1.att = a
            self.textView.text = ""
            
            self.textViewTop2?.isActive = false
            //self.textViewTop = self.textView.topAnchor.constraint(equalTo: self.stemLabel.bottomAnchor, constant: 0.0)
            self.textViewTop?.isActive = true
            self.view.bringSubview(toFront:self.checkXView)
            self.view.layoutIfNeeded()
            self.askForForm(erasePreviousForm: false)
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
        self.navigationController?.isNavigationBarHidden = true
        
        reloadSettings()
        vs.reset()
    }
    
    func reloadSettings()
    {
        //NSLog("load settings start")
        let def = UserDefaults.standard.object(forKey: "Levels")
        if def != nil
        {
            //NSLog("has setting")
            var units = [Int]()
            let d = def as! [Bool]
            var j = 1
            for i in d
            {
                if i == true
                {
                    units.append(j)
                }
                j += 1
            }
            vs.setUnits(units: units)
            //print(units)
        }
        //NSLog("load settings done")
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
                                let z:Int = Int(v)
                                vf = VerbForm(person: UInt8(person), number: UInt8(number), tense: UInt8(t), voice: UInt8(voice), mood: UInt8(mood), verb: z)
                                s = vf?.getForm(decomposed:false)
                                if s != nil && (s?.count)! > 0
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
                att.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "HelveticaNeue-Bold", size: fontSize)!, range: NSRange(location: start, length: b[i].count))
            }
            start += b[i].count + 1
        }
        return att
    }
    
    func sizeOfString(v:UITextView) -> CGSize
    {
        let s: String = v.text
        let myString: NSString = s as NSString
        return myString.size(withAttributes: [NSAttributedStringKey.font: v.font!])
    }
    
    func positionCheckX()
    {
        // 0 = center
        //set offset from end of text
        var offset:CGFloat = 0
        if textView.text.count > 0
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
    
    func enterKeyPressed()
    {
        timerLabel.stopTimer()
        checkAnswer()
    }
    
    func checkAnswer()
    {
        textView.isEditable = false
        textView.isSelectable = false
        textView.resignFirstResponder()
        continueButton.isHidden = false
        continueButton.isEnabled = true
        blockPinch = false
        
        positionCheckX()
        
        if vs.checkVerb(expectedForm: (vs.requestedForm?.getForm(decomposed:false))!, enteredForm: textView.text, mfPressed: mfPressed, time: String.init(format: "%.02f sec", timerLabel.elapsedTimeForDB)) == true
        {
            NSLog("yes!")
            
            checkXView.image = checkImg
            checkXView.isHidden = false
            if isGame
            {
                setScore(score: vs.score)
            }
        }
        else
        {
            textView.textColor = UIColor.gray
            showAnswer()
            NSLog("no!")
            checkXView.image = xImg
            checkXView.isHidden = false
            if isGame
            {
                setLives(lives: vs.lives)
            }
        }
    }
    
    func setScore(score:Int32)
    {
        scoreLabel.text = String(score)
    }
    
    func setLives(lives:Int)
    {
        switch lives
        {
        case 3:
            life1.isHidden = false
            life2.isHidden = false
            life3.isHidden = false
            gameOverLabel.isHidden = true
        case 2:
            life1.isHidden = false
            life2.isHidden = false
            life3.isHidden = true
            gameOverLabel.isHidden = true
        case 1:
            life1.isHidden = false
            life2.isHidden = true
            life3.isHidden = true
            gameOverLabel.isHidden = true
        case 0:
            life1.isHidden = true
            life2.isHidden = true
            life3.isHidden = true
            gameOverLabel.isHidden = false
            continueButton.setTitle("Play again?", for: [])
        default: break
        }
    }
    
    @objc func continuePressed(button: UIButton) {
        continueButton.isEnabled = false
        
        if continueButton.titleLabel?.text == "Play"
        {
            start()
            return
        }
        
        checkXView.isHidden = true
        unexpand() //has to be called before getNext()
        let ret = vs.getNext()
        
        if isGame && vs.lives == 0
        {
            label2.hide(duration:0.3)
            //stemLabel.hide(duration:0.3)
            label1.hide(duration: 0.3)
            //textView.hide(duration: 0.3)
            textView.text = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.start()
            }
        }
        else if ret == VERB_SEQ_CHANGE_NEW
        {
            label2.hide(duration:0.3)
            //stemLabel.hide(duration:0.3)
            label1.hide(duration: 0.3)
            //textView.hide(duration: 0.3)
            textView.text = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.askForForm(erasePreviousForm: true)
            }
        }
        else
        {
            if label2.isHidden == true || label2.text == ""
            {
                label1.hide(duration: 0.3)
                //stemLabel.hide(duration:0.3)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.animatetextViewUp()
                }
            }
            else
            {
                label1.hide(duration: 0.3)
                //stemLabel.hide(duration:0.3)
                //textView.hide(duration: 0.3)
                textView.text = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.animateLabelUp()
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
            if vs.requestedForm?.getForm(decomposed:false).contains(",") == false
            {
                timerLabel.stopTimer()
                checkAnswer()
            }
            else
            {
                //1.5 x the time
                let halfTime = timerLabel.countDownTime / 2
                timerLabel.startTime += halfTime
                // FIX ME NOW kb?.mfButton?.setTitle(",", for: [])
            }
        }
    }
    
    func start()
    {
        label1.text = ""
        label2.text = ""
        textView.text = ""
        continueButton.setTitle("Continue", for: [])
        gameOverLabel.isHidden = true
        vs.reset()
        let _ = vs.getNext()
        askForForm(erasePreviousForm: true)
        if (isGame)
        {
            scoreLabel.text = String(0)
            life1.isHidden = false;
            life2.isHidden = false;
            life3.isHidden = false;
        }
    }
    
    func askForForm(erasePreviousForm:Bool)
    {
        blockPinch = true
        isExpanded = false
        if erasePreviousForm
        {
            label1.type(newText: (vs.givenForm?.getForm(decomposed: false))!, duration: 0.3)
        }
        label1.isHidden = false
        
        let p:UInt8 = vs.requestedForm!.person
        let n:UInt8 = vs.requestedForm!.number
        let t:UInt8 = vs.requestedForm!.tense
        let v:UInt8 = vs.requestedForm!.voice
        let m:UInt8 = vs.requestedForm!.mood
        
        stemLabel.setVerbForm(person: Int(p), number: Int(n), tense: Int(t), voice: Int(v), mood: Int(m), locked: true)
        //stemLabel.type(newAttributedText: attributedDescription(orig: (vs.givenForm?.getDescription())!, new: (vs.requestedForm?.getDescription())!), duration: 0.3)
        
        label2.text = ""
        textView.isEditable = true
        textView.isSelectable = true
        textView.textColor = UIColor.black
        mfPressed = false
        mfLabel.isHidden = true
        timerLabel.reset()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.textView.becomeFirstResponder()
            self.timerLabel.startTimer()
        }
    }
    
    func showAnswer()
    {
        label2.isHidden = false
        label2.type(newText: (vs.requestedForm?.getForm(decomposed: false))!, duration: 0.3)
    }
    
    @objc func handleTimeOut()
    {
        NSLog("time out")
        
        checkAnswer()
    }
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer)
    {
        //NSLog("Scale: %.2f | Velocity: %.2f",sender.scale, sender.velocity);
        let thresholdVelocity:CGFloat  = 0 //4.0;
        
        if blockPinch == true
        {
            return
        }
        if sender.scale > 1 && sender.velocity > thresholdVelocity
        {
            expand()
        }
        else if sender.velocity < -thresholdVelocity
        {
            unexpand()
        }
    }
    
    func expand()
    {
        if isExpanded == true
        {
            return
        }
        NSLog("expand")
        let a = NSMutableAttributedString.init(string: (vs.givenForm?.getForm(decomposed: true))!)
        label1.attributedText = a
        label1.att = a
        label1.textColor = UIColor.black
        if label2.attributedText?.string == ""
        {
            textView.text = vs.requestedForm?.getForm(decomposed: true)
            positionCheckX()
        }
        else
        {
            let b = NSMutableAttributedString.init(string: (vs.requestedForm?.getForm(decomposed: true))!)
            label2.attributedText = b
            label2.att = b
            label2.textColor = UIColor.black
        }
        isExpanded = true
    }
    
    func unexpand()
    {
        if isExpanded == false
        {
            return
        }
        NSLog("unexpand")
        
        let a = NSMutableAttributedString.init(string: (vs.givenForm?.getForm(decomposed: false))!)
        label1.attributedText = a
        label1.att = a
        label1.textColor = UIColor.black
        
        if label2.attributedText?.string == ""
        {
            textView.text = vs.requestedForm?.getForm(decomposed: false)
            positionCheckX()
        }
        else
        {
            let b = NSMutableAttributedString.init(string: (vs.requestedForm?.getForm(decomposed: false))!)
            label2.attributedText = b
            label2.att = b
            label2.textColor = UIColor.black
        }
        isExpanded = false
    }
}

