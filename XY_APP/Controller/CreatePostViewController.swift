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
            let newPost = PostModel(id: "", username: "user", timestamp: Date(), content: text, imageRefs: [])
            newPost.submitPost(images: nil, completion: {result in
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
