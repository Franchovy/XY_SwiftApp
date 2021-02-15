//
//  ProfileHeaderChatViewController.swift
//  XY
//
//  Created by Maxime Franchot on 11/02/2021.
//

import UIKit

class ProfileHeaderChatViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
        tableView.allowsMultipleSelection = true
        tableView.separatorStyle = .none
        tableView.register(ChatBubbleTableViewCell.self, forCellReuseIdentifier: ChatBubbleTableViewCell.identifier)
        return tableView
    }()
    
    private let typeView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let emojiButtonGradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(0x3F63F7).cgColor,
            UIColor(0x58A5FF).cgColor
        ]
        gradientLayer.type = .axial
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1.0)
        gradientLayer.locations = [0, 1]
        return gradientLayer
    }()
    
    private let cameraImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    private let emojiButton: UIButton = {
        let button = UIButton()
        button.setBackgroundColor(color: UIColor(0x3F63F7), forState: .normal)
        button.setImage(UIImage(systemName: "face.smiling")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setBackgroundColor(color: UIColor(0x3F63F7), forState: .normal)
        button.setImage(UIImage(systemName: "paperplane.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    
    private let typeTextField: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(named: "tintColor")!.cgColor
        textView.layer.cornerRadius = 15
        textView.font = UIFont(name: "HelveticaNeue", size: 14)
        textView.textContainerInset = UIEdgeInsets(top: 9, left: 4, bottom: 7, right: 27)
        return textView
    }()
    
    var viewModels:[MessageViewModel] = [
        MessageViewModel(
            text: "Yo man, ready for China?",
            timestamp: Date(),
            nickname: "CEO",
            senderIsSelf: false
        ),
        MessageViewModel(
            text: "Hey dude, give me two minutes, I got problems with the new viewcontroller again.",
            timestamp: Date(),
            nickname: "CTO",
            senderIsSelf: true
        ),
        MessageViewModel(
            text: "Wow, you really still developing the app yourself? God damn.",
            timestamp: Date(),
            nickname: "CEO",
            senderIsSelf: false
        )
    ]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(tableView)
        
        cameraButton.layer.insertSublayer(emojiButtonGradient, at: 0)
        cameraButton.layer.insertSublayer(cameraImageView.layer, above: nil)
        typeView.addSubview(cameraButton)
        typeView.addSubview(emojiButton)
        typeView.addSubview(typeTextField)
        typeView.addSubview(sendButton)
        
        view.addSubview(typeView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhere))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
        
        let typeViewHeight:CGFloat = 40
        typeView.frame = CGRect(
            x: 0,
            y: view.height - typeViewHeight,
            width: view.width,
            height: typeViewHeight
        )
        
        let buttonSize:CGFloat = 38
        cameraButton.frame = CGRect(
            x: 15,
            y: (typeView.height-buttonSize)/2,
            width: buttonSize,
            height: buttonSize
        )
        emojiButtonGradient.frame = cameraButton.bounds
        cameraImageView.frame = cameraButton.bounds.insetBy(dx: 5, dy: 5)
        
        emojiButton.frame = CGRect(
            x: cameraButton.right + 5,
            y: (typeView.height-buttonSize)/2,
            width: buttonSize,
            height: buttonSize
        )
        
        typeTextField.frame = CGRect(
            x: emojiButton.right + 5,
            y: (typeView.height-buttonSize)/2,
            width: view.width - (emojiButton.right + 5) - 15,
            height: buttonSize
        )
        
        let sendButtonSize: CGFloat = 22.5
        sendButton.frame = CGRect(
            x: typeTextField.right - sendButtonSize - 10.5,
            y: 8,
            width: sendButtonSize,
            height: sendButtonSize
        )
    }
    
    func configure(with conversationViewModel: ConversationViewModel, chatViewModels: [MessageViewModel]) {
        viewModels = chatViewModels
        tableView.reloadData()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        tableView.frame.origin.y = keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {

        
        tableView.frame.origin.y = 0
    }
    
    @objc func tappedAnywhere() {
        typeTextField.resignFirstResponder()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                typeTextField.layer.borderColor = UIColor(named: "tintColor")?.cgColor
            }
        }
    }
}

extension ProfileHeaderChatViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleTableViewCell.identifier) as? ChatBubbleTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    
}
