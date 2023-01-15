//
//  SaveTimer.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/14/23.
//

import Foundation

protocol SaveTimerDelegate {
    func save()
}

class SaveTimer {
    var delegate: SaveTimerDelegate?
    let seconds: Double
    var timer: Timer?
    
    init(seconds: Double = 3) {
        self.seconds = seconds
    }
    
    func start() {
        stop()
        timer = Timer.scheduledTimer(
            timeInterval: seconds,
            target: self,
            selector: #selector(save),
            userInfo: nil,
            repeats: false
        )
    }
    
    func stop() {
        if timer != nil {
            timer!.invalidate()
        }
    }
    
    @objc func save() {
        stop()
        delegate?.save()
    }
}

