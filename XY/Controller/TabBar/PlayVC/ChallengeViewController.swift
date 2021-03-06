//
//  ChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 06/03/2021.
//

import UIKit

class ChallengeViewController: UIViewController {
    
    var challengeNameLabel: GradientLabel
    
    var challengeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 21)
        label.textColor = UIColor(named: "XYWhite")
        label.numberOfLines = 0
        return label
    }()
    
        
    init(model: ChallengeModel) {
        
        let modelChallengeText: String!
        switch 0...5 {
        case 0:
            modelChallengeText = "Wooahh dude!!!"
        case 1:
            modelChallengeText = "Bro. That's mad"
        case 2:
            modelChallengeText = "COVID ISNT REAL"
        case 3:
            modelChallengeText = "Man you are insane"
        case 4:
            modelChallengeText = "I love you omg"
        default:
            modelChallengeText = "I love it omg"
        }
        
        challengeNameLabel = GradientLabel(text: model.title, fontSize: 27, gradientColours: Global.xyGradient)
        challengeDescriptionLabel.text =
            modelChallengeText
        
        
        
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
