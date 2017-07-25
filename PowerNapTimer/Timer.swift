//
//  Timer.swift
//  PowerNapTimer
//
//  Created by James Pacheco on 4/12/16.
//  Copyright © 2016 James Pacheco. All rights reserved.
//

import UIKit

protocol TimerDelegate: class {
    func timerSecondTick()
    func timerCompleted()
    func timerStopped()
}

class MyTimer: NSObject {
    
    var timeRemaining: TimeInterval?
    var timer: Timer?
    
    weak var delegate: TimerDelegate?
    
    var isOn: Bool {
        if timeRemaining != nil {
            return true
        } else {
            return false
        }
    }
    
    func timeAsString() -> String {
        let timeRemaining = Int(self.timeRemaining ?? 20*60)
        let minutesLeft = timeRemaining / 60
        let secondsLeft = timeRemaining - (minutesLeft*60)
        return String(format: "%02d : %02d", arguments: [minutesLeft, secondsLeft])
    }

    fileprivate func secondTick() {
        guard let timeRemaining = timeRemaining else {return}
        if timeRemaining > 0 {
            self.timeRemaining = timeRemaining - 1
            /// Fire custom delegate timerSecondTick method
            delegate?.timerSecondTick()
            print(timeRemaining)
        } else {
            // Destroy timer when no time remaining
            timer?.invalidate()
            self.timeRemaining = nil
            /// Call custom delegate method timerCompleted()
            delegate?.timerCompleted()
        }
    }
    
    func startTimer(_ time: TimeInterval) {
        if !isOn {
            timeRemaining = time
            
            /*  scheduledTimer = Timer class func
                interval = number of seconds before the block is fired
                repeat = whether to repeat, Bool
                block = a block to be executed when the timer fires, takes single NSTimer parameter
             */
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
                self.secondTick()
            })
        }
    }
    
    func stopTimer() {
        if isOn {
            timeRemaining = nil
            /// Call custom delegate metho timerStopped()
            delegate?.timerStopped()
        }
    }
}
