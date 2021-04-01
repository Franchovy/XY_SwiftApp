//
//  EditPasswordViewController.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class EditPasswordViewController: UIViewController {
    
    private let separatorLine = SeparatorLine()
    private let currentPasswordField = TextField(placeholder: "previous password")
    private let separatorLine2 = SeparatorLine()
    private let newPasswordTextField = TextField(placeholder: "new password")
    private let separatorLine3 = SeparatorLine()
    private let repeatPasswordTextField = TextField(placeholder: "repeat new password")
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "XYBackground")
        
        currentPasswordField.isSecureTextEntry = true
        newPasswordTextField.isSecureTextEntry = true
        repeatPasswordTextField.isSecureTextEntry = true
        
        view.addSubview(separatorLine)
        view.addSubview(currentPasswordField)
        view.addSubview(separatorLine2)
        view.addSubview(newPasswordTextField)
        view.addSubview(separatorLine3)
        view.addSubview(repeatPasswordTextField)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonPressed))
        navigationItem.title = "Change Password"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        separatorLine.setPosition(y: 0, width: view.width)
        
        currentPasswordField.frame = CGRect(
            x: 0,
            y: 1,
            width: view.width,
            height: 46.95
        )
        
        separatorLine2.setPosition(y: currentPasswordField.bottom, width: view.width)
        
        newPasswordTextField.frame = CGRect(
            x: 0,
            y: separatorLine2.bottom + 1,
            width: view.width,
            height: 46.95
        )
        
        separatorLine3.setPosition(y: newPasswordTextField.bottom, width: view.width)
        
        repeatPasswordTextField.frame = CGRect(
            x: 0,
            y: separatorLine3.bottom + 1,
            width: view.width,
            height: 46.95
        )
    }
    
    @objc private func saveButtonPressed() {
        displayTempLabel(
            centerPoint: view.center.applying(CGAffineTransform(translationX: 0, y: -150)),
            labelText: "Password changed.",
            labelColor: UIColor(named: "XYTint")!
        )
    }
}
