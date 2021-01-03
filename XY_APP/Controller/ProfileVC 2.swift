//
//  ProfileVC.swift
//  XY_APP
//
//  Created by Simone on 02/01/2021.
//

import Foundation
import UIKit

class ProfileVC : UIViewController {

    @IBOutlet weak var UpProfTableView: UITableView!

    var Profile : [UpperProfile] = [
        
        UpperProfile(Nickname: "XYfounder", ProfileImage: UIImage(named: "Raggruppa 301-image2")!, Link: "xy.com", Followers: "1.4M", Following: "4", Level: "129", ProfileCaption: "Put a funny caption here :)")
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        UpProfTableView.dataSource = self
        UpProfTableView.delegate = self
        
        UpProfTableView.register(UINib(nibName: "ProfileUpperCell", bundle: nil), forCellReuseIdentifier: "ProfileUpperReusable")
        
    }
}

extension ProfileVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileUpperReusable", for: indexPath) as! ProfileUpperCell
       
        cell.ProfImg.image = Profile[indexPath.row].ProfileImage
        cell.ProfNick.text = Profile[indexPath.row].Nickname
        cell.profFollowers.text = Profile[indexPath.row].Followers
        cell.profFollowing.text = Profile[indexPath.row].Following
        cell.profLev.text = Profile[indexPath.row].Level
        
        
        return cell
    }
    
    
}
extension ProfileVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
}
