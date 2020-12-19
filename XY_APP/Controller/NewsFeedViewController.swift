//
//  HomeViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit


class NewsFeedViewController: UIViewController {
    
    // don't forget to hook this up from the storyboard
    @IBOutlet weak var centralContainer: UIView!
    @IBOutlet weak var tableView: FlowTableView!
    
    @IBOutlet weak var writePostTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.parentViewController = self
        
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
   
    @IBAction func submitButtonPressed(_ sender: Any) {
        if let text = self.writePostTextField.text {
            let newPost = Post(id: "", username: "user", timestamp: Date(), content: text, imageRefs: [])
            newPost.submitPost(images: [UIImage(named:"charlizePost")!], completion: {result in
                switch result {
                case .success:
                    // Segue to News feed and refresh
                    // Show next viewcontroller
                    
                    self.navigationController?.popViewController(animated: true)
                case .failure:
                    print("Error submitting post")
                }
            })
        }
    }
    }


