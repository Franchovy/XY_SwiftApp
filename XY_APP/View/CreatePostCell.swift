//
//  CreatePostCell.swift
//  XY_APP
//
//  Created by Simone on 02/01/2021.
//

import UIKit
import FirebaseAuth

protocol XYImagePickerDelegate {
    func presentImagePicker(imagePicker: UIImagePickerController)
    func onImageUploadSucceed()
}

class CreatePostCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: XYImagePickerDelegate?
    
    @IBOutlet weak var createPostView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var captionEditor: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addImageGestureRecognizer(tapGestureRecognizer:)))
        createPostView.addGestureRecognizer(tapGesture)
    }
    
    @objc func addImageGestureRecognizer(tapGestureRecognizer: UITapGestureRecognizer) {
        openImagePicker()
    }
    
    @IBAction func addImageButtonPressed(_ sender: Any) {
        openImagePicker()
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        submitButton.isEnabled = false
        
        if let image = imagePreview.image {
            // Upload post
            FirebaseUpload.createPost(caption: captionEditor.text ?? "", image: image) { result in
                switch result {
                case .success(let postData):
                    self.delegate?.onImageUploadSucceed()
                case .failure(let error):
                    self.submitButton.isEnabled = true
                    print("Error uploading post: \(error)")
                }
            }
        } else {
            plusButton.shake()
        }
    }
    
    func openImagePicker() {
        delegate?.presentImagePicker(imagePicker: imagePicker)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        captionEditor.layer.cornerRadius = 10
        createPostView.layer.cornerRadius = 15
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // This is probably a bad way to do it, but for now the imagePreview image is where the image is stored.
            imagePreview.image = image
            plusButton.isHidden = true
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }    
}
