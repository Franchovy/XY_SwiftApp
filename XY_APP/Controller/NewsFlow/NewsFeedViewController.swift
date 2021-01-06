//
//  HomeViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit
import Firebase
import FirebaseStorage

class NewsFeedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var ringBar: CircleView!
    
    @IBOutlet weak var tableView: FlowTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.parentViewController = self
        
        
        
        // Set posts inside tableview
    
        // Remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
    }
    
    
    
    @IBAction func xpButtonPressed(_ sender: UIBarButtonItem) {
        
    }
}

