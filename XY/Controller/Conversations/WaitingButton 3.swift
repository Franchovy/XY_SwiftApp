//
//  WaitingButton.swift
//  XY_APP
//
//  Created by Simone on 20/12/2020.
//

import UIKit

class WaitingButton: UITableViewCell {

    @IBOutlet weak var waitingButtonIbo: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func waitingButtonPressed(_ sender: UIButton) {
    }
}
