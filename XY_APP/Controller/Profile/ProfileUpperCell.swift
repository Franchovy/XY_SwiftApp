//
//  ProfileUpperCell.swift
//  XY_APP
//
//  Created by Simone on 02/01/2021.
//

import UIKit
import Firebase

class ProfileUpperCell: UITableViewCell {
    
    //MARK: - Delegate functions
    
    var logout: (() -> Void)?
    var chatSegue: (() -> Void)?

    
    //MARK: - IBOutlets
    
    @IBOutlet weak var ProfImg: UIImageView!
    @IBOutlet weak var ProfNick: UILabel!
    @IBOutlet weak var profFollowers: UILabel!
    @IBOutlet weak var profFollowing: UILabel!
    @IBOutlet weak var profLev: UILabel!
    @IBOutlet weak var postCapt: UILabel!
    @IBOutlet weak var profViewContainer: UIView!
    
    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var followingView: UIView!
    
    @IBOutlet weak var levelView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ProfImg.layer.cornerRadius = 10
        profViewContainer.layer.cornerRadius = 15.0
        followersView.layer.cornerRadius = 10.0
        followingView.layer.cornerRadius = 10.0
        
        levelView.layer.cornerRadius = 10.0
        
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        logout?()
    }
    
    
    @IBAction func chatButtonPressed(_ sender: Any) {
        chatSegue?()
    }
   
 
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

extension ProfileUpperCell : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    
}




