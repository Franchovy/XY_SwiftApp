//
//  FriendBubblesView.swift
//  XY
//
//  Created by Maxime Franchot on 07/04/2021.
//

import UIKit

class FriendBubblesView: UIView {

    var friendBubbles: [FriendBubble] = []
    var viewModels: [FriendBubbleViewModel] = []
    
    var numMoreLabel: Label?
    var fromLabel: Label?
    
    init() {
        super.init(frame: .zero)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var x:CGFloat = 0
        
        if let fromLabel = fromLabel {
            fromLabel.sizeToFit()
            fromLabel.frame = CGRect(
                x: 0,
                y: 0,
                width: fromLabel.width,
                height: fromLabel.height
            )
            
            x = fromLabel.width + 15
        }
        
        for friendBubble in friendBubbles {
            friendBubble.frame = CGRect(x: x, y: 0, width: 25, height: 25)
            
            x += 15
        }
        
        if let numMoreLabel = numMoreLabel {
            numMoreLabel.sizeToFit()
            numMoreLabel.frame = CGRect(
                x: x,
                y: 0,
                width: numMoreLabel.width,
                height: numMoreLabel.height
            )
        }
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        if friendBubbles.count > 0 {
            let bubblesWidth = friendBubbles.last!.right - friendBubbles.first!.left
            let additionalWidth =
                (numMoreLabel != nil ? numMoreLabel!.width + 5 : 0) +
                (fromLabel != nil ? fromLabel!.width + 5 : 0)
            frame.size.width = bubblesWidth + additionalWidth
                
            
            frame.size.height = 25
        }
    }
    
    public func isNotEmpty() -> Bool {
        return friendBubbles.count > 0
    }
    
    public func reset() {
        friendBubbles.forEach({$0.removeFromSuperview()})
        friendBubbles = []
        viewModels = []
        
        numMoreLabel?.removeFromSuperview()
        numMoreLabel = nil
        
        fromLabel?.removeFromSuperview()
        fromLabel = nil
    }
    
    public func configure(with viewModels: [FriendBubbleViewModel], numMore: Int = 0, displayReceived: Bool = false) {
        self.viewModels = viewModels
        
        friendBubbles = viewModels.map({ viewModel in
            let friendBubble = FriendBubble()
            friendBubble.setImage(viewModel.image)
            addSubview(friendBubble)
            return friendBubble
        })
        
        if numMore > 0 {
            numMoreLabel = Label("+ \(numMore) more", style: .info, adaptToLightMode: false)
            addSubview(numMoreLabel!)
        }
        if displayReceived {
            fromLabel = Label("From: ", style: .body, adaptToLightMode: false)
            addSubview(fromLabel!)
        }
    }
}
