//
//  HomeViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit


class NewsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    // Data model: These strings will be the data for the table view cells
    var posts: [PostModel] = []
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 5
    
    // don't forget to hook this up from the storyboard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var createPostTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Get posts from backend
        getPosts()
                        
        // Remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Along with auto layout, these are the keys for enabling variable cell height
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
    }

    
    func getPosts() {
        // Clear current posts in feed
        posts.removeAll()
        tableView.reloadData()
        
        // Get posts from backend
        PostModel.getAllPosts(completion: { result in
            switch result {
            case .success(let newposts):
                if let newposts = newposts {
                    self.posts.append(contentsOf: newposts)
                }
                self.tableView.reloadData()
            case .failure(let error):
                print("Failed to get posts! \(error)")
                self.posts.append(PostModel(username: "XY_AI", content: "There was a problem getting posts from the backend!", imageRefs: ["J2NTP9Er4Ad3kRsms7XRoD"]))
                self.tableView.reloadData()
            }
        })
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:PostViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PostViewCell
        
        cell.loadFromPost(post: self.posts[indexPath.row])
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}
