//
//  CardViewController.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 12/7/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
import Koloda
import CoreData

class CardViewController: UIViewController {
@IBOutlet weak var kolodaView: KolodaView!
    var cardIndex = 0
    var hqidForCardIndex = [Int]()
    let cc = CardController.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray
        // Do any additional setup after loading the view.
        kolodaView.dataSource = self
        kolodaView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CardViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        //koloda.reloadData()
        koloda.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection)
    {
        /*
        if direction == .left
        {
            print("left, \(hqidForCardIndex[index])")
        }
        else if direction == .right
        {
            print("right, \(hqidForCardIndex[index])")
        }
        else
        {
            print("other direction, \(hqidForCardIndex[index])")
        }
        */
        let c:Bool = (direction == .right) ? true : false
        
        cc.markRightOrWrong(cardId:hqidForCardIndex[index], correct:c)
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool
    {
        return true
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat?
    {
        //return 0.1 //extremely sensitive, 0.9 very insensitive
        return 0.6
    }
}

extension CardViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return 200000000000
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let f = self.view.frame
        let l = CardView.init(frame: f)
        var fs:String = ""
        var bs:String = ""
        var hqid = 0
        cc.nextCard(hqid: &hqid, frontStr: &fs, backString: &bs)
        
        print("card index: \(index), \(hqid)")
        hqidForCardIndex.append(hqid)
        l.label1!.text = fs
        l.label2!.text = bs
        return l;
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil//Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
    }
    
    
}
