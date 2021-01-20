//
//  CreatePostVC.swift
//  XY_APP
//
//  Created by Simone on 01/01/2021.
//

import Foundation
import UIKit
import Vision

class CreatePostVC: UIViewController, UINavigationControllerDelegate, XYImagePickerDelegate  {
    
    func presentImagePicker(imagePicker: UIImagePickerController) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func onImageUploadSucceed() {
        // Navigate to flow
        tabBarController!.selectedIndex = 0 // index for Flow
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.layer.cornerRadius = 15
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CreatePostCell", bundle: nil), forCellReuseIdentifier: "CreatePostReusable")

    }
}

extension CreatePostVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatePostReusable", for: indexPath) as! CreatePostCell
        
        cell.delegate = self
        
        return cell
        
    }
    
    
    
}
