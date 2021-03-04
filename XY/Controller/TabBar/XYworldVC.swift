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
    case userRanking
    case ranking
    
    var title: String {
        switch self {
        case .onlineNow:
            return "Online Friends"
        case .userRanking:
            return ""
        case .ranking:
            return ""
        }
    }
}


enum XYworldCell {
    case onlineNow(viewModel: ProfileViewModel)
    case userRanking(viewModel: ProfileViewModel)
    case ranking(viewModel: RankingViewModel)
}


class XYworldVC: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    
    @IBOutlet var xyworldSearchBar: UISearchBar!
    @IBOutlet var xyworldTableView: UITableView!
    
    static var onlineNowCellSize = CGSize(width: 95, height: 125)
    static var rankingBoardCellSize = CGSize(width: 365, height: 230)

    private var collectionView: UICollectionView?
    
    private var sections = [XYworldSection]()
    
    private var onlineNowUsers = [ProfileViewModel]()
    private var userRanking = [ProfileViewModel]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
//        sections.append(XYworldSection(type: .onlineNow, cells: []))
//        sections.append(XYworldSection(type: .userRanking, cells: []))
        
        // Search bar
        xyworldSearchBar.delegate = self
        navigationItem.titleView = xyworldSearchBar
        xyworldSearchBar.placeholder = "Search"
        
        let textFieldInsideSearchBar = xyworldSearchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        if let textFieldInsideSearchBar = self.xyworldSearchBar.value(forKey: "searchField") as? UITextField,
           let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
            
            //Magnifying glass
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .gray
        }
        
        let tappedAnywhereGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhereGesture))
        view.addGestureRecognizer(tappedAnywhereGestureRecognizer)
        
        
        let rankingViewModelBuilder = RankingViewModelBuilder()
        rankingViewModelBuilder.build(model: RankingModel(
                                        name: "Top Ranking", rankedUserIDs: ["aaa", "bbb", "ccc", "ddd", "eee", "fff"])) { (rankingVM, error) in
            if let rankingVM = rankingVM {
                print("rankingVM recieved")
            }
        }
        
        ///
        
        let rankingdemo = RankingViewModel(
            name: "Top Ranking",
            cells: [
                RankingCellViewModel(userID: "1", image: UIImage(named: "testface"), name: "C3-0", rank: 1, level: 5, xp: 15000),
                RankingCellViewModel(userID: "2", image: UIImage(named: "testface"), name: "C3-T0", rank: 2, level: 5, xp: 10000),
                RankingCellViewModel(userID: "3", image: UIImage(named: "testface"), name: "Elon Musk", rank: 3, level: 5, xp: 5000)
            ]
        )
        
        sections.append(XYworldSection(type: .ranking, cells: [XYworldCell.ranking(viewModel: rankingdemo)]))
        
        ///
        
        return
        
        FirebaseDownload.getRanking() { result in
            switch result {
            case .success(let userList):
                var userRankingCells = [XYworldCell?](repeating: nil, count: userList.count)
                for userId in userList {
                    let index = userList.firstIndex(of: userId)!
                    
                    FirebaseDownload.getProfileId(userId: userId) { (profileId, error) in
                        if let error = error {
                            print("Error fetching profileId: \(error)")
                        }
                        if let profileId = profileId {
                            let viewModel = ProfileViewModel(profileId: profileId, userId: userId)
                            
                            print("Inserting at index: \(index)")
                            if userRankingCells.count < index {
                                userRankingCells.insert(XYworldCell.userRanking(viewModel: viewModel), at: index)
                            } else {
                                userRankingCells[index] = XYworldCell.userRanking(viewModel: viewModel)
                            }
                        }
                        print(userRankingCells)
                        if !userRankingCells.contains(where: { $0 == nil }) {
                            // Finished loading
                            self.loadUserRanking(cells: userRankingCells.compactMap({ $0! }))
                        }
                    }
                }
            case .failure(let error):
                print("Error fetching userId rankings: \(error)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        collectionView?.frame = CGRect(
            x: 0,
            y: 10,
            width: view.width,
            height: view.height - 10
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let ownUserId = AuthManager.shared.userId else {
            return
        }
        
        // Subscribe to Online Now in RT DB
        DatabaseManager.shared.subscribeToOnlineNow() { ids in
            if let ids = ids {
                self.onlineNowUsers = []
                
                var cells = [XYworldCell]()
                for (userId, profileId) in ids {
                    if userId == ownUserId {
                        continue
                    }
                    let viewModel = ProfileViewModel(profileId: profileId, userId: userId)
                    
                    self.onlineNowUsers.append(viewModel)
                    cells.append(XYworldCell.onlineNow(viewModel: viewModel))
                }
                self.loadOnlineNowSection(cells: cells)
            }
        }
    }
    
    private func loadUserRanking(cells: [XYworldCell]) {
        return
        if cells.count == 0 {
            sections.removeAll { $0.type == .userRanking }
            return
        }
        
        let userRankingSection = XYworldSection.init(type: .userRanking, cells: cells)
        
        if sections.count > 1 {
          if sections[1].type == .userRanking {
            sections[1] = userRankingSection
          }
        } else if sections[0].type == .userRanking {
            sections[0] = userRankingSection
        }
        
        collectionView?.reloadData()
    }
    
    private func loadOnlineNowSection(cells: [XYworldCell]) {
        if cells.count == 0 {
            sections.removeAll { $0.type == .onlineNow }
        } else {
            let newSection = XYworldSection.init(type: .onlineNow, cells: cells)
            
            if sections[0].type != .onlineNow {
                if sections[0].type == .userRanking {
                    sections.insert(newSection, at: 0)
                } else {
                    sections.append(newSection)
                }
            } else {
                sections[0] = newSection
            }
        }
        
        collectionView?.reloadData()
    }
    
    @objc private func tappedAnywhereGesture() {
        xyworldSearchBar.resignFirstResponder()
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
        case .userRanking(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileCardCollectionViewCell.identifier,
                for: indexPath
            ) as? ProfileCardCollectionViewCell else {
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
}

extension XYworldVC {
    func layout(for section: Int) -> NSCollectionLayoutSection {
        let sectionType = sections[section].type
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .absolute(200), heightDimension: .absolute(55)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading
        )
//        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
        
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
        case .userRanking, .ranking:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(XYworldVC.rankingBoardCellSize.width),
                    heightDimension: .absolute(XYworldVC.rankingBoardCellSize.height)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(XYworldVC.rankingBoardCellSize.width),
                    heightDimension: .absolute(XYworldVC.rankingBoardCellSize.height)
                ),
                subitems: [item]
            )
            
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.boundarySupplementaryItems = [sectionHeader]
            sectionLayout.orthogonalScrollingBehavior = .continuous
            
            return sectionLayout
        }
    }
}

