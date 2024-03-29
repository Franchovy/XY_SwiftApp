//
//  EditNicknameTextField.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class EditNicknameTextField: UITextField, UITextFieldDelegate {

    private let backgroundLayer = CALayer()
    
    init() {
        super.init(frame: .zero)
        
        delegate = self
        
        layer.insertSublayer(backgroundLayer, at: 0)
        backgroundLayer.backgroundColor = UIColor(named: "XYCard")?.cgColor
        backgroundLayer.cornerRadius = 10
        
        layer.shadowRadius = 1
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        
        font = UIFont(name: "Raleway-Heavy", size: 25)
        textColor = UIColor(named: "XYTint")
        textAlignment = .center
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
    }
    
    let inset: CGFloat = 10

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset , dy: inset)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset , dy: inset)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        sizeToFit()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let text = text, text != "" {
            ProfileDataManager.shared.setNickname(as: text) { error in
                if let error = error {
                    print("Error saving nickname: \(error.localizedDescription)")
                    NavigationControlManager.mainViewController.displayTempLabel(centerPoint: NavigationControlManager.mainViewController.view.center, labelText: "Error saving nickname!", labelColor: .systemRed)
                } else {
                    NavigationControlManager.mainViewController.displayTempLabel(centerPoint: NavigationControlManager.mainViewController.view.center, labelText: "Saved.", labelColor: .XYWhite)
                }
            }
        } else {
            text = ProfileDataManager.shared.nickname
        }
    }
}
