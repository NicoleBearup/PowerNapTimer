//
//  Timer.swift
//  PowerNapTimer
//
//  Created by James Pacheco on 4/12/16.
//  Modified by Nicole Bearup on 7/25/17.
//  Copyright © 2016 James Pacheco. All rights reserved.
//

import UIKit

protocol TimerDelegate: class {
    func timerSecondTick()
    func timerCompleted()
    func timerStopped()
}

class MyTimer: NSObject {
    
    // MARK: Properties
    
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
    
    // MARK: fileprivate Method
    
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
    
    // MARK: Methods
    
    func timeAsString() -> String {
        let timeRemaining = Int(self.timeRemaining ?? 20*60)
        let minutesLeft = timeRemaining / 60
        let secondsLeft = timeRemaining - (minutesLeft*60)
        return String(format: "%02d : %02d", arguments: [minutesLeft, secondsLeft])
    }
    
    func startTimer(_ time: TimeInterval) {
        if !isOn {
            timeRemaining = time
            DispatchQueue.main.async {
                self.secondTick()
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
                    self.secondTick()
                })
            }
            
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
            /// Destroy timer
            timer?.invalidate()
            /// Call custom delegate method timerStopped()
            delegate?.timerStopped()
        }
    }
}
