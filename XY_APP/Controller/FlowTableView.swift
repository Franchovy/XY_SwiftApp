//
//  FlowTableView.swift
//  XY_APP
//
//  Created by Maxime Franchot on 14/12/2020.
//

import Foundation
import UIKit

class FlowTableView : UITableView, UITableViewDelegate {
    
    var postLoader = PostLoader()
    var parentViewController: UIViewController?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // postLoader -> Async calls to load posts
        delegate = self
        dataSource = self
        register(UINib(nibName: K.imagePostCellNibName, bundle: nil), forCellReuseIdentifier: K.imagePostCellIdentifier)
        
        rowHeight = UITableView.automaticDimension
    }
    
    func getPosts() {
        // Clear current posts in feed
        //CellLoader.posts.removeAll()
        postLoader.refreshIds()
        reloadData()
        
        // Get posts from backend
        PostModel.getAllPosts(completion: { result in
            switch result {
            case .success(let newposts):
                if let newposts = newposts {
                    self.postLoader.posts.append(contentsOf: newposts)
                }
                self.reloadData()
            case .failure(let error):
                print("Failed to get posts! \(error)")
                self.postLoader.posts.append(PostModel(id: "0", username: "XY_AI", content: "There was a problem getting posts from the backend!", imageRefs: []))
                self.reloadData()
            }
        })
    }
}

extension FlowTableView : UITableViewDataSource {
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postLoader.posts.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get next cell from indexPath
        let cell:ImagePostCell
        cell = dequeueReusableCell(withIdentifier: K.imagePostCellIdentifier) as! ImagePostCell
        
        // Load cell from async loader using indexpath for id.
        postLoader.load(cell: cell, indexRow: indexPath.row)

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // method to run when table view cell is tapped
        let cell = tableView.cellForRow(at: indexPath) as! ImagePostCell
        let profileViewer = ProfileViewer()
        
        if let parentViewController = parentViewController {
            profileViewer.parentViewController = parentViewController
            profileViewer.segueToProfile(username: (cell.profile?.username)!)
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
