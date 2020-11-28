//
//  InterestsViewController.swift
//  XY_APP
//
//  Created by Simone on 28/11/2020.
//

import UIKit

    
class InterestsViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var travelsButton: UIButton!
    @IBOutlet weak var blogsButton: UIButton!
    @IBOutlet weak var spaceButton: UIButton!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var artButton: UIButton!
    @IBOutlet weak var technologyButton: UIButton!
    @IBOutlet weak var enterteinmentButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width:5, height:5)
            button.layer.shadowRadius = 5
            button.layer.shadowOpacity = 1.0
        
        travelsButton.layer.cornerRadius = 10
        travelsButton.layer.shadowColor = UIColor.black.cgColor
        travelsButton.layer.shadowOffset = CGSize(width:5, height:5)
        travelsButton.layer.shadowRadius = 5
        travelsButton.layer.shadowOpacity = 1.0
        
        blogsButton.layer.cornerRadius = 10
        blogsButton.layer.shadowColor = UIColor.black.cgColor
        blogsButton.layer.shadowOffset = CGSize(width:5, height:5)
        blogsButton.layer.shadowRadius = 5
        blogsButton.layer.shadowOpacity = 1.0
        
        
        spaceButton.layer.cornerRadius = 10
        spaceButton.layer.shadowColor = UIColor.black.cgColor
        spaceButton.layer.shadowOffset = CGSize(width:5, height:5)
        spaceButton.layer.shadowRadius = 5
        spaceButton.layer.shadowOpacity = 1.0
        
        
        foodButton.layer.cornerRadius = 10
        foodButton.layer.shadowColor = UIColor.black.cgColor
        foodButton.layer.shadowOffset = CGSize(width:5, height:5)
        foodButton.layer.shadowRadius = 5
        foodButton.layer.shadowOpacity = 1.0
        
        
        artButton.layer.cornerRadius = 10
        artButton.layer.shadowColor = UIColor.black.cgColor
        artButton.layer.shadowOffset = CGSize(width:5, height:5)
        artButton.layer.shadowRadius = 5
        artButton.layer.shadowOpacity = 1.0
        
        technologyButton.layer.cornerRadius = 10
        technologyButton.layer.shadowColor = UIColor.black.cgColor
        technologyButton.layer.shadowOffset = CGSize(width:5, height:5)
        technologyButton.layer.shadowRadius = 5
        technologyButton.layer.shadowOpacity = 1.0
        
        enterteinmentButton.layer.cornerRadius = 10
        enterteinmentButton.layer.shadowColor = UIColor.black.cgColor
        enterteinmentButton.layer.shadowOffset = CGSize(width:5, height:5)
        enterteinmentButton.layer.shadowRadius = 5
        enterteinmentButton.layer.shadowOpacity = 1.0
        
        musicButton.layer.cornerRadius = 10
        musicButton.layer.shadowColor = UIColor.black.cgColor
        musicButton.layer.shadowOffset = CGSize(width:5, height:5)
        musicButton.layer.shadowRadius = 5
        musicButton.layer.shadowOpacity = 1.0
        
        
        
        
        
    }
            
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    @IBOutlet weak var progressBarScore: UILabel!
    
    
   
    
    
    var interests = [String]()
    var progressScore = 0
    
  
    
    
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
