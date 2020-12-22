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
    var postsToSubmitFeedbackIds: [String] = []
    
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
        
        // Set viewcount timer
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: timerHandler)
        timer.fire()
        
        let feedbackTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: self.feedbackTimer)
        feedbackTimer.fire()
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
    
    
    // SWIPE RIGHT
    @objc internal func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let closeAction = UIContextualAction(style: .normal, title:  "+ XP", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            let cell = tableView.cellForRow(at: indexPath)
            self.swipeRightAnimation(cell: cell!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Remove cell from flow and reload
                if self.posts.count > 0 {
                    //self.posts.remove(at: indexPath.row - 1)
                    //tableView.reloadData()
                }
            }
            
            success(true)
        })
        closeAction.image = UIImage(named: "xp")
        closeAction.backgroundColor = .clear
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        
        // Add swipe left
        if self.posts.count > indexPath.row {
            var post = self.posts[indexPath.row - 1]
            post.feedback = PostManager.shared.updateFeedback(postId: post.id, viewTime: 0, swipeRights: 1, swipeLefts: 0)
            
            // Send Feedback to backend and update cells
            FeedbackAPI.shared.submitFeedback(postId: post.id, feedback: post.feedback!, completion: { result in
                switch result {
                case .success(let postUpdateXPData):
                    for postUpdate in postUpdateXPData {
                        for p in self.posts {
                            if p.id == postUpdate.id {
                                // Update data
                                PostManager.shared.addXP(postId: p.id, xp: Float(postUpdate.xp))
                                
                                print("Update data for post: \(postUpdate.id)")
                                // Update xp bar
                                DispatchQueue.main.async {
                                    let cellToUpdate = tableView.visibleCells.filter{
                                        guard let cell = $0 as? ImagePostCell else {return false}
                                        return cell.postId == postUpdate.id }.first as! ImagePostCell
                                    
                                    let post = PostManager.shared.getPostWithId(id: cellToUpdate.postId!)!
                                    
                                    let progressBar = cellToUpdate.XP as! GradientCircularProgressBarPost
                                    progressBar.progress = CGFloat(post.xpLevel.xp / Levels.shared.getNextLevel(xpLevel: post.xpLevel))
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("Error submitting feedback: \(error)")
                }
                
            })
        }
        
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
            
            // Add swipe left
            if self.posts.count > indexPath.row {
                var post = self.posts[indexPath.row]
                if post.feedback != nil {
                    post.feedback!.swipeLeft += 1
                } else {
                    post.feedback = PostManager.shared.updateFeedback(postId: post.id, viewTime: 0, swipeRights: 0, swipeLefts: 1)
                    
                    if !self.postsToSubmitFeedbackIds.contains(post.id) {
                        self.postsToSubmitFeedbackIds.append(post.id)
                    }
                }
            }
            
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
    
    func reloadVisibleProgressBars() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for cell in self.visibleCells {
                if let cell = cell as? ImagePostCell {
                    guard var post = PostManager.shared.getPostWithId(id: cell.postId!) else {return}
                    
                    let progressBar = cell.XP as! GradientCircularProgressBarPost
                    progressBar.progress = CGFloat(post.xpLevel.xp / Levels.shared.getNextLevel(xpLevel: post.xpLevel))
                }
            }
        }
    }
    
    func timerHandler(timer: Timer) {
        for cell in visibleCells {
            if let xpCell = cell as? ImagePostCell {
                guard var post = PostManager.shared.getPostWithId(id: xpCell.postId!) else {return}
                
                // Add viewtime
                post.feedback = PostManager.shared.updateFeedback(postId: post.id, viewTime: 1, swipeRights: 0, swipeLefts: 0)
                
                // Calculate XP gain
                post.xpLevel = Algorithm.shared.addXPfromPostFeedback(post: post)
                // Update XP gain
                PostManager.shared.updateXP(postId: post.id, xpLevel: post.xpLevel)
                // Register to submit feedback to backend
                if !self.postsToSubmitFeedbackIds.contains(post.id) {
                    self.postsToSubmitFeedbackIds.append(post.id)
                }
                // Update progress on progress bar
                let progressBar = xpCell.XP as! GradientCircularProgressBarPost // todo remove this line
                progressBar.progress = CGFloat(post.xpLevel.xp / Levels.shared.getNextLevel(xpLevel: post.xpLevel))
            }
        }
    }
    
    func feedbackTimer(timer: Timer) {
        if postsToSubmitFeedbackIds.count == 0 { return }
        
        var feedbackData: [String: Feedback] = [:]
        for postId in postsToSubmitFeedbackIds {
            let post = PostManager.shared.getPostWithId(id: postId)
            
            feedbackData[postId] = post?.feedback!
        }
        
        FeedbackAPI.shared.submitFeedbackForMultiple(data: feedbackData, completion: { result in
            switch result {
            case .success(let updatedXPDataArray):
                for updateXPData in updatedXPDataArray {
                    PostManager.shared.addXP(postId: updateXPData.id, xp: Float(updateXPData.xp))
                }
                self.reloadVisibleProgressBars()
            case .failure(let error):
                print("Error submitting feedback for posts: \(error)")
            }
        })
    }
}
