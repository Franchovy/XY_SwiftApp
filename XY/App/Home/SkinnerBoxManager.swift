//
//  SkinnerBoxManager.swift
//  XY
//
//  Created by Maxime Franchot on 04/05/2021.
//

import UIKit

protocol SkinnerBoxManagerDelegate : class {
    func taskPressed(taskNumber: Int)
    func onTaskComplete(taskNumber: Int, outOf: Int)
}

final class SkinnerBoxManager {
    static var shared = SkinnerBoxManager()
    private init() { }
    
    weak var delegate: SkinnerBoxManagerDelegate?
    
    var completedTaskDescriptions = [
        ("Profile Image", UIImage(systemName: "eyes")!, "Your profile is now public!"),
        ("Find Friends", UIImage(systemName: "eyes")!, "You've added a friend, you're ready to start challenges!")
    ]
    
    var uncompletedTaskDescriptions = [
        ("Profile Image", UIImage(systemName: "eyes")!, "Add a profile image for friends to see you"),
        ("Find Friends", UIImage(systemName: "eyes")!, "Find at least one friend to start a challenge")
    ]
    
    let userDefaultsKey = "skinnerBoxTaskNumber"
    
    var taskNumber = 0
    
    func load() {
        if let taskNumber = UserDefaults.standard.object(forKey: userDefaultsKey) as? Int {
            self.taskNumber = taskNumber
        }
    }
    
    func completedTask(number: Int) {
        if number == taskNumber {
            delegate?.onTaskComplete(taskNumber: taskNumber + 1, outOf: uncompletedTaskDescriptions.count)
            taskNumber += 1
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
