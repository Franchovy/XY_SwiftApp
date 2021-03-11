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
    
    var title: String {
        switch self {
        case .onlineNow:
            return "Online Friends"
        case .ranking:
            return "Ranking"
        }
    }
}

enum XYworldCell {
    case onlineNow(viewModel: ProfileViewModel)
    case ranking(viewModel: RankingViewModel)
}

class XYworldVC: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    
    private var noOnlineFriendsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 18)
        label.text = "No Friends Online."
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(named: "tintColor")
//        refreshControl.addTarget(self, action: #selector(flowRefreshed(_:)), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        let layout = UICollectionViewCompositionalLayout { section, _ -> NSCollectionLayoutSection? in
            return self.layout(for: section)
        }
        
        layout.configuration.scrollDirection = .vertical
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        
        collectionView.backgroundColor = UIColor(named: "Black")
        
        collectionView.register(
            SectionLabelReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionLabelReusableView.identifier
        )
        
        collectionView.register(
            OnlineNowCollectionViewCell.self,
            forCellWithReuseIdentifier: OnlineNowCollectionViewCell.identifier
        )
        collectionView.register(
            ProfileCardCollectionViewCell.self,
            forCellWithReuseIdentifier: ProfileCardCollectionViewCell.identifier
        )
        collectionView.register(
            RankingBoardCell.self,
            forCellWithReuseIdentifier: RankingBoardCell.identifier
        )
        
        self.collectionView = collectionView
        
        view.addSubview(collectionView)
        collectionView.addSubview(noOnlineFriendsLabel)
        
        sections.append(XYworldSection(type: .onlineNow, cells: []))
        sections.append(XYworldSection(type: .ranking, cells: []))
        
        subscribeToOnlineNow()
        subscribeToRanking()
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
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OnlineNowCollectionViewCell.identifier,
                for: indexPath
            ) as? OnlineNowCollectionViewCell else {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: "cell",
                    for: indexPath
                )
            }
            cell.configure(with: viewModel)
            return cell
        case .ranking(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RankingBoardCell.identifier,
                for: indexPath
            ) as? RankingBoardCell else {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: "cell",
                    for: indexPath
                )
            }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = sections[indexPath.section].cells[indexPath.row]

        switch model {
        case .onlineNow(let _):
            break
        case .ranking(let viewModel):
            let vc = RankingsViewController()
            vc.configure(with: viewModel)
            
            navigationController?.pushViewController(vc, animated: true)
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
        }
    }
}

