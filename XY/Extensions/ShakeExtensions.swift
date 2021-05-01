//
//  Shake.swift
//  XY_APP
//
//  Created by Maxime Franchot on 14/01/2021.
//

import UIKit


public extension UITextField {

    func shake(count : Float = 4,
               for duration : TimeInterval = 0.3,
               withTranslation translation : Float = 5)
    {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}

public extension UIImageView {

    func shake(count : Float = 4,
               for duration : TimeInterval = 0.3,
               withTranslation translation : Float = 5)
    {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}


public extension UIButton {

    func shake(count : Float = 4,
               for duration : TimeInterval = 0.3,
               withTranslation translation : Float = 5)
    {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}

public extension UIView {
    func hoverAnimate() {
        let yScale = CAKeyframeAnimation(keyPath: "transform.scale.y")
        let xScale = CAKeyframeAnimation(keyPath: "transform.scale.x")
        let yTrans = CAKeyframeAnimation(keyPath: "transform.translation.y")
        let xTrans = CAKeyframeAnimation(keyPath: "transform.translation.x")
        yScale.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        xScale.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        yTrans.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        xTrans.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        yScale.repeatCount = .infinity
        xScale.repeatCount = .infinity
        yTrans.repeatCount = .infinity
        xTrans.repeatCount = .infinity
        yScale.duration = 2
        xScale.duration = 2
        yTrans.duration = 1.5
        xTrans.duration = 2
        yScale.autoreverses = true
        xScale.autoreverses = true
        yTrans.autoreverses = true
        xTrans.autoreverses = true
        yScale.values = [0.95, 1]
        xScale.values = [0.95, 1]
        yTrans.values = [-15, 0]
        xTrans.values = [-10, 10]
        layer.add(yScale, forKey: "hoverScaleY")
        layer.add(xScale, forKey: "hoverScaleX")
        layer.add(yTrans, forKey: "hoverTranslY")
        layer.add(xTrans, forKey: "hoverTranslX")
    }
}
