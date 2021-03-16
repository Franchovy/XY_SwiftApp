//
//  CreatePostViewController.swift
//  XY
//
//  Created by Maxime Franchot on 16/03/2021.
//

import UIKit

class CreatePostViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .darkGray
        return imageView
    }()
    
    private let captionField: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "Raleway-Medium", size: 20)
        textView.backgroundColor = UIColor(named:"XYCard")
        textView.textColor = UIColor(named: "XYTint")
        textView.keyboardDismissMode = .interactive
        textView.layer.cornerRadius = 10
        return textView
    }()
    
    enum State {
        case open
        case pickImage
        case provideDetails
        case posting
    }
    
    var state: State
    
    var tapToExitCaption: UITapGestureRecognizer!
    var pickImageGesture: UITapGestureRecognizer!
    
    init() {
        state = .open
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "Black")
        
        captionField.delegate = self
        
        view.addSubview(imageView)
        view.addSubview(captionField)
        
        navigationItem.title = "Create Post"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        
        imageView.isUserInteractionEnabled = true
        pickImageGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewPressed))
        imageView.addGestureRecognizer(pickImageGesture)
        
        tapToExitCaption = UITapGestureRecognizer(target: self, action: #selector(didTapToExitCaption))
        tapToExitCaption.isEnabled = false
        imageView.addGestureRecognizer(tapToExitCaption)
        view.addGestureRecognizer(tapToExitCaption)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(
            x: 10,
            y: view.safeAreaInsets.top + 10,
            width: view.width - 20,
            height: view.width - 20
        )
        
        captionField.frame = CGRect(
            x: 10,
            y: imageView.bottom + 10,
            width: view.width - 20,
            height: 80
        )
    }
    
    func setIsEditingCaption(_ isEditing: Bool) {
        if isEditing {
            tapToExitCaption.isEnabled = true
            pickImageGesture.isEnabled = false
        } else {
            tapToExitCaption.isEnabled = false
            pickImageGesture.isEnabled = true
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = editedImage
        } else if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc private func imageViewPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.modalPresentationStyle = .overFullScreen
        navigationController?.present(imagePicker, animated: true)
    }
    
    @objc private func didTapClose() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapDone() {
        guard let image = imageView.image else {
            displayError("Please pick an image!")
            return
        }
        guard let text = captionField.text, text != "" else {
            displayError("Please write a caption!")
            return
        }
        
        
        // Proceed to post
        PostFirestoreManager.shared.uploadPost(with: text, image: image) { (result) in
            switch result {
            case .success(let postViewModel):
                print("Successfully uploaded!")
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    @objc private func didTapToExitCaption() {
        captionField.resignFirstResponder()
        setIsEditingCaption(false)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setIsEditingCaption(true)
    }
    
    private func displayError(_ message: String) {
        print("Error: \(message)")
        
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 19)
        label.textColor = .red
        label.text = message
        label.sizeToFit()
        view.addSubview(label)
        label.frame.origin =
            CGPoint(
                x: (view.width - label.width)/2,
                y: captionField.bottom + 15
            )
        label.alpha = 0.0
        
        UIView.animate(withDuration: 0.5) {
            label.alpha = 1.0
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.5, delay: 2.0) {
                    label.alpha = 0.0
                } completion: { (done) in
                    if done {
                        label.removeFromSuperview()
                    }
                }
            }
        }
    }
}
