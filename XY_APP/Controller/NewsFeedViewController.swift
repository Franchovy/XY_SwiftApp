//
//  HomeViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit


class NewsFeedViewController: UIViewController {
    
    // don't forget to hook this up from the storyboard
    @IBOutlet weak var tableView: FlowTableView!

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
    
}

