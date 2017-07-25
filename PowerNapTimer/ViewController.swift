//
//  ViewController.swift
//  PowerNapTimer
//
//  Created by James Pacheco on 4/12/16.
//  Modified by Nicole Bearup on 7/25/17.
//  Copyright © 2016 James Pacheco. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: Properties
    
    let myTimer = MyTimer()
    let userNotificatinIdentifier = "timerNotification"
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTimer.delegate = self
        setView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTimer()
    }
    
    // MARK: Methods
    
    func setView() {
        updateTimerLabel()
        // If timer is running, start button title should say "Cancel". If timer is not running, title should say "Start nap"
        if myTimer.isOn {
            startButton.setTitle("Cancel", for: UIControlState())
        } else {
            startButton.setTitle("Start nap", for: UIControlState())
        }
    }
    
    func updateTimerLabel() {
        timerLabel.text = myTimer.timeAsString()
    }
    
    // Call this to reset
    func resetTimer() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            ///
            let timerLocalNotifications = requests.filter { $0.identifier == self.userNotificatinIdentifier }
            ///
            guard let timerNotificationRequest = timerLocalNotifications.last,
                let trigger = timerNotificationRequest.trigger as? UNCalendarNotificationTrigger,
                let fireDate = trigger.nextTriggerDate() else { return }
            ///
            self.myTimer.stopTimer()
            self.myTimer.startTimer(fireDate.timeIntervalSinceNow)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func startButtonTapped(_ sender: Any) {
        if myTimer.isOn {
            myTimer.stopTimer()
        } else {
            myTimer.startTimer(5)
            scheduleLocalNotifcation()
        }
        setView()
    }
    
    // MARK: UIAlertController method
    
    func setupAlertController() {
        
        /// Snooze textField property
        var snoozeTextField: UITextField?
        
        /// Initialize instance of UIAlertController
        let alert = UIAlertController(title: "Wake up!", message: "Get up you lazy bum!", preferredStyle: .alert)
        
        /// Add textField
        alert.addTextField { (textField) in
            textField.placeholder = "Sleep a few more minutes..."
            textField.keyboardType = .numberPad
            snoozeTextField = textField
        }
        
        /// Initialize UIAlertAction
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in
            self.setView()
        }
        
        let snoozeAction = UIAlertAction(title: "Snooze", style: .default) { (_) in
            guard let timeText = snoozeTextField?.text,
                let time = TimeInterval(timeText) else { return }
            self.myTimer.startTimer(time)
            /// Schedule Notification
            self.scheduleLocalNotifcation()
            self.setView()
        }
        
        /// Add the action
        alert.addAction(dismissAction)
        alert.addAction(snoozeAction)
        
        /// Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: UserNotifications
    
    func scheduleLocalNotifcation() {
        
        /// Initialize UNMutableNotificationContent()
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Wake up!"
        notificationContent.body = "Time to get up."
        
        /// Trigger when you want to display content
        guard let timeRemaining = myTimer.timeRemaining else { return }
        let fireDate = Date(timeInterval: timeRemaining, since: Date())
        
        /// Convert date
        let dateComponents = Calendar.current.dateComponents([.minute, .second], from: fireDate)
        let dateTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        /// Creeate UNNotificationRequest to send to NotificationCenter
        let request = UNNotificationRequest(identifier: userNotificatinIdentifier, content: notificationContent, trigger: dateTrigger)
        
        /// Add request to NotificationCenter
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Unable to add notification request. \(error.localizedDescription)")
            }
        }
    }
    
    func cancelLocalNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [userNotificatinIdentifier])
    }
}

// MARK: Timer delegate

extension ViewController: TimerDelegate {
    
    func timerSecondTick() {
        updateTimerLabel()
    }
    
    func timerCompleted() {
        setView()
        // Present the notification and alert controller
        setupAlertController()
    }
    
    func timerStopped() {
        setView()
        // Cancel notification
        cancelLocalNotification()
    }
}









