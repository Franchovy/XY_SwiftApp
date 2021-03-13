//
//  ExploreViewController.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import Foundation
import UIKit
import AVFoundation

class ExploreVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private var collectionView: UICollectionView = {
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .absolute(200), heightDimension: .absolute(55)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading
        )
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 0)
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.32),
                heightDimension: .absolute(190)
            )
        )
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(175)
            ),
            subitems: [item]
        )
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        sectionLayout.boundarySupplementaryItems = [sectionHeader]
        sectionLayout.orthogonalScrollingBehavior = .continuous
        
        let layout = UICollectionViewCompositionalLayout(section: sectionLayout)
        
        layout.configuration.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        collectionView.register(CategorySectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategorySectionReusableView.identifier)
        collectionView.register(ChallengeCollectionViewCell.self, forCellWithReuseIdentifier: ChallengeCollectionViewCell.identifier)
        return collectionView
    }()
    
    private var currentViralIndex = 0
    private var sections = [(String, [(ChallengeViewModel, ChallengeVideoViewModel)])]()
    
    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        view.backgroundColor = UIColor(named: "Black")
        
        navigationController?.navigationBar.isHidden = false
        
        let categories:[ChallengeModel.Categories] = [.xyChallenges, .karmaChallenges, .playerChallenges]
        
        for category in categories {
            
            ChallengesFirestoreManager.shared.getChallengesAndVideos(limitTo: 3, category: category) { (pairs) in
                if let pairs = pairs {
                    var viewModels = [(ChallengeViewModel, ChallengeVideoViewModel)]()
                    
                    for (model, videoModel) in pairs {
                        
                        ChallengesViewModelBuilder.buildChallengeAndVideo(from: videoModel, challengeModel: model) { (viewModelPair) in
                            if let viewModelPair = viewModelPair {
                                viewModels.append(viewModelPair)
                                
                                if viewModels.count == pairs.count {
                                    self.sections.append((category.toString(), viewModels))
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        let titleView = UIImageView(image: UIImage(named: "XYnavbarlogo"))
        navigationItem.titleView = titleView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        for cell in collectionView.visibleCells {
            if let cell = cell as? ChallengeCollectionViewCell {
                cell.stopVideo()
            }
        }
    }
    
    // MARK: - CollectionView functions
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChallengeCollectionViewCell.identifier,
            for: indexPath
        ) as? ChallengeCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(viewModel: sections[indexPath.section].1[indexPath.row].0, videoViewModel: sections[indexPath.section].1[indexPath.row].1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategorySectionReusableView.identifier,
            for: indexPath
        ) as? CategorySectionReusableView else {
            return UICollectionReusableView()
        }
        
        headerView.configure(title: sections[indexPath.section].0)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = sections[indexPath.section].1[indexPath.row].0
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        let exploreChallengeVC = ExploreChallengeViewController(challengeViewModel: viewModel)
        
        navigationController?.pushViewController(exploreChallengeVC, animated: true)
    }
}
