//
//  CardViewController.swift
//  HopliteChallenge
//
//  Created by Jeremy March on 12/7/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import UIKit
import Koloda

class CardViewController: UIViewController {
@IBOutlet weak var kolodaView: KolodaView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        kolodaView.dataSource = self
        kolodaView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        //let att = [ NSAttributedStringKey.font: UIFont(name: "NewAthenaUnicode", size: 22)! ]
        //self.navigationController?.navigationBar.titleTextAttributes = att
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CardViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
    }
}

extension CardViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return 20
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let f = self.view.frame
        let l = CardView.init(frame: f)
        l.label1!.text = "test"
        l.label2!.text = "back"
        return l;//UIImageView(image: images[index])
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil//Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
    }
}
