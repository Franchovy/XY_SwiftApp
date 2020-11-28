//
//  InterestsViewController.swift
//  XY_APP
//
//  Created by Simone on 28/11/2020.
//

import UIKit

    
class InterestsViewController: UIViewController {
            
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressBarScore: UILabel!
  
    var interests = [String]()
    var progressScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func interestButtonPressed(_ sender: UIButton) {
        guard let interestButtonLabel = sender.titleLabel?.text! else { fatalError() }
        
        if !interests.contains(interestButtonLabel) {
            
            // Add 1 to progress score
            progressScore += 1
            progressBar.progress = Float(progressScore) / 5
            progressBarScore.text = "\(progressScore)"
            
            //Add interest to interest array
            interests.append(interestButtonLabel)
            
            print("Here are all your interests: ", interests)
        }
    }
    

}
