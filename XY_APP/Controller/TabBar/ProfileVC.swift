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
    
    lazy var profile: [ProfileModel] = []
    
    lazy var profile2: [Profile2Model] = [
        Profile2Model(FlowLabel: "Flow")
    ]
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        UpProfTableView.dataSource = self
        
        UpProfTableView.register(UINib(nibName: "ProfileUpperCell", bundle: nil), forCellReuseIdentifier: "ProfileUpperReusable")
        
        UpProfTableView.register(UINib(nibName: "ProfileFlowTableViewCell", bundle: nil), forCellReuseIdentifier: "profileBottomReusable")
        
        
        
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
        return 1 + profile2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileUpperReusable", for: indexPath) as! ProfileUpperCell
            
            cell.viewModel = ProfileViewModel(userId: Auth.auth().currentUser!.uid)
            // Add "Tap anywhere" escape function from keyboard focus
            let tappedAnywhereGestureRecognizer = UITapGestureRecognizer(target: cell, action: #selector(cell.tappedAnywhere(tapGestureRecognizer:)))
            view.addGestureRecognizer(tappedAnywhereGestureRecognizer)
            
            //cell.imagePickerDelegate = self
            cell.logout = logoutSegue
            cell.chatSegue = segueToChat
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileBottomReusable", for: indexPath) as! ProfileFlowTableViewCell
            cell.flowLabel.text = profile2[indexPath.row - 1].FlowLabel
            return cell
        }
    }
    
}
    
    
    //extension ProfileVC : UITableViewDelegate {
        
        //func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         //   print(indexPath.row)
            
      //  }
        
  //  }
    
  //  extension ProfileVC : XYImagePickerDelegate {
   //     func presentImagePicker(imagePicker: UIImagePickerController) {
    //        present(imagePicker, animated: true, completion: nil)
    //    }
    //
    //    func onImageUploadSucceed() {
            
    //    }
   // }
//}
