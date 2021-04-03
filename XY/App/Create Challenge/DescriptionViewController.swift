//
//  DescriptionViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

class DescriptionViewController: UIViewController {
    
    private let challengeNameTextField = TextField(placeholder: "Give a title to your challenge...", style: .card, maxChars: 15)
    private let challengeDescriptionTextField = TextField(placeholder: "Describe what you have to do in your challenge...", style: .card, maxChars: 50)
    
    private let challengePreviewImage = UIImageView()
    private let downloadVideoButton = Button(image: UIImage(systemName: "arrow.down.to.line"), title: "Save video", style: .card, titlePosition: .belowImage, imageSizeIncrease: 30)

    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "XYBackground")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.configureBackgroundStyle(.visible)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(challengeNameTextField)
        view.addSubview(challengeDescriptionTextField)
        view.addSubview(challengePreviewImage)
        view.addSubview(downloadVideoButton)
        
        navigationItem.title = "Description"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        challengeNameTextField.frame = CGRect(
            x: 11,
            y: 15,
            width: 250,
            height: 81
        )
        
        challengeDescriptionTextField.frame = CGRect(
            x: 11,
            y: challengeNameTextField.bottom + 9,
            width: 250,
            height: 198
        )
        
        challengePreviewImage.frame = CGRect(
            x: challengeNameTextField.right + 10,
            y: 15,
            width: 94,
            height: 94
        )
        
        let downloadVideoButtonSize = CGSize(width: 105, height: 74)
        downloadVideoButton.frame = CGRect(
            x: (view.width - downloadVideoButtonSize.width)/2,
            y: view.height - downloadVideoButtonSize.height - 30,
            width: downloadVideoButtonSize.width,
            height: downloadVideoButtonSize.height
        )
    }
    
    public func setPreviewImage(_ image: UIImage) {
        challengePreviewImage.image = image
    }
}
