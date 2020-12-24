//
//  FlowTableView.swift
//  XY_APP
//
//  Created by Maxime Franchot on 14/12/2020.
//

import Foundation
import UIKit


class FlowTableView : UITableView, UITableViewDelegate {

    //var cells: [Item]
    var posts: [PostData] = []
    
    var parentViewController: UIViewController?
    
    var submitPostCompletion: ((_ postContent:String) -> Void)?
    var addImageCompletion: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        delegate = self
        dataSource = self

        // Register celltype PostViewCell
        register(UINib(nibName: K.imagePostCellNibName, bundle: nil), forCellReuseIdentifier: K.imagePostCellIdentifier)
        register(UINib(nibName: "WritePostViewTableViewCell", bundle: nil), forCellReuseIdentifier: "CreatePostCell")
        
        rowHeight = UITableView.automaticDimension
    }
    
    func getPosts() {
        // Clear current posts in feed
        DispatchQueue.main.async {
            self.reloadData()
        }
        
        // Get posts from backend
        PostsAPI.shared.getAllPosts(completion: { result in
            switch result {
            case .success(let newposts):
                if let newposts = newposts {
                    self.posts.append(contentsOf: newposts)
                }
                self.reloadData()
            case .failure(let error):
                print("Failed to get posts! \(error)")
                self.posts.append(PostData(id: "0", username: "XY_AI", timestamp: Date(),content: "There was a problem getting posts from the backend!", images: []))
                self.reloadData()
            }
        })
    }
    
    func addImageButtonPressed() {
        // Call imagepicker
        addImageCompletion?()
    }
    
    func submitButtonPressed(postContent:String) {
        // Submit post
        submitPostCompletion?(postContent)
    }
}

extension FlowTableView : UITableViewDataSource {
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count + 1
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get next cell from indexPath
        
        // TESTING CODE - Make the first cell into a create post cell.
        if indexPath.row == 0 {
            let cell = dequeueReusableCell(withIdentifier: "CreatePostCell") as! WritePostViewTableViewCell
            print("Added WritePostViewTableViewCell!")
            
            cell.onImageButtonPressed = addImageButtonPressed
            cell.onSubmitButtonPressed = submitButtonPressed
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        // Load cell from async loader using indexpath for id.
        if let cell = dequeueReusableCell(withIdentifier: K.imagePostCellIdentifier) as? ImagePostCell {
            cell.loadFromPost(post: posts[indexPath.row - 1])
            return cell

        } else if let cell = dequeueReusableCell(withIdentifier: "CreatePostCell") as? WritePostViewTableViewCell {
            print("Added WritePostViewTableViewCell!")
            return cell

        }
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // method to run when table view cell is tapped
        if let cell = tableView.cellForRow(at: indexPath) as? ImagePostCell {
            let profileViewer = ProfileViewer()
            
            if let parentViewController = parentViewController {
                profileViewer.parentViewController = parentViewController
                
                let post = posts[indexPath.row - 1]
                profileViewer.segueToProfile(username: post.username)
            } else {
                fatalError("parentViewController needs to be set for navigating to profile!")
            }
        } else if let cell = tableView.cellForRow(at: indexPath) as? WritePostViewTableViewCell {
            print("Tapped WritePostViewTableViewCell!")
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
    
    @objc fileprivate func swipeRightAnimation(cell: UITableViewCell) {
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            
            cell.transform = cell.transform.translatedBy(x: 500, y: 0)
        })
    }
    
    @objc fileprivate func swipeLeftAnimation(cell: UITableViewCell) {
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            
            cell.transform = cell.transform.translatedBy(x: -500, y: 0)
        })
    }
    
    @objc internal func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let closeAction = UIContextualAction(style: .normal, title:  "+ XP", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("OK, marked as Closed")
            let cell = tableView.cellForRow(at: indexPath)
            self.swipeRightAnimation(cell: cell!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Remove cell from flow and reload
                if self.posts.count > 0 {
                    self.posts.remove(at: indexPath.row - 1)
                    tableView.reloadData()
                }
            }
            
            success(true)
        })
        closeAction.image = UIImage(named: "xp")
        closeAction.backgroundColor = .clear
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        
        let actionsConfig = UISwipeActionsConfiguration(actions: [closeAction])
        actionsConfig.performsFirstActionWithFullSwipe = true
        
        return actionsConfig
    }
    
    // SWIPE LEFT
    func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let modifyAction = UIContextualAction(style: .normal, title:  "Remove from flow", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            let cell = tableView.cellForRow(at: indexPath)
            self.swipeLeftAnimation(cell: cell!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Remove cell from flow and reload
                self.posts.remove(at: indexPath.row - 1)
                tableView.reloadData()
            }
            
            success(true)
        })
        
        modifyAction.image = UIImage(named: "hide")
        modifyAction.backgroundColor = .none
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
     
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
}
