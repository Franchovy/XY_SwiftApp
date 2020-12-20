//
//  WritePostViewTableViewCell.swift
//  XY_APP
//
//  Created by Maxime Franchot on 19/12/2020.
//

import UIKit

class WritePostViewTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func submitButtonPressed(_ sender: Any) {
        
    }
    
}
