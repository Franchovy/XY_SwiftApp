//
//  EditProfileViewController.swift
//  XY
//
//  Created by Maxime Franchot on 19/03/2021.
//

import UIKit

class EditProfileViewController: UIViewController {

    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        return imageView
    }()
    
    private let nicknameTextField: TextFieldCard = {
        let textField = TextFieldCard()
        textField.text = "AAAAAa"
        textField.textColor = UIColor(named: "XYTint")
        textField.font = UIFont(name: "Raleway-Heavy", size: 25)
        textField.backgroundColor = UIColor(named: "XYCard")
        textField.textAlignment = .center
        return textField
    }()
    
    private let captionTextView: TextViewCard = {
        let textView = TextViewCard()
        textView.setPlaceholderText(text: "Write a caption for your profile")
        textView.setMaxChars(maxChars: 100)
        return textView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(named: "Black")
        
        view.addSubview(profileImage)
        view.addSubview(nicknameTextField)
        view.addSubview(captionTextView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let profileImageSize:CGFloat = 110
        profileImage.frame = CGRect(
            x: (view.width - profileImageSize)/2,
            y: 20,
            width: profileImageSize,
            height: profileImageSize
        )
        profileImage.layer.cornerRadius = profileImageSize/2
        
        nicknameTextField.sizeToFit()
        nicknameTextField.frame = CGRect(
            x: (view.width - nicknameTextField.width)/2,
            y: profileImage.bottom + 15,
            width: nicknameTextField.width,
            height: nicknameTextField.height
        )
        
        captionTextView.frame = CGRect(
            x: 21,
            y: nicknameTextField.bottom + 23,
            width: view.width - 42,
            height: 74
        )
    }
    
    public func configure() {
        
    }
}
