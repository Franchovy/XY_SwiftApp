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
    
    var ownerId: String = Auth.auth().currentUser!.uid
 
    var modalEscapable: Bool = false
    
    var panGestureInAction: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        UpProfTableView.dataSource = self
        
        UpProfTableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: ProfileCell.identifier)
        
        UpProfTableView.register(UINib(nibName: "ProfileFlowTableViewCell", bundle: nil), forCellReuseIdentifier: "profileBottomReusable")

        var escapeModalGesture = UIPanGestureRecognizer(target: self, action: #selector(escapeModal(panGestureRecognizer:)))
        escapeModalGesture.isEnabled = modalEscapable
        escapeModalGesture.delegate = self
        UpProfTableView.addGestureRecognizer(escapeModalGesture)
        UpProfTableView.isUserInteractionEnabled = true
        
        //escapeModalGesture.isEnabled = false
    }
    
    var escapeModalGestureOngoing = false
    @objc func escapeModal(panGestureRecognizer: UIPanGestureRecognizer) {
        let touchPoint = panGestureRecognizer.location(in: view?.window)
        var initialTouchPoint = CGPoint.zero
        
        if escapeModalGestureOngoing {
            switch panGestureRecognizer.state {
            case .began:
                initialTouchPoint = touchPoint
            case .changed:
                if touchPoint.y > initialTouchPoint.y {
                    view.frame.origin.y = touchPoint.y - initialTouchPoint.y
                }
            case .ended, .cancelled:
                panGestureInAction = false
                
                if touchPoint.y - initialTouchPoint.y > 200 {
                    dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.view.frame = CGRect(x: 0,
                                                 y: 0,
                                                 width: self.view.frame.size.width,
                                                 height: self.view.frame.size.height)
                    })
                }
            case .failed, .possible:
                break
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
        return 1 + profile2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.identifier, for: indexPath) as! ProfileCell
            
            cell.viewModel = ProfileViewModel(userId: ownerId)
            // Add "Tap anywhere" escape function from keyboard focus
//            let tappedAnywhereGestureRecognizer = UITapGestureRecognizer(target: cell, action: #selector(cell.tappedAnywhere(tapGestureRecognizer:)))
//            view.addGestureRecognizer(tappedAnywhereGestureRecognizer)
//            
//            //cell.imagePickerDelegate = self
//            cell.logout = logoutSegue
//            cell.chatSegue = segueToChat
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileBottomReusable", for: indexPath) as! ProfileFlowTableViewCell
            cell.flowLabel.text = profile2[indexPath.row - 1].FlowLabel
            return cell
        }
    }
    
}
    

extension ProfileVC : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            
            print("Gesture location: \(panGestureRecognizer.location(in: UpProfTableView.visibleCells[0]).y)")
            print("Gesture velocity: \(panGestureRecognizer.velocity(in: UpProfTableView.visibleCells[0]).y)")
            
            if
                panGestureRecognizer.location(in: UpProfTableView.visibleCells[0]).y < 400 &&
                    panGestureRecognizer.velocity(in: UpProfTableView.visibleCells[0]).y > 150 {
                escapeModalGestureOngoing = true
            } else {
                escapeModalGestureOngoing = false
            }
        }
        
        return escapeModalGestureOngoing
    }
    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
//            return false
//            return panGestureRecognizer.velocity(in: UpProfTableView).y > 500 || panGestureRecognizer.location(in: UpProfTableView).y < 250
//        } else {
//            return false
//        }
//    }
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
