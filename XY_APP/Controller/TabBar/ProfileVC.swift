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
        
        // Load profileUpper Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileUpperReusable", for: indexPath) as! ProfileUpperCell
        
        cell.viewModel = ProfileViewModel(userId: Auth.auth().currentUser!.uid)
        
        cell.logout = logoutSegue
        cell.chatSegue = segueToChat
        
        return cell
    }
}

extension ProfileVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)

    }
    
}
