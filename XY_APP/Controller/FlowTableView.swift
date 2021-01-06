//
//  FlowTableView.swift
//  XY_APP
//
//  Created by Maxime Franchot on 14/12/2020.
//

import Foundation
import UIKit


class FlowTableView : UITableView, UITableViewDelegate {

    var posts: [PostData] = []
    
    var postsToSubmitFeedbackIds: [String] = []
    
    var parentViewController: UIViewController?
    
    // remove
    var submitPostCompletion: ((_ postContent:String) -> Void)?
    var addImageCompletion: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        delegate = self
        dataSource = self

        // Register celltype PostViewCell
    
        register(UINib(nibName: "FlowMomentsTableViewCell", bundle: nil), forCellReuseIdentifier: "MomentsCell")
        register(UINib(nibName: K.imagePostCellNibName, bundle: nil), forCellReuseIdentifier: K.imagePostCellIdentifier)
        
        rowHeight = UITableView.automaticDimension
        
        // Load data from firebase
        //FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.posts).document("")
        
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
        
        if indexPath.row == 0 {
            return dequeueReusableCell(withIdentifier: FlowMomentsTableViewCell.reusableIdentifier) as! FlowMomentsTableViewCell
        } else {
            let cell = dequeueReusableCell(withIdentifier: K.imagePostCellIdentifier) as! ImagePostCell
            cell.loadPostData(post: posts[indexPath.row - 1])
            cell.XP.backgroundColor = .clear
            cell.XP.levelLabel.textColor = .white
            cell.XP.levelLabel.text = "1"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // method to run when table view cell is tapped

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
        
        if self.posts.count > indexPath.row {
            var post = self.posts[indexPath.row - 1]
            post.feedback = PostManager.shared.updateFeedback(postId: post.id, viewTime: 0, swipeRights: 1, swipeLefts: 0)
            
            if !self.postsToSubmitFeedbackIds.contains(post.id) {
                self.postsToSubmitFeedbackIds.append(post.id)
            }
            
            self.updateFeedbackData()
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
            
            if self.posts.count > indexPath.row {
                var post = self.posts[indexPath.row]
                if post.feedback != nil {
                    post.feedback!.swipeLeft += 1
                } else {
                    post.feedback = PostManager.shared.updateFeedback(postId: post.id, viewTime: 0, swipeRights: 0, swipeLefts: 1)
                    
                    if !self.postsToSubmitFeedbackIds.contains(post.id) {
                        self.postsToSubmitFeedbackIds.append(post.id)
                    }
                    
                    self.updateFeedbackData()
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
            // Reload User progress bar
            
            
            // Reload post progress bars
            for cell in self.visibleCells {
                if let cell = cell as? ImagePostCell {
                    guard var post = PostManager.shared.getPostWithId(id: cell.postId!) else {return}
                    
                    let progressBar = cell.XP.progressBarCircle!
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
                //post.xpLevel = Algorithm.shared.addXPfromPostFeedback(post: post)
                // Update XP gain
                //PostManager.shared.updateXP(postId: post.id, xpLevel: post.xpLevel)
                // Register to submit feedback to backend
                if !self.postsToSubmitFeedbackIds.contains(post.id) {
                    self.postsToSubmitFeedbackIds.append(post.id)
                }
                // Update progress on progress bar
                let progressBar = xpCell.XP.progressBarCircle!
                progressBar.color = post.xpLevel.getColor()
                progressBar.progress = CGFloat(PostManager.shared.getXP(postId: post.id).xp / Levels.shared.getNextLevel(xpLevel: post.xpLevel))
            }
        }
    }
    
    func feedbackTimer(timer: Timer) {
        updateFeedbackData()
    }
    
    func updateFeedbackData() {
        if postsToSubmitFeedbackIds.count == 0 { return }
        
        var feedbackData: [String: Feedback] = [:]
        for postId in postsToSubmitFeedbackIds {
            let post = PostManager.shared.getPostWithId(id: postId)
            
            feedbackData[postId] = post?.feedback!
        }
        
        FeedbackAPI.shared.submitFeedbackForMultiple(data: feedbackData, completion: { result in
            switch result {
            case .success(let updatedXPDataArray):
                PostManager.shared.addXPUpdateData(updatedXPDataArray: updatedXPDataArray)

                self.reloadVisibleProgressBars()
            case .failure(let error):
                print("Error submitting feedback for posts: \(error)")
            }
        })
    }
}


