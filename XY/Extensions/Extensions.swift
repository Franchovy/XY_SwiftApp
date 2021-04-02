//
//  Extensions.swift
//  XY
//
//  Created by Maxime Franchot on 18/01/2021.
//

import Foundation
import UIKit

extension UIView {
    var width : CGFloat {
        return frame.size.width
    }
    var height : CGFloat {
        return frame.size.height
    }
    var left : CGFloat {
        return frame.origin.x
    }
    var right : CGFloat {
        return left + width
    }
    var top : CGFloat {
        return frame.origin.y
    }
    var bottom : CGFloat {
        return top + height
    }
}

extension DateFormatter {
    static let defaultFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.locale = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension String {
    static func date(with date: Date) -> String {
        return DateFormatter.defaultFormatter.string(from: date)
    }
}

extension Date {
    func shortTimestamp() -> String {
        let ti = NSInteger(-self.timeIntervalSinceNow)

        if ti < 60 {
            return "\(ti)s"
        } else if (ti / 60) < 60 {
            return "\((ti / 60))m"
        } else if (ti / 3600) < 26 {
            return "\((ti / 3600))h"
        } else {
            return "\((ti / 3600 / 24))d"
        }
    }
}

extension UIView {
    func applyshadowWithCorner(containerView : UIView, cornerRadious : CGFloat, shadowOffset: CGSize, shadowRadius: CGFloat){
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = shadowOffset
        containerView.layer.shadowRadius = shadowRadius
        containerView.layer.cornerRadius = cornerRadious
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadious).cgPath
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
    }
}

extension UIView {
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

extension UILabel {
    func setFrameWithAutomaticHeight(x: CGFloat, y: CGFloat, width: CGFloat) {
        guard let text = text else {
            frame = .zero
            return
        }
        
        let boundingRect = text.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        
        frame = CGRect(
            x: x,
            y: y,
            width: width,
            height: boundingRect.height
        )
    }
}

extension UIViewController {
    func displayTempLabel(centerPoint: CGPoint, labelText: String, labelColor: UIColor) {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 18)
        label.textColor = labelColor
        label.text = labelText
        label.alpha = 0.0
        
        view.addSubview(label)
        label.sizeToFit()
        label.center = centerPoint.applying(CGAffineTransform(translationX: 0, y: 300))
        
        UIView.animate(withDuration: 0.3) {
            label.alpha = 0.8
            label.center = centerPoint
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.3, delay: 0.7) {
                    label.alpha = 0.0
                    label.center = centerPoint.applying(CGAffineTransform(translationX: 0, y: -300))
                } completion: { (done) in
                    if done {
                        label.removeFromSuperview()
                    }
                }
            }
        }
    }
}

extension UIView{
    func rotate(numRotations: Int) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2 * Double(numRotations))
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func stopRotating() {
        self.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
    func scaleAnimate(_ scaleFactor: Float, duration: Double) {
        let scaleX : CABasicAnimation = CABasicAnimation(keyPath: "transform.scale.x")
        let scaleY : CABasicAnimation = CABasicAnimation(keyPath: "transform.scale.y")
        scaleX.toValue = NSNumber(value: scaleFactor)
        scaleY.toValue = NSNumber(value: scaleFactor)
        scaleX.duration = duration
        scaleY.duration = duration
        scaleX.isCumulative = true
        scaleY.isCumulative = true
        scaleX.isRemovedOnCompletion = false
        scaleY.isRemovedOnCompletion = false
        scaleX.fillMode = .forwards
        scaleY.fillMode = .forwards
        self.layer.add(scaleX, forKey: "scaleXAnimation")
        self.layer.add(scaleY, forKey: "scaleYAnimation")
    }
    
    func stopScaleAnimate(_ fromScaleFactor: Float, duration: Double) {
        let scaleX : CABasicAnimation = CABasicAnimation(keyPath: "transform.scale.x")
        let scaleY : CABasicAnimation = CABasicAnimation(keyPath: "transform.scale.y")
        scaleX.fromValue = NSNumber(value: fromScaleFactor)
        scaleY.fromValue = NSNumber(value: fromScaleFactor)
        scaleX.toValue = 1
        scaleY.toValue = 1
        scaleX.duration = duration
        scaleY.duration = duration
        scaleX.isCumulative = true
        scaleY.isCumulative = true
        scaleX.isRemovedOnCompletion = true
        scaleY.isRemovedOnCompletion = true
        scaleX.fillMode = .both
        scaleY.fillMode = .both
        self.layer.add(scaleX, forKey: "endScaleXAnimation")
        self.layer.add(scaleY, forKey: "endScaleYAnimation")
        
        self.layer.removeAnimation(forKey: "scaleYAnimation")
        self.layer.removeAnimation(forKey: "scaleXAnimation")
    }
    
    func springScaleAnimate(from startScaleFactor: Float, to scaleFactor: Float) {
        let scaleX = CASpringAnimation(keyPath: "transform.scale.x")
        let scaleY = CASpringAnimation(keyPath: "transform.scale.y")
    
        scaleX.fromValue = NSNumber(value: startScaleFactor)
        scaleY.fromValue = NSNumber(value: startScaleFactor)
        
        scaleX.toValue = NSNumber(value: scaleFactor)
        scaleY.toValue = NSNumber(value: scaleFactor)
        
        scaleX.initialVelocity = -50.0
        scaleY.initialVelocity = -50.0
        
        scaleY.damping = 1.0
        scaleX.damping = 1.0
        
        scaleX.mass = 0.05
        scaleY.mass = 0.05
        scaleX.stiffness = 50
        scaleY.stiffness = 50
        
        scaleX.duration = scaleX.settlingDuration
        scaleY.duration = scaleY.settlingDuration
        
        scaleX.isCumulative = true
        scaleY.isCumulative = true
        
        scaleX.fillMode = .forwards
        scaleY.fillMode = .forwards
        scaleX.isRemovedOnCompletion = false
        scaleY.isRemovedOnCompletion = false
        
        self.layer.add(scaleX, forKey: "springScaleXAnimation")
        self.layer.add(scaleY, forKey: "springScaleYAnimation")
    }
    
    func stopSpringScaleAnimate() {
        self.layer.removeAnimation(forKey: "springScaleYAnimation")
        self.layer.removeAnimation(forKey: "springScaleXAnimation")
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(_ rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

extension UITabBarController {
    func setTabBarVisible(visible:Bool, duration: TimeInterval, animated:Bool) {
        if (tabBarIsVisible() == visible) { return }
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)

        // animation
        UIViewPropertyAnimator(duration: duration, curve: .linear) {
            self.tabBar.frame.offsetBy(dx:0, dy:offsetY)
            self.view.frame = CGRect(x:0,y:0,width: self.view.frame.width, height: self.view.frame.height + offsetY)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }.startAnimation()
    }

    func tabBarIsVisible() ->Bool {
        return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
    }
}

extension UIImage {
    func generateThumbnail() -> UIImage? {
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 100] as CFDictionary

        guard let imageData = self.pngData(),
              let imageSource = CGImageSourceCreateWithData(imageData as NSData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options)
        else {
            return nil
        }

        return UIImage(cgImage: image)
    }
}

extension CALayer {
    func moveTo(point: CGPoint, animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = value(forKey: "position")
            animation.toValue = NSValue(cgPoint: point)
            animation.fillMode = .forwards
            self.position = point
            add(animation, forKey: "position")
        } else {
            self.position = point
        }
    }

    func resize(to size: CGSize, animated: Bool) {
        let oldBounds = bounds
        var newBounds = oldBounds
        newBounds.size = size

        if animated {
            let animation = CABasicAnimation(keyPath: "bounds")
            animation.fromValue = NSValue(cgRect: oldBounds)
            animation.toValue = NSValue(cgRect: newBounds)
            animation.fillMode = .forwards
            self.bounds = newBounds
            add(animation, forKey: "bounds")
        } else {
            self.bounds = newBounds
        }
    }

    func resizeAndMove(frame: CGRect, animated: Bool, duration: TimeInterval = 0) {
        if animated {
            let positionAnimation = CABasicAnimation(keyPath: "position")
            positionAnimation.fromValue = value(forKey: "position")
            positionAnimation.toValue = NSValue(cgPoint: CGPoint(x: frame.midX, y: frame.midY))

            let oldBounds = bounds
            var newBounds = oldBounds
            newBounds.size = frame.size

            let boundsAnimation = CABasicAnimation(keyPath: "bounds")
            boundsAnimation.fromValue = NSValue(cgRect: oldBounds)
            boundsAnimation.toValue = NSValue(cgRect: newBounds)

            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [positionAnimation, boundsAnimation]
            groupAnimation.fillMode = .forwards
            groupAnimation.duration = duration
            groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.frame = frame
            add(groupAnimation, forKey: "frame")

        } else {
            self.frame = frame
        }
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}

extension UIColor {
    static func blend(color1: UIColor, intensity1: CGFloat = 0.5, color2: UIColor, intensity2: CGFloat = 0.5) -> UIColor {
        let total = intensity1 + intensity2
        let l1 = intensity1/total
        let l2 = intensity2/total
        guard l1 > 0 else { return color2}
        guard l2 > 0 else { return color1}
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return UIColor(red: l1*r1 + l2*r2, green: l1*g1 + l2*g2, blue: l1*b1 + l2*b2, alpha: l1*a1 + l2*a2)
    }
}

extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
