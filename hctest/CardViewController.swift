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
        //self.view.backgroundColor = .red //does nothing
        
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
        let isCorrect:Bool = (direction == .right) ? true : false
        cc.markRightOrWrong(cardId:hqidForCardIndex[index], correct:isCorrect)
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool
    {
        return false//this only starts working after the first two cards?
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat?
    {
        //return 0.1 //extremely sensitive, 0.9 very insensitive
        return 0.6
    }
}

extension CardViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return 200000000000 //make room for infinite cards
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let f = self.view.frame
        let l = CardView.init(frame: f)
        l.backgroundColor = .clear
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
