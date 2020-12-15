//
//  CreatePostViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 07/12/2020.
//

import UIKit

class CreatePostViewController : UIViewController {
    
    @IBOutlet weak var writePostTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        if let text = self.writePostTextField.text {
            let newPost = PostModel(id: "", username: "user", content: text, imageRefs: [])
            newPost.submitPost(images: [UIImage(named: "J2NTP9Er4Ad3kRsms7XRoD")!], completion: {result in
                switch result {
                case .success:
                    // Segue to News feed and refresh
                    // Segue to login
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "NewsFeedViewController") as! NewsFeedViewController
                    
                    // Show next viewcontroller
                    self.show(vc, sender: self)
                case .failure:
                    print("Error submitting post")
                }
            })
        }
    }
}
