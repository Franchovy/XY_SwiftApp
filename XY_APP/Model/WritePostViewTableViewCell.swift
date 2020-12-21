//
//  WritePostViewTableViewCell.swift
//  XY_APP
//
//  Created by Maxime Franchot on 19/12/2020.
//

import UIKit

class WritePostViewTableViewCell: UITableViewCell {

    // Properties
    
    @IBOutlet weak var textField: UITextField!
    
    // Completion handlers to set when using this
    
    var onImageButtonPressed: (() -> Void)?
    var onSubmitButtonPressed: ((_ postContent:String) -> Void)?
    
    // IBActions
    
    @IBAction func addImageButtonPressed(_ sender: Any) {
        onImageButtonPressed?()
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if let text = textField.text {
            onSubmitButtonPressed?(text)
        }
    }
    
}
