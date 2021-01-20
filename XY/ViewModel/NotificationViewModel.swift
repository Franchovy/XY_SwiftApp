//
//  Notification.swift
//  XY_APP
//
//  Created by Simone on 01/01/2021.
//

import Foundation
import UIKit

struct NotificationViewModel {
    let displayImage: UIImage?
    let previewImage: UIImage?
    let title: String
    let text: String
    let onSelect: (() -> Void)?
}
