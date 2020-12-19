//
//  HomeViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit


class NewsFeedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // don't forget to hook this up from the storyboard
    @IBOutlet weak var centralContainer: UIView!
    @IBOutlet weak var tableView: FlowTableView!
    
    @IBOutlet weak var writePostTextField: UITextField!
    
    var imagePicker = UIImagePickerController()
    
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
        
        
        // Get posts from backend
        getPosts()
                        
        // Remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
    }

    func getPosts() {
        // load posts from backend
        // load posts to flowtableview
        tableView.getPosts()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Set profile image in app
            if createPostImages != nil {
                createPostImages?.append(newImage)
            } else {
                createPostImages = [newImage]
            }
        }
    }
   
    @IBAction func photoButtonPressed(_ sender: Any) {
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
    
    @IBAction func writeButtonPressed(_ sender: Any) {
        // Add submitPost cell to tableview
        
        tableView.reloadData()
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if let text = self.writePostTextField.text {
            let newPost = Post(id: "", username: "user", timestamp: Date(), content: text, imageRefs: [])
            newPost.submitPost(images: createPostImages, completion: {result in
                switch result {
                case .success:
                    // Refresh feed
                    self.getPosts()
                    self.tableView.reloadData()
                    break
                case .failure:
                    print("Error submitting post")
                }
            })
        }
    }
}


