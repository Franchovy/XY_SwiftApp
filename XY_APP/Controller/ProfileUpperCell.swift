//
//  ProfileUpperCell.swift
//  XY_APP
//
//  Created by Simone on 02/01/2021.
//

import UIKit
import Firebase

class ProfileUpperCell: UITableViewCell {
    
    
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func signoutButtonPressed(_ sender: UIButton) {
       
        let firebaseAuth = Firebase.Auth.auth()
    do {
      try firebaseAuth.signOut()
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }
      
      
    }
    
}

extension ProfileUpperCell : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }


}





