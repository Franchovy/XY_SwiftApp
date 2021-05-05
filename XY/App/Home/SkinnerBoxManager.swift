//
//  SkinnerBoxManager.swift
//  XY
//
//  Created by Maxime Franchot on 04/05/2021.
//

import UIKit

protocol SkinnerBoxManagerDelegate : class {
    func taskPressed(taskNumber: Int)
    func onTaskComplete(taskNumber: Int)
}

final class SkinnerBoxManager {
    static var shared = SkinnerBoxManager()
    private init() { }
    
    weak var delegate: SkinnerBoxManagerDelegate?
    
    var completedTaskDescriptions = [
        ("Profile Image", UIImage(named: "sb_task1_check")!, "Your profile is now public!"),
        ("Find Friends", UIImage(named: "sb_task2_check")!, "You're ready to play!")
    ]
    
    var uncompletedTaskDescriptions = [
        ("Profile Image", UIImage(named: "sb_task1_unchecked")!, "Add a profile image for friends to see you"),
        ("Find Friends", UIImage(named: "sb_task2_unchecked")!, "Find at least one friend to start a challenge")
    ]
    
    let userDefaultsKey = "skinnerBoxTaskNumber"
    
    var taskNumber = 0
    
    var numTasks: Int {
        get {
            uncompletedTaskDescriptions.count
        }
    }
    
    func load() {
        if let taskNumber = UserDefaults.standard.object(forKey: userDefaultsKey) as? Int {
            self.taskNumber = taskNumber
        }
    }
    
    func completedTask(number: Int) {
        if number == taskNumber {
            delegate?.onTaskComplete(taskNumber: taskNumber + 1)
            taskNumber += 1
            UserDefaults.standard.setValue(taskNumber, forKey: userDefaultsKey)
        }
    }
    
    func pressedTask(taskNumber: Int) {
        delegate?.taskPressed(taskNumber: taskNumber)
    }
    
    func getTask(number: Int) -> (String, UIImage, String) {
        if taskNumber > number {
            return completedTaskDescriptions[number]
        } else {
            return uncompletedTaskDescriptions[number]
        }
    }
}
