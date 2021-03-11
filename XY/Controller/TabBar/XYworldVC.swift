//
//  FriendsViewController.swift
//  XY_APP
//
//  Created by Simone on 07/12/2020.
//

import Foundation
import UIKit

struct XYworldSection {
    let type: XYworldSectionType
    let cells: [XYworldCell]
}

enum XYworldSectionType: CaseIterable {
    case onlineNow
    case ranking
    case flow
    
    var title: String {
        switch self {
        case .onlineNow:
            return "Online Friends"
        case .ranking:
            return "Rankings"
        case .flow:
            return "Flow"
        }
    }
}

enum XYworldCell {
    case onlineNow(viewModel: ProfileViewModel)
    case ranking(viewModel: RankingViewModel)
    case post(viewModel: NewPostViewModel)
}

class XYworldVC: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    
    private var noOnlineFriendsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 18)
        label.text = Int.random(in: 0...100) == 1 ? "No Friends Online #foreverAlone" : "No Friends Online 😢"
        label.isHidden = true
        label.textColor = UIColor(named: "tintColor")
        label.alpha = 0.7
        return label
    }()
    
    static var onlineNowCellSize = CGSize(width: 60, height: 80)
    static var rankingBoardCellSize = CGSize(width: 365, height: 230)

    private var collectionView: UICollectionView?
    
    let barXPCircle = CircleView()
    
    private var sections = [XYworldSection]()
    
    private var onlineNowUsers = [ProfileViewModel]()
    private var rankingCells = [XYworldCell?]()
    private var postModels = [NewPostViewModel]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barXPCircle)
        navigationItem.titleView = UIImageView(image: UIImage(named: "XYnavbarlogo"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        barXPCircle.registerXPUpdates(for: .ownUser)
        subscribeToOnlineNow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        barXPCircle.deregisterUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        barXPCircle.setProgress(level: 0, progress: 0.0)
        barXPCircle.setupFinished()
        barXPCircle.setLevelLabelFontSize(size: 24)
        barXPCircle.registerXPUpdates(for: .ownUser)
        
        let layout = UICollectionViewCompositionalLayout { section, _ -> NSCollectionLayoutSection? in
            return self.layout(for: section)
        }
        
        layout.configuration.scrollDirection = .vertical
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(named: "tintColor")
//        refreshControl.addTarget(self, action: #selector(flowRefreshed(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor(named: "Black")
        
        collectionView.register(
            SectionLabelReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionLabelReusableView.identifier
        )
        
        collectionView.register(OnlineNowCollectionViewCell.self,forCellWithReuseIdentifier: OnlineNowCollectionViewCell.identifier)
//        collectionView.register(ProfileCardCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCardCollectionViewCell.identifier)
        collectionView.register(RankingBoardCell.self, forCellWithReuseIdentifier: RankingBoardCell.identifier)
        collectionView.register(ImagePostCell.self, forCellWithReuseIdentifier: ImagePostCell.identifier)
        
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.addSubview(noOnlineFriendsLabel)
        
        sections.append(XYworldSection(type: .onlineNow, cells: []))
        sections.append(XYworldSection(type: .ranking, cells: []))
        sections.append(XYworldSection(type: .flow, cells: []))
        
        subscribeToOnlineNow()
        subscribeToRanking()
        fetchFlow()
    }
    
    override func viewDidLayoutSubviews() {
        barXPCircle.frame.size = CGSize(width: 25, height: 25)
        
        noOnlineFriendsLabel.sizeToFit()
        noOnlineFriendsLabel.frame = CGRect(
            x: (view.width - noOnlineFriendsLabel.width)/2,
            y: 75,
            width: noOnlineFriendsLabel.width,
            height: noOnlineFriendsLabel.height
        )
        
        collectionView?.frame = CGRect(
            x: 0,
            y: 10,
            width: view.width,
            height: view.height - 10
        )
    }
    
    private func subscribeToOnlineNow() {
        // Subscribe to Online Now in RT DB
        DatabaseManager.shared.subscribeToOnlineNow() { ids in
            if let ids = ids {
                self.loadOnlineNow(with: ids)
            }
        }
    }
    
    private func loadOnlineNow(with userProfileIDPairs: [(String, String)]) {
        self.onlineNowUsers = []
        
        guard let ownUserId = AuthManager.shared.userId else {
            return
        }
        
        if userProfileIDPairs.count > 1 {
            noOnlineFriendsLabel.isHidden = true
        } else {
            noOnlineFriendsLabel.isHidden = false
        }
        
        var cells = [XYworldCell]()
        for (userId, profileId) in userProfileIDPairs {
            if userId == ownUserId {
                continue
            }
            let viewModel = ProfileViewModel(profileId: profileId, userId: userId)
            
            self.onlineNowUsers.append(viewModel)
            cells.append(XYworldCell.onlineNow(viewModel: viewModel))
        }
        self.sections[0] = XYworldSection(type: .onlineNow, cells: cells)
    }
    
    func subscribeToRanking() {
        
        rankingCells = [XYworldCell?](repeating: nil, count: 2)
        
        RankingFirestoreManager.shared.getTopRanking(rankingLength: 3) { (rankingIDs) in
            let model = RankingModel(
                name: "Global",
                rankedUserIDs: rankingIDs
            )
            
            let builder = RankingViewModelBuilder()
            builder.build(model: model) { (rankingViewModel, error) in
                if let error = error {
                    print(error)
                } else if let rankingViewModel = rankingViewModel {
                    self.rankingCells[0] = XYworldCell.ranking(viewModel: rankingViewModel)
                    self.sections[1] = XYworldSection(type: .ranking, cells: self.rankingCells.flatMap{ $0 })
                    self.collectionView?.reloadData()
                }
            }
        }
        
        RankingFirestoreManager.shared.getTopRanking(rankingLength: 3) { (rankingIDs) in
            let model = RankingModel(
                name: "Friends",
                rankedUserIDs: rankingIDs
            )
            
            let builder = RankingViewModelBuilder()
            builder.build(model: model) { (rankingViewModel, error) in
                if let error = error {
                    print(error)
                } else if let rankingViewModel = rankingViewModel {
                    self.rankingCells[1] = XYworldCell.ranking(viewModel: rankingViewModel)
                    self.sections[1] = XYworldSection(type: .ranking, cells: self.rankingCells.flatMap{ $0 })
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    public func fetchFlow() {
        FlowAlgorithmManager.shared.getFlowFromFollowing() { postModels in
            if let postModels = postModels {
                let dispatchGroup = DispatchGroup()
                
                for model in postModels {
                    dispatchGroup.enter()
                    PostViewModelBuilder.build(from: model) { (postViewModel) in
                        defer {
                            dispatchGroup.leave()
                        }
                        
                        if let postViewModel = postViewModel {
                            self.postModels.append(postViewModel)
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    
                    self.sections[2] = XYworldSection(type: .flow, cells: self.postModels.compactMap({ XYworldCell.post(viewModel: $0) }))
                    
                    self.collectionView?.reloadData()
                }
            }
        }
    }
}

extension XYworldVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = sections[indexPath.section].cells[indexPath.row]

        switch model {
        case .onlineNow(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnlineNowCollectionViewCell.identifier, for: indexPath) as? OnlineNowCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModel)
            return cell
        case .ranking(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RankingBoardCell.identifier, for: indexPath) as? RankingBoardCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        case .post(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePostCell.identifier, for: indexPath) as? ImagePostCell else {
                return UICollectionViewCell()
            }
//            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionLabelReusableView.identifier,
                for: indexPath
            ) as! SectionLabelReusableView
            sectionHeader.label.text = sections[indexPath.section].type.title
            return sectionHeader
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
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
        }
    }
}

extension XYworldVC {
    func layout(for section: Int) -> NSCollectionLayoutSection {
        let sectionType = sections[section].type
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .absolute(200), heightDimension: .absolute(55)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading
        )
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 0)
        
        switch sectionType {
        case .onlineNow:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(XYworldVC.onlineNowCellSize.width),
                    heightDimension: .absolute(XYworldVC.onlineNowCellSize.height)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(XYworldVC.onlineNowCellSize.height)
                ),
                subitems: [item]
            )
            
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.boundarySupplementaryItems = [sectionHeader]
            sectionLayout.orthogonalScrollingBehavior = .continuous
            
            return sectionLayout
        case .ranking:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.95),
                    heightDimension: .absolute(XYworldVC.rankingBoardCellSize.height)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.95),
                    heightDimension: .absolute(XYworldVC.rankingBoardCellSize.height)
                ),
                subitems: [item]
            )
            
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            sectionLayout.boundarySupplementaryItems = [sectionHeader]
            sectionLayout.orthogonalScrollingBehavior = .continuous
            
            return sectionLayout
        case .flow:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1)
                ),
                subitems: [item]
            )
            
            let sectionLayout = NSCollectionLayoutSection(group: group)
            
//            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            sectionLayout.boundarySupplementaryItems = [sectionHeader]
            sectionLayout.orthogonalScrollingBehavior = .continuous
            
            return sectionLayout
            
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
        }
    }
}


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
