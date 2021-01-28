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
    
    @IBOutlet weak var tableView: UITableView!
    
    var topCell: ProfileCell!
    var bottomCell: ProfileFlowTableViewCell!
    
    var topViewModel: ProfileViewModel? {
        didSet {
            topViewModel?.delegate = self
        }
    }
    // bottomCell ViewModel:
    
    var ownerId: String = Auth.auth().currentUser!.uid
    var profileId: String?
 
    var modalEscapable: Bool = false
    var panGestureInAction: Bool = false
    var escapeModalGestureOngoing = false
    
    // MARK: - Init
    

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        modalPresentationStyle = .overFullScreen
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: ProfileCell.identifier)
        tableView.register(UINib(nibName: "ProfileFlowTableViewCell", bundle: nil), forCellReuseIdentifier: "profileBottomReusable")

        var escapeModalGesture = UIPanGestureRecognizer(target: self, action: #selector(escapeModal(panGestureRecognizer:)))
        escapeModalGesture.isEnabled = modalEscapable
        escapeModalGesture.delegate = self
        tableView.addGestureRecognizer(escapeModalGesture)
        
//        var scrollGesture = UIPanGestureRecognizer(target: self, action: #selector(scrolling(panGestureRecognizer:)))
//        tableView.addGestureRecognizer(scrollGesture)
        
        fetchProfileData()
        
        tableView.isUserInteractionEnabled = true
        
    }
    
    private func fetchProfileData() {
        if let profileId = profileId {
            topViewModel = ProfileViewModel(profileId: profileId, userId: ownerId)
        } else {
            // Fetch profileId for userId
            FirebaseDownload.getProfileId(userId: ownerId) { [weak self] (profileId, error) in
                guard let strongSelf = self, let profileId = profileId, error == nil else {
                    print(error ?? "An Error occurred while fetching profile ID for user: \(self?.ownerId)")
                    return
                }
                
                let topViewModel = ProfileViewModel(profileId: profileId, userId: strongSelf.ownerId)
                strongSelf.topViewModel = topViewModel
                // If viewmodel for cell is not set, then set it.
                guard let profileCell = strongSelf.topCell else {
                    return
                }
                profileCell.configure(for: topViewModel)
            }
        }
        
    }
    
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
        
    }
    
    func chatSegue() {
        
        if ownerId == Auth.auth().currentUser!.uid {
            performSegue(withIdentifier: "segueToChat", sender: self)
        } else {
            // Open message VC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatVC = storyboard.instantiateViewController(withIdentifier: ChatVC.identifier) as! ChatVC
            
            
            FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.conversations)
                .whereField(FirebaseKeys.ConversationKeys.members, arrayContains: Auth.auth().currentUser!.uid)
                .getDocuments() { snapshotDocuments, error in
                if let error = error { print("Error fetching conversations!") }
                    
                if let snapshotDocuments = snapshotDocuments {
                    if !snapshotDocuments.isEmpty {
                        // Check this user's conversations for one with the other user
                        for document in snapshotDocuments.documents {
                            let conversationMembers = document.get(FirebaseKeys.ConversationKeys.members) as! [String]
                            if conversationMembers.contains(self.ownerId) {
                                // Set conversation id
                                chatVC.conversationId = document.documentID
                            }
                        }
                    }
                    
                    if chatVC.conversationId == nil {
                        chatVC.otherMemberId = self.ownerId
                    }
                    
                    self.present(chatVC, animated: true, completion: {})
                }
            }
        }
    }
    
    func settingsSegue() {
        performSegue(withIdentifier: "segueToSettings", sender: self)
    }
}

extension ProfileVC : UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Fade background of cover picture on scroll down
                
        let scrollPositionProportionToWidth = max(0, 1 - (tableView.contentOffset.y / (topCell.coverImage.frame.height - topCell.profileCard.frame.height)))
        topCell.coverImage.layer.opacity = Float(scrollPositionProportionToWidth)
        topCell.backgroundColor = .black
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let scrollViewYPosition = scrollView.contentOffset.y
        let profileCardTop =
            topCell.coverImage.height
            - topCell.profileCard.height
            - topCell.profileImage.height / 2
            - 10
        let scrollYAxisVelocity = scrollView.panGestureRecognizer.velocity(in: view).y
        
        if scrollViewYPosition < profileCardTop {
            if scrollYAxisVelocity > 0 {
                // Page to top
                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            } else {
                // Page to profileCard
                scrollView.setContentOffset(CGPoint(x: 0, y: profileCardTop), animated: true)
            }
        }
    }
}

extension ProfileVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.identifier, for: indexPath) as! ProfileCell
            
            // Add "Tap anywhere" escape function from keyboard focus
            let tappedAnywhereGestureRecognizer = UITapGestureRecognizer(target: cell, action: #selector(cell.tappedAnywhere(tapGestureRecognizer:)))
            view.addGestureRecognizer(tappedAnywhereGestureRecognizer)
            
            cell.imagePickerDelegate = self
            
            cell.onKeyboardDismiss = { self.dismissKeyboard() }
            cell.isOwnProfile = ownerId == Auth.auth().currentUser!.uid
            cell.onChatButtonPressed = chatSegue
            cell.onSettingsButtonPressed = settingsSegue
            
            if let topViewModel = topViewModel {
                cell.configure(for: topViewModel)
            }
            
            topCell = cell
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileBottomReusable", for: indexPath) as! ProfileFlowTableViewCell
            cell.ownerId = ownerId
            return cell
        }
    }
}
    

extension ProfileVC : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            
            // Detect escape gesture
            if panGestureRecognizer.location(in: tableView.visibleCells[0]).y < 400 &&
                    panGestureRecognizer.velocity(in: tableView.visibleCells[0]).y > 150 {
                escapeModalGestureOngoing = true
            } else {
                escapeModalGestureOngoing = false
            }
            
            return escapeModalGestureOngoing
        } else {
            return true
        }
    }
}

extension ProfileVC : XYImagePickerDelegate {
    func presentImagePicker(imagePicker: UIImagePickerController) {
        present(imagePicker, animated: true, completion: nil)
    }

    func onImageUploadSucceed() {
        
    }
}

extension ProfileVC: ProfileViewModelDelegate {
    func onXYNameFetched(_ xyname: String) {
        
    }
    
    func onProfileDataFetched(_ viewModel: ProfileViewModel) {
        
    }
    
    func onProfileDataFetched(_ profileData: ProfileModel) {
        guard let topViewModel = topViewModel, topCell != nil else {
            return
        }
        topCell.configure(for: topViewModel)
    }
    
    func onProfileImageFetched(_ image: UIImage) {
        guard topCell != nil else {
            return
        }
        topCell.profileImage.image = image
    }
    
    func onCoverImageFetched(_ image: UIImage) {
        guard topCell != nil else {
            return
        }
        topCell.coverImage.image = image
    }
}
