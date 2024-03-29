//
//  HCTimer.swift
//  hctest
//
//  Created by Jeremy March on 3/5/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation
import UIKit

class HCTimer: UILabel {
    var countDownTime:CFTimeInterval = 30
    var timerDisplayLink:CADisplayLink?
    var startTime:CFTimeInterval = 0
    var elapsedTimeForDB:CFTimeInterval = 0
    var countDown:Bool = false
    var isRunning:Bool = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func startTimer()
    {
        self.show()
        if countDown == true
        {
            self.text = String.init(format: "%.02f sec", countDownTime)
        }
        else
        {
            self.text = "0.00 sec"
        }
        self.textColor = GlobalTheme.primaryText
        
        stopTimer()
        startTime = CACurrentMediaTime()
        timerDisplayLink = CADisplayLink.init(target: self, selector: #selector(runTimer))
        timerDisplayLink?.preferredFramesPerSecond = 26
        timerDisplayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        isRunning = true
    }
    
    @objc func runTimer()
    {
        var elapsedTime:CFTimeInterval = CACurrentMediaTime() - startTime
        elapsedTimeForDB = elapsedTime
        elapsedTime = countDownTime - elapsedTimeForDB
        
        if countDown == true
        {
            if elapsedTime < 0
            {
                self.text = "0.00 sec";
                stopTimer()
                self.textColor = UIColor.red
                NotificationCenter.default.post(name: Notification.Name(rawValue: "HCTimeOut"), object: self)
            }
            else
            {
                self.text = String.init(format: "%.02f sec", elapsedTime)
            }
        }
        else
        {
            self.text = String.init(format: "%.02f sec", elapsedTimeForDB)
        }
    }
    
    func stopTimer()
    {
        //update the timer label once more so it's accurate
        //CFTimeInterval elapsedTime = CACurrentMediaTime() - self.startTime;
        //self.timeLabel.text = [NSString stringWithFormat:@"%.02f sec", elapsedTime];
        isRunning = false
        if timerDisplayLink != nil
        {
            timerDisplayLink?.invalidate()
        }
        
        //timerDisplayLink = nil;
    }
    
    func reset()
    {
        if countDown
        {
            self.text = String.init(format: "%.02f sec", countDownTime)
        }
        else
        {
            self.text = String.init(format: "%.02f sec", 0)
        }
    }
    
    func hide()
    {
        self.isHidden = true
    }
    func show()
    {
        self.isHidden = false
    }
}
