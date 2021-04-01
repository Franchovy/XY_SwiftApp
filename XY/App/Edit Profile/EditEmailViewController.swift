//
//  EditEmailViewController.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class EditEmailViewController: UIViewController {
    
    private let separatorLine = SeparatorLine()
    private let currentEmailField = Label(style: .info, fontSize: 15)
    private let separatorLine2 = SeparatorLine()
    private let newEmailTextField = TextField(placeholder: "New email")

    init() {
        super.init(nibName: nil, bundle: nil)
        
        currentEmailField.text = AuthManager.shared.email
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "XYBackground")
        
        view.addSubview(separatorLine)
        view.addSubview(currentEmailField)
        view.addSubview(separatorLine2)
        view.addSubview(newEmailTextField)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonPressed))
        navigationItem.title = "Change Email"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        separatorLine.setPosition(y: 0, width: view.width)
        
        currentEmailField.sizeToFit()
        currentEmailField.frame = CGRect(
            x: 0,
            y: 1,
            width: view.width,
            height: 46.95
        )
        
        separatorLine2.setPosition(y: currentEmailField.bottom, width: view.width)
        
        newEmailTextField.frame = CGRect(
            x: 0,
            y: separatorLine2.bottom + 1,
            width: view.width,
            height: 46.95
        )
    }
    
    @objc private func saveButtonPressed() {
        displayTempLabel(
            centerPoint: view.center.applying(CGAffineTransform(translationX: 0, y: -150)),
            labelText: "New Email saved.",
            labelColor: UIColor(named: "XYTint")!
        )
    }
}
