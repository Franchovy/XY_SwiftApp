//
//  HomeViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit


class NewsFeedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var ringBar: CircleView!
    
    @IBOutlet weak var tableView: FlowTableView!
    
    @IBOutlet weak var writePostTextField: UITextField!
    
    var imagePicker = UIImagePickerController()
    var imageIds: [String]?
    
    var createPostImages: [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.parentViewController = self
        
        imagePicker.delegate = self
        //imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        tableView.addImageCompletion = photoButtonPressed
        tableView.submitPostCompletion = submitButtonPressed
        
        // Get posts from backend
        getPosts()
        
        // Remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
        
        // Set timer to reload user xp periodically
        let feedbackTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: self.timerHandler)
        feedbackTimer.fire()
    }
    
    func getPosts() {
        // load posts from backend
        // load posts to flowtableview
        tableView.getPosts()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Upload image
            ImageCache.insertAndUpload(image: newImage, closure: { result in
                switch result {
                case .success(let imageId):
                    if var imageIds = self.imageIds {
                        imageIds.append(imageId)
                    } else {
                        self.imageIds = [imageId]
                    }
                case .failure(let error):
                    print("Error uploading image")
            }
            })
            DispatchQueue.main.async {
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
   
    func photoButtonPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func submitButtonPressed(_ createPostText: String) {
        print("Submitting post with content: \(createPostText) and imageIds: \(imageIds)")
        
        PostsAPI.shared.submitCreatePostRequest(content: createPostText, imageIds: imageIds, closure: { result in
            switch result {
            case .success(let postData):
                print("Just created post: \(postData)")
                // Add new post to flow
                self.tableView.posts.insert(postData, at: 1)
                print("TODO: Check image in cache, load on flow on submit")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                }
            case .failure(let error):
                print("Error submitting post: \(error)")
            }
        })
    }
    
    func timerHandler(timer: Timer) {
        reloadUserXPProgressBar()
    }
    
    // Timer reloading user xp data
    func reloadUserXPProgressBar() {
        Profile.shared.getProfile(username: Session.shared.username, closure: { result in
            switch result {
            case .success(let profileData):
                DispatchQueue.main.async {
                    self.ringBar.progress = CGFloat(profileData.xpLevel!.xp / Levels.shared.getNextLevel(xpLevel: profileData.xpLevel!))
                }
                print("User has level: \(profileData.xpLevel?.level) xp: \(profileData.xpLevel?.xp)")
            case .failure(let error):
                print("Error fetching user profile data! \(error)")
            }
        })
    }
}
