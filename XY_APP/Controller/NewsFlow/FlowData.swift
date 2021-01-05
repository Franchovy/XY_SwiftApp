//
//  FlowData.swift
//  XY_APP
//
//  Created by Maxime Franchot on 04/01/2021.
//

import UIKit

enum FlowDataType {
    case post
    case momentsCollection
}

protocol FlowDataCell {
    var type: FlowDataType { get set }
}

