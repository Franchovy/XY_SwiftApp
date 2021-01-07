//
//  ProfileVC.swift
//  XY_APP
//
//  Created by Simone on 02/01/2021.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseAuth

class ProfileVC : UIViewController {

    @IBOutlet weak var UpProfTableView: UITableView!

    lazy var profile: [UpperProfile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        UpProfTableView.dataSource = self
        UpProfTableView.delegate = self
        
        UpProfTableView.register(UINib(nibName: "ProfileUpperCell", bundle: nil), forCellReuseIdentifier: "ProfileUpperReusable")
        
        if let ownId = Auth.auth().currentUser?.uid {
            fetchProfile(profileId: ownId)
        }
    }
    
    func fetchProfile(profileId: String) {
        FirebaseDownload.getProfile(userId: profileId) { profileData, error in
            if let error = error {
                print("Error fetching profile: \(error)")
            }
            if let profileData = profileData {
                self.profile.append(profileData)
            }
        }
        
        
    }
    
    func logoutSegue() {
        // Log out
        if let vc1 = self.tabBarController {
            if let vc2 = vc1.navigationController {
                vc2.popToRootViewController(animated: true)
            }
        }
    }

    
    func segueToChat() {
        //Segue to chat viewcontroller
        print("Segue to chat!")
        performSegue(withIdentifier: "segueToChat", sender: self)
    }

}

extension ProfileVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Load profileUpper Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileUpperReusable", for: indexPath) as! ProfileUpperCell
           
            // case: ProfileUpper
            if profile.count >= indexPath.row {
                cell.ProfNick.text = profile[indexPath.row].xyname
                cell.profFollowers.text = String(describing: profile[indexPath.row].followers)
                cell.profFollowing.text = String(describing: profile[indexPath.row].following)
                cell.profLev.text = String(describing: profile[indexPath.row].level)
                cell.postCapt.text = profile[indexPath.row].caption
                
                // get profile image async
                let storage = Storage.storage()
                storage.reference(withPath: profile[indexPath.row].imageId).getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error fetching profile image: \(error)")
                    }
                    if let data = data, let image = UIImage(data: data) {
                        cell.ProfImg.image = image
                    }
                }
            }
            
            cell.logout = logoutSegue
            cell.chatSegue = segueToChat
            
            return cell
        }
        
        fatalError()
    }
    
    
}
extension ProfileVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)

    }
    
}
