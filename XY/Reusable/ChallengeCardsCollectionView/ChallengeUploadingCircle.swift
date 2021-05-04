//
//  ChallengeUploadingCircle.swift
//  XY
//
//  Created by Maxime Franchot on 03/05/2021.
//

import UIKit

class ChallengeUploadingCircle: UIView {

    let sendingLabel = Label("Sending...", style: .title, fontSize: 18, adaptToLightMode: false)
    let sendingImageView = UIImageView(image: UIImage(named: "sending_icon"))
    let loadingCircle = XPCircleView()
    
    let loadingCircleSize: CGFloat = 50
    let sendingImageViewSize: CGFloat = 30
    
    init() {
        super.init(frame: .zero)
        
        sendingImageView.contentMode = .scaleAspectFill
        loadingCircle.setThickness(.medium)
        loadingCircle.setColor(.XYBlue)
        
        addSubview(sendingLabel)
        addSubview(loadingCircle)
        addSubview(sendingImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        loadingCircle.frame = CGRect(
            x: (width - loadingCircleSize)/2,
            y: 0,
            width: loadingCircleSize,
            height: loadingCircleSize
        )
        
        sendingImageView.frame = CGRect(
            x: (width - sendingImageViewSize)/2,
            y: loadingCircle.center.y - sendingImageViewSize/2,
            width: sendingImageViewSize,
            height: sendingImageViewSize
        )
        
        sendingLabel.sizeToFit()
        sendingLabel.frame = CGRect(
            x: (width - sendingLabel.width)/2,
            y: loadingCircle.bottom + 5,
            width: sendingLabel.width,
            height: sendingLabel.height
        )
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        sendingLabel.sizeToFit()
        
        frame.size.width = sendingLabel.width
        frame.size.height = 50 + 5 + sendingLabel.height
    }
    
    func onProgress(progress: Double) {
        loadingCircle.animateSetProgress(CGFloat(progress))
    }
    
    func finishUploading() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseIn) {
                    self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                } completion: { (done) in
                    if done {
                        self.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func finishError() {
        
    }
}
