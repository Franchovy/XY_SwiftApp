//
//  Gradient.swift
//  XY
//
//  Created by Maxime Franchot on 02/03/2021.
//

import UIKit

class Gradient {
    static func createGradientLayer(gradientColours: [UIColor], angle: CGFloat = 0) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = gradientColours.map({ $0.cgColor })
        
        let startPoint = pointForAngle(angle)
        let endPoint = startPoint.applying(CGAffineTransform(scaleX: -1, y: -1)).applying(CGAffineTransform(translationX: 1, y: 1))
        
        
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        
        let count = gradientColours.count
        layer.locations = gradientColours.enumerated().map({
            return Float($0.offset) / Float(count - 1) as NSNumber
        })
        
        return layer
    }
    
    private static func pointForAngle(_ angle: CGFloat) -> CGPoint {
        // convert degrees to radians
        let radians = angle * .pi / 180.0
        var x = cos(radians)
        var y = sin(radians)
        // (x,y) is in terms unit circle. Extrapolate to unit square to get full vector length
        if (abs(x) > abs(y)) {
            // extrapolate x to unit length
            x = x > 0 ? 1 : -1
            y = x * tan(radians)
        } else {
            // extrapolate y to unit length
            y = y > 0 ? 1 : -1
            x = y / tan(radians)
        }
        return CGPoint(x: x, y: y)
    }
}
