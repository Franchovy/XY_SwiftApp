//
//  FlowTableView.swift
//  XY_APP
//
//  Created by Maxime Franchot on 14/12/2020.
//

import Foundation
import UIKit

class FlowTableView : UITableView, UITableViewDelegate {
    
    var posts: [Post] = []
    var parentViewController: UIViewController?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        delegate = self
        dataSource = self

        // Register celltype PostViewCell
        register(UINib(nibName: K.imagePostCellNibName, bundle: nil), forCellReuseIdentifier: K.imagePostCellIdentifier)
        
        rowHeight = UITableView.automaticDimension
    }
    
    func getPosts() {
        // Clear current posts in feed
        reloadData()
        
        // Get posts from backend
        Post.getAllPosts(completion: { result in
            switch result {
            case .success(let newposts):
                if let newposts = newposts {
                    self.posts.append(contentsOf: newposts)
                }
                self.reloadData()
            case .failure(let error):
                print("Failed to get posts! \(error)")
                self.posts.append(Post(id: "0", username: "XY_AI", timestamp: Date(),content: "There was a problem getting posts from the backend!", imageRefs: []))
                self.reloadData()
            }
        })
    }
}

extension FlowTableView : UITableViewDataSource {
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get next cell from indexPath
        let cell:ImagePostCell
        cell = dequeueReusableCell(withIdentifier: K.imagePostCellIdentifier) as! ImagePostCell
        
        // Load cell from async loader using indexpath for id.
        cell.loadFromPost(post: posts[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // method to run when table view cell is tapped
        let cell = tableView.cellForRow(at: indexPath) as! ImagePostCell
        
        let profileViewer = ProfileViewer()
        
        if let parentViewController = parentViewController {
            profileViewer.parentViewController = parentViewController
            
            let post = posts[indexPath.row]
            profileViewer.segueToProfile(username: post.username)
        } else {
            fatalError("parentViewController needs to be set for navigating to profile!")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15 // Return the spacing between sections
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear // Make the background color show through
        return headerView
    }
}
