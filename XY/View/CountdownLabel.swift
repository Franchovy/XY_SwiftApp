//
//  CountdownLabel.swift
//  XY
//
//  Created by Maxime Franchot on 28/03/2021.
//

import UIKit

class CountdownLabel: UILabel {

    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-ExtraBold", size: 72)
        label.textColor = UIColor(named: "XYYellow")
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        lineBreakMode = .byClipping
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var endTime: Date!
    var timer: Timer!
    var time: TimeInterval!
    public func setDeadline(countDownTo endTime: Date) {
        self.endTime = endTime
        
        timer = Timer.scheduledTimer(timeInterval: 0.04,
                                     target: self,
                                     selector: #selector(advanceTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    var ms: NSInteger!
    var ti: NSInteger!
    @objc private func advanceTimer(timer: Timer) {
        //Total time since timer started, in seconds
        time = endTime.timeIntervalSince(Date())
        
        ti = NSInteger(time)
        
        if ti == 0 {
            setTimerText(timeInteger: 0)
        } else {
            setTimerText(timeInteger: ti)
        }
    }

    var showSeconds: Bool = true
    var showHours: Bool = true
    var showMinutes: Bool = true
    var showDays: Bool = true
    
    private func setTimerText(timeInteger: NSInteger) {
        let seconds = timeInteger % 60
        let minutes = (timeInteger / 60) % 60
        let hours = (timeInteger / 3600) % 24
        let days = (timeInteger / 3600 / 24)
        
        text = ""
        if showDays {
            text?.append(String(format: "%02d", days))
        }
        if showDays && showHours {
            text?.append(spacer)
        }
        if showHours {
            text?.append(String(format: "%02d", hours))
        }
        if showHours && showMinutes {
            text?.append(spacer)
        }
        if showMinutes {
            text?.append(String(format: "%02d", minutes))
        }
        if showMinutes && showSeconds {
            text?.append(spacer)
        }
        if showSeconds {
            text?.append(String(format: "%02d", seconds))
        }
        
    }
    
    var spacer: String = ":"
    public func setSpacer(_ spacer: String) {
        self.spacer = spacer
    }
}
