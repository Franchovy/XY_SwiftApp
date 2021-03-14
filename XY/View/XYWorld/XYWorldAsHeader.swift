//
//  XYWorldAsHeader.swift
//  XY
//
//  Created by Maxime Franchot on 14/03/2021.
//

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
            return "Rankings"
        }
    }
}

enum XYworldCell {
    case onlineNow(viewModel: ProfileViewModel)
    case ranking(viewModel: RankingViewModel)
}

class XYWorldAsHeader: UITableViewHeaderFooterView {
    static let identifier = "XYWorldAsHeader"
    
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
        
    private var sections = [XYworldSection]()
    
    private var onlineNowUsers = [ProfileViewModel]()
    private var rankingCells = [XYworldCell?]()
    
    weak var rankingBoardDelegate: RankingBoardCellDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    
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
        collectionView.allowsSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor(named: "Black")
        
        collectionView.register(
            SectionLabelReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionLabelReusableView.identifier
        )
        
        collectionView.register(OnlineNowCollectionViewCell.self,forCellWithReuseIdentifier: OnlineNowCollectionViewCell.identifier)
        collectionView.register(RankingBoardCell.self, forCellWithReuseIdentifier: RankingBoardCell.identifier)
        
        self.collectionView = collectionView
        
        addSubview(collectionView)
        collectionView.addSubview(noOnlineFriendsLabel)
        
        
        sections.append(XYworldSection(type: .onlineNow, cells: []))
        sections.append(XYworldSection(type: .ranking, cells: []))
        
        subscribeToOnlineNow()
        subscribeToRanking()
        
        subscribeToOnlineNow()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        noOnlineFriendsLabel.sizeToFit()
        noOnlineFriendsLabel.frame = CGRect(
            x: (width - noOnlineFriendsLabel.width)/2,
            y: 75,
            width: noOnlineFriendsLabel.width,
            height: noOnlineFriendsLabel.height
        )
        
        collectionView?.frame = CGRect(
            x: 0,
            y: 10,
            width: width,
            height: height - 10
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
    
    private func layout(for section: Int) -> NSCollectionLayoutSection {
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
                    widthDimension: .absolute(XYWorldAsHeader.onlineNowCellSize.width),
                    heightDimension: .absolute(XYWorldAsHeader.onlineNowCellSize.height)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(XYWorldAsHeader.onlineNowCellSize.height)
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
                    heightDimension: .absolute(XYWorldAsHeader.rankingBoardCellSize.height)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.95),
                    heightDimension: .absolute(XYWorldAsHeader.rankingBoardCellSize.height)
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

extension XYWorldAsHeader : UICollectionViewDelegate, UICollectionViewDataSource {
    
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
            cell.delegate = rankingBoardDelegate
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
