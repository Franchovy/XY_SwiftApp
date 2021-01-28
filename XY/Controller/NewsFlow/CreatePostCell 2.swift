//
//  CreatePostCell.swift
//  XY_APP
//
//  Created by Simone on 02/01/2021.
//

import UIKit

class CreatePostCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var postPlaceholder: UITextField!
    
    @IBOutlet weak var createPostView: UIView!
    
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var addPhotoPostButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        postPlaceholder.layer.cornerRadius = 10
        createPostView.layer.cornerRadius = 15
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //postPlaceholder.largeContentImage = photo
        
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func addPostButtonPressed(_ sender: UIButton) {
     
        //present(imagePicker, animated: true, completion: nil)
        
    }
    
}
