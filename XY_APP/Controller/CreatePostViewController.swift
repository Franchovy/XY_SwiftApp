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
            let newPost = PostModel(username: "user", content: text)
            newPost.submitPost(completion: {result in
                switch result {
                case .success:
                    // Refresh posts feed
                    print("Created post: ", text)
                case .failure:
                    print("Error submitting post")
                }
            })
        }
    }
    
}
