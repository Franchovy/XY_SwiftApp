//
//  HomeViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit


class NewsFeedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var ringBar: UIView!
    
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
            // Upload image
            ImageCache.insertAndUpload(image: newImage, closure: { result in
                switch result {
                case .success(let imageId):
                    if var imageIds = self.imageIds {
                        imageIds.append(imageId)
                    }
                    
                case .failure(let error):
                    print("Error uploading image")
            }
            })
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
            PostsAPI.shared.submitCreatePostRequest(content: text, imageIds: imageIds, closure: { result in
                switch result {
                case .success(let postData):
                    // Create post and put in news feed
                    
                    // Refresh feed
                    self.getPosts()
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error submitting post: \(error)")
                }
            })
        }
    }
}
    
}

@IBDesignable
class GradientCircularProgressBar: UIView {
    @IBInspectable var color: UIColor = .gray {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var gradientColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var ringWidth: CGFloat = 5

    var progress: CGFloat = 0.5 {
        didSet { setNeedsDisplay() }
    }

    private var progressLayer = CAShapeLayer()
    private var backgroundMask = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        createAnimation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        createAnimation()
    }

    private func setupLayers() {
        backgroundMask.lineWidth = ringWidth
        backgroundMask.fillColor = nil
        backgroundMask.strokeColor = UIColor.black.cgColor
        layer.mask = backgroundMask

        progressLayer.lineWidth = ringWidth
        progressLayer.fillColor = nil

        layer.addSublayer(gradientLayer)
        layer.transform = CATransform3DMakeRotation(CGFloat(90 * Double.pi / 180), 0, 0, -1)

        gradientLayer.mask = progressLayer
        gradientLayer.locations = [0.35, 0.5, 0.65]
    }

    private func createAnimation() {
        let startPointAnimation = CAKeyframeAnimation(keyPath: "startPoint")
        startPointAnimation.values = [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)]

        startPointAnimation.repeatCount = 1
        startPointAnimation.duration = 1

        let endPointAnimation = CAKeyframeAnimation(keyPath: "endPoint")
        endPointAnimation.values = [CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1), CGPoint.zero]

        endPointAnimation.repeatCount = 1
        endPointAnimation.duration = 1

        gradientLayer.add(startPointAnimation, forKey: "startPointAnimation")
        gradientLayer.add(endPointAnimation, forKey: "endPointAnimation")
    }

    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: ringWidth / 2, dy: ringWidth / 2))
        backgroundMask.path = circlePath.cgPath

        progressLayer.path = circlePath.cgPath
        progressLayer.lineCap = .round
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.strokeColor = UIColor.black.cgColor

        gradientLayer.frame = rect
        gradientLayer.colors = [color.cgColor, gradientColor.cgColor, color.cgColor]
    }
    @IBAction func buttonPressed(_ sender: Any) {
        createAnimation()
    }
}





