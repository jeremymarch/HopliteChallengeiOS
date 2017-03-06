//
//  ViewController.swift
//  hctest
//
//  Created by Jeremy March on 3/4/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //@IBOutlet var label:UILabel?
    @IBOutlet var button:UIButton?
    var label = UILabel()
    var label2 = UILabel()
    let textView = UITextView()
    let continueButton = UIButton()
    let headerView = UIView()
    
    var label1Top:NSLayoutConstraint?
    var label2Top:NSLayoutConstraint?
    var textViewTop:NSLayoutConstraint?
    
    let vs:VerbSequence = VerbSequence()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let m = VerbForm(person:0, number:0, tense:0, voice:0, mood:0, verb:4)
        //NSLog("here: \(m.getForm())")
        
        /*
        for constraint in (label.constraints) {
            if constraint.identifier == "labelHeight"
            {
                constraint.isActive = false;
            }
        }
        */
        let fontSize:CGFloat = 24.0
        let greekFont = UIFont(name: "NewAthenaUnicode", size: fontSize)
        
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false;
        headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.0, constant: 40.0).isActive = true
        //label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0, constant: -12.0).isActive = true
        headerView.backgroundColor = UIColor.yellow
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false;
        label.textAlignment = NSTextAlignment.center
        //label.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0).isActive = true
        
        label1Top = label.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0)
        label1Top?.isActive = true
        
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        label.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.22).isActive = true
        //label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0, constant: -12.0).isActive = true
        label.backgroundColor = UIColor.cyan
        label.font = greekFont

        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false;
        textView.textAlignment = NSTextAlignment.center
        //textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 0.0).isActive = true
        
        textViewTop = textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 0.0)
        textViewTop?.isActive = true
        
        
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        textView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true
        //label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0, constant: -12.0).isActive = true
        textView.backgroundColor = UIColor.green
        textView.font = greekFont
        
        view.addSubview(label2)
        label2.translatesAutoresizingMaskIntoConstraints = false;
        label2.textAlignment = NSTextAlignment.center
        
        label2Top = label2.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0.0)
        label2Top?.isActive = true
        
        label2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        label2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        label2.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.22).isActive = true
        //label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0, constant: -12.0).isActive = true
        label2.backgroundColor = UIColor.red
        label2.font = greekFont
        
        view.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false;
        continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true
        continueButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6.0).isActive = true
        continueButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6.0).isActive = true
        continueButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.0, constant:60.0).isActive = true
        //label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0, constant: -12.0).isActive = true
        continueButton.backgroundColor = UIColor.blue
        continueButton.setTitle("Continue", for: [])
        continueButton.titleLabel?.textColor = UIColor.white
        
        
        vs.getNext()
        label.text = vs.requestedForm?.getForm()
        
        continueButton.addTarget(self, action: #selector(press(button:)), for: .touchUpInside)
        
        //printVerbs()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func press(button: UIButton) {
        vs.getNext()
        label.text = vs.requestedForm?.getForm()
        
        label2Top?.isActive = false
        label2Top = label2.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0.0)
        label2Top?.isActive = true
        view.bringSubview(toFront: self.label2)
        
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
            
        }, completion: {
            (value: Bool) in
            
            self.textViewTop?.isActive = false
            self.textViewTop = self.textView.topAnchor.constraint(equalTo: self.label2.bottomAnchor, constant: 0.0)
            self.textViewTop?.isActive = true
            
            self.label1Top?.isActive = false
            self.label1Top = self.label.topAnchor.constraint(equalTo: self.textView.bottomAnchor, constant: 0.0)
            self.label1Top?.isActive = true
            
            var temp:UILabel?
            temp = self.label2
            self.label2 = self.label
            self.label = temp!

            var tempCon:NSLayoutConstraint?
            tempCon = self.label2Top
            self.label2Top = self.label1Top
            self.label1Top = tempCon!
            
        })
        
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
                                    label.text = s
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
    
    
}

