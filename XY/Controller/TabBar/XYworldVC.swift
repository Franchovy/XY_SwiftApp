//
//  FriendsViewController.swift
//  XY_APP
//
//  Created by Simone on 07/12/2020.
//

import Foundation
import UIKit



class XYworldVC: UIViewController, UISearchBarDelegate {
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.sectionHeaderHeight = 450
        tableView.estimatedRowHeight = 350
        tableView.backgroundColor = UIColor(named: "XYblack")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(XYWorldAsHeader.self, forHeaderFooterViewReuseIdentifier: XYWorldAsHeader.identifier)
        tableView.register(ImagePostCell.self, forCellReuseIdentifier: ImagePostCell.identifier)
        return tableView
    }()
    
    let barXPCircle: CircleView = {
        let circleView = CircleView()
        circleView.setProgress(level: 0, progress: 0.0)
        circleView.setupFinished()
        circleView.setLevelLabelFontSize(size: 24)
        circleView.registerXPUpdates(for: .ownUser)
        return circleView
    }()
    
    private var postModels = [(PostModel, NewPostViewModel?)]()
    
    // MARK: - Properties
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(xpButtonPressed))
        barXPCircle.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self

        navigationItem.titleView = UIImageView(image: UIImage(named: "XYNavbarLogo"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        fetchFlow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        barXPCircle.registerXPUpdates(for: .ownUser)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        barXPCircle.deregisterUpdates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        barXPCircle.frame.size = CGSize(width: 25, height: 25)
        tableView.frame = view.bounds.inset(by: view.safeAreaInsets)
    }
    
    @objc private func xpButtonPressed() {
        let vc = NotificationsVC()
        vc.isHeroEnabled = true
        vc.modalPresentationStyle = .fullScreen
        vc.heroModalAnimationType = .pageIn(direction: .left)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public func fetchFlow() {
        FlowAlgorithmManager.shared.getFlowFromFollowing() { postModels in
            if let postModels = postModels {
                self.postModels.append(contentsOf: postModels.map({ ($0, nil) }))
                self.tableView.reloadData()
                                
                for model in postModels {
                    PostViewModelBuilder.build(from: model) { (postViewModel) in
                        if let postViewModel = postViewModel {
                            
                            let cellIndex = self.postModels.firstIndex(where: { $0.0.id == model.id })!
                            self.postModels[cellIndex] = (self.postModels[cellIndex].0, postViewModel)
                            self.tableView.reloadRows(at: [IndexPath(row: cellIndex, section: 0)], with: .fade)
                        }
                    }
                }
            }
        }
    }
}

extension XYworldVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: XYWorldAsHeader.identifier) as? XYWorldAsHeader else {
            return UIView()
        }
        header.rankingBoardDelegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagePostCell.identifier, for: indexPath) as? ImagePostCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: postModels[indexPath.row].1)
        
        return cell
    }
}

extension XYworldVC : RankingBoardCellDelegate {
    func didTapRankingBoard(with viewModel: RankingViewModel) {
        let vc = RankingsViewController()
        vc.configure(with: viewModel)
        
        navigationController?.pushViewController(vc, animated: true)

        if (viewModel.name == "Global") {
            RankingFirestoreManager.shared.getTopRanking(rankingLength: 30) { (rankingIDs) in
                let model = RankingModel(
                    name: "Global",
                    rankedUserIDs: rankingIDs
                )
                
                let builder = RankingViewModelBuilder()
                builder.build(model: model) { (rankingViewModel, error) in
                    if let error = error {
                        print(error)
                    } else if let rankingViewModel = rankingViewModel {
                        vc.configure(with: rankingViewModel)
                    }
                }
            }
        } else {
            RankingFirestoreManager.shared.getFriendsRanking(rankingLength: 30) { (rankingIDs) in
                guard let rankingIDs = rankingIDs else {
                    return
                }
                let model = RankingModel(
                    name: "Friends",
                    rankedUserIDs: rankingIDs
                )
                
                let builder = RankingViewModelBuilder()
                builder.build(model: model) { (rankingViewModel, error) in
                    if let error = error {
                        print(error)
                    } else if let rankingViewModel = rankingViewModel {
                        vc.configure(with: rankingViewModel)
                    }
                }
            }
        }
    }
}

    
//        case .post:
//            let cell = tableView.cellForRow(at: indexPath) as! ImagePostCell
//
//            let originalTransform = cell.transform
//            let shrinkTransform = cell.transform.scaledBy(x: 0.95, y: 0.95)
//
//            UIView.animate(withDuration: 0.2) {
//                cell.transform = shrinkTransform
//            } completion: { (done) in
//                if done {
//                    UIView.animate(withDuration: 0.2) {
//                        cell.transform = originalTransform
//                    }
//                }
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
//                cell.setHeroIDs(forPost: "post", forCaption: "caption", forImage: "image")
//
//                let vc = PostViewController()
//                vc.configure(with: self.postViewModels[indexPath.row])
//                vc.isHeroEnabled = true
//
//                vc.onDismiss = { cell.setHeroIDs(forPost: "", forCaption: "", forImage: "") }
//
//                vc.setHeroIDs(forPost: "post", forCaption: "caption", forImage: "image")
//
//                self.navigationController?.isHeroEnabled = true
//                self.navigationController?.pushViewController(vc, animated: true)
//
//            }


// MARK: - ImagePostCell Delegate functions

//extension XYworldVC : ImagePostCellDelegate {
//    func imagePostCellDelegate(reportPressed postId: String) {
//        let alert = UIAlertController(title: "Report", message: "Why are you reporting this post?", preferredStyle: .alert)
//
//        alert.addTextField { (textfield) in
//            textfield.placeholder = "Report details"
//            textfield.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
//        }
//        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action) in
//            let textfield = alert.textFields![0]
//
//            guard let text = textfield.text else {
//                return
//            }
//
//            FirebaseUpload.sendReport(message: text, postId: postId)
//
//            if let index = self.postViewModels.firstIndex(where: { $0.id == postId }) {
//                self.postViewModels.remove(at: index)
//                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
//
//        }))
//
//        present(alert, animated: true, completion: nil)
//    }
//
//    func imagePostCellDelegate(didOpenPostVCFor cell: ImagePostCell) {
//
//    }
//
//    func imagePostCellDelegate(willSwipeLeft cell: ImagePostCell) {
//        guard let cellIndex = tableView.indexPath(for: cell),
//              postViewModels.count > cellIndex.row else {
//            return
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + cell.swipeAnimationDuration - 0.2) {
//            self.tableView.scrollToRow(at: IndexPath(row: cellIndex.row, section: cellIndex.section), at: .middle, animated: true)
//        }
//    }
//
//    func imagePostCellDelegate(willSwipeRight cell: ImagePostCell) {
//        guard let cellIndex = tableView.indexPath(for: cell),
//              postViewModels.count > cellIndex.row else {
//            return
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + cell.swipeAnimationDuration - 0.2) {
//            self.tableView.scrollToRow(at: IndexPath(row: cellIndex.row, section: cellIndex.section), at: .middle, animated: true)
//        }
//    }
//
//    func imagePostCellDelegate(didSwipeLeft cell: ImagePostCell) {
//        guard let cellIndex = tableView.indexPath(for: cell),
//              postViewModels.count > cellIndex.row else {
//            return
//        }
//
//        self.postViewModels.remove(at: cellIndex.row)
//
//        self.tableView.deleteRows(at: [cellIndex], with: .bottom)
//
//        guard let postId = cell.viewModel?.id else {
//            return
//        }
//        FirebaseFunctionsManager.shared.swipeLeft(postId: postId)
//    }
//
//    func imagePostCellDelegate(didSwipeRight cell: ImagePostCell) {
//        guard let cellIndex = tableView.indexPath(for: cell),
//              postViewModels.count > cellIndex.row else {
//            return
//        }
//
//        self.postViewModels.remove(at: cellIndex.row)
//
//        self.tableView.deleteRows(at: [cellIndex], with: .bottom)
//
//        guard self.postViewModels.count > cellIndex.row else {
//            return
//        }
//
//        guard let postId = cell.viewModel?.id else {
//            return
//        }
//
//        FirebaseFunctionsManager.shared.swipeRight(postId: postId)
//    }
//}
