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
    @IBOutlet weak var interestsView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width:1, height:1)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 1.0
        
        travelsButton.layer.cornerRadius = 8
        travelsButton.layer.shadowColor = UIColor.black.cgColor
        travelsButton.layer.shadowOffset = CGSize(width:1, height:1)
        travelsButton.layer.shadowRadius = 2
        travelsButton.layer.shadowOpacity = 1.0
        
        blogsButton.layer.cornerRadius = 8
        blogsButton.layer.shadowColor = UIColor.black.cgColor
        blogsButton.layer.shadowOffset = CGSize(width:1, height:1)
        blogsButton.layer.shadowRadius = 2
        blogsButton.layer.shadowOpacity = 1.0
        
        
        spaceButton.layer.cornerRadius = 8
        spaceButton.layer.shadowColor = UIColor.black.cgColor
        spaceButton.layer.shadowOffset = CGSize(width:1, height:1)
        spaceButton.layer.shadowRadius = 2
        spaceButton.layer.shadowOpacity = 1.0
        
        
        foodButton.layer.cornerRadius = 8
        foodButton.layer.shadowColor = UIColor.black.cgColor
        foodButton.layer.shadowOffset = CGSize(width:1, height:1)
        foodButton.layer.shadowRadius = 2
        foodButton.layer.shadowOpacity = 1.0
        
        
        artButton.layer.cornerRadius = 8
        artButton.layer.shadowColor = UIColor.black.cgColor
        artButton.layer.shadowOffset = CGSize(width:1, height:1)
        artButton.layer.shadowRadius = 2
        artButton.layer.shadowOpacity = 1.0
        
        technologyButton.layer.cornerRadius = 8
        technologyButton.layer.shadowColor = UIColor.black.cgColor
        technologyButton.layer.shadowOffset = CGSize(width:1, height:1)
        technologyButton.layer.shadowRadius = 2
        technologyButton.layer.shadowOpacity = 1.0
        
        enterteinmentButton.layer.cornerRadius = 8
        enterteinmentButton.layer.shadowColor = UIColor.black.cgColor
        enterteinmentButton.layer.shadowOffset = CGSize(width:1, height:1)
        enterteinmentButton.layer.shadowRadius = 2
        enterteinmentButton.layer.shadowOpacity = 1.0
        
        musicButton.layer.cornerRadius = 8
        musicButton.layer.shadowColor = UIColor.black.cgColor
        musicButton.layer.shadowOffset = CGSize(width:1, height:1)
        musicButton.layer.shadowRadius = 2
        musicButton.layer.shadowOpacity = 1.0
        
        
        interestsView.layer.cornerRadius = 15
        interestsView.layer.shadowColor = UIColor.black.cgColor
        interestsView.layer.shadowOffset = CGSize(width:1, height:1)
        interestsView.layer.shadowRadius = 2
    }
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressBarScore: UILabel!
    
    
    var interests = [String]()
    var progressScore = 0
    
    
    @IBAction  func interestButtonPressed(_ sender: UIButton) {
            guard let interestButtonLabel = sender.titleLabel?.text! else { fatalError()
            }
            
            if !interests.contains(interestButtonLabel) {
                // add 1 to the progresses
                progressScore += 1
                progressBar.progress = Float(progressScore) / 5
                progressBarScore.text = "\(progressScore)"
                
                //Add interest to interest array
                interests.append(interestButtonLabel)
                
                print("Here are all your interests: ", interests)
            }
        }
        
    }





