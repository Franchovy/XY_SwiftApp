//
//  ExploreViewController.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import Foundation
import UIKit
import AVFoundation

class ExploreVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    private var collectionView: UICollectionView = {
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(90)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading
        )
        sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 0)
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(130),
                heightDimension: .absolute(190)
            )
        )
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(175)
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
    
    let createNewButton:GradientBorderButtonWithShadow = {
        let button = GradientBorderButtonWithShadow()
        button.setTitle("Create New", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 38)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundColor(color: .black)
        button.setGradient(Global.xyGradient)
        return button
    }()
    
    private var currentViralIndex = 0
    private var sections = [(String, [(ChallengeViewModel, ChallengeVideoViewModel)])]()
    private var categories = [ChallengeModel.Categories]()
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        for view in collectionView.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
        
        view.addSubview(collectionView)
        view.addSubview(createNewButton)
        
        createNewButton.addTarget(self, action: #selector(createNewPressed), for: .touchUpInside)
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
        
        categories = [.xyChallenges, .playerChallenges]
        
        for category in categories {
            
            ChallengesFirestoreManager.shared.getChallengesAndVideos(
                limitTo: 3,
                category: category
            ) { (pairs) in
                if let pairs = pairs {
                    var viewModels = [(ChallengeViewModel, ChallengeVideoViewModel)]()
                    
                    for (model, videoModel) in pairs {
                        
                        ChallengesViewModelBuilder.buildChallengeAndVideo(from: videoModel, challengeModel: model) { (viewModelPair) in
                            if let viewModelPair = viewModelPair {
                                viewModels.append(viewModelPair)
                                
                                if viewModels.count == pairs.count {
                                    if category == .xyChallenges {
                                        self.sections.insert((category.toString(), viewModels), at: 0)
                                    } else if category == .playerChallenges {
                                        
                                        self.sections.append(
                                            (category.toString(), viewModels)
                                        )
                                    }
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        let titleView = UIImageView(image: UIImage(named: "XYNavbarLogo"))
        navigationItem.titleView = titleView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds.inset(by: view.safeAreaInsets)
        
        createNewButton.frame = CGRect(
            x: (view.width - 259)/2,
            y: view.height - 54 - 16,
            width: 259,
            height: 54
        )
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
    
    // MARK: - Fetch handling
    
    func loadMore() {
        guard sections.count == 3, sections.last?.0 == ChallengeModel.Categories.playerChallenges.toString() else {
            return
        }
        
        ChallengesFirestoreManager.shared.getChallengesAndVideos(
            limitTo: 3,
            category: .playerChallenges
        ) { (pairs) in
            if let pairs = pairs {
                var viewModels = self.sections.last!.1
                
                for (model, videoModel) in pairs {
                    
                    ChallengesViewModelBuilder.buildChallengeAndVideo(from: videoModel, challengeModel: model) { (viewModelPair) in
                        if let viewModelPair = viewModelPair {
                            viewModels.append(viewModelPair)
                            
                            if viewModels.count == pairs.count {
                                self.sections[2] = (ChallengeModel.Categories.playerChallenges.rawValue, viewModels)
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Obj-C Functions
    
    @objc private func createNewPressed() {
        TabBarViewController.instance.selectedIndex = 2
    }
    
    // MARK: - Scroll view delegate functions
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if( scrollView.contentSize.height == 0 ) {
            return;
        }
        
        let buffer = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        let maxVisibleY = collectionView.contentOffset.y + self.collectionView.bounds.size.height
        let actualMaxY = collectionView.contentSize.height + collectionView.contentInset.bottom
        if maxVisibleY + buffer >= actualMaxY {
            loadMore()
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
        cell.delegate = self
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
        
        let category = categories[indexPath.section]
        headerView.configure(
            title: category.toString(),
            gradient: category.getGradientAdaptedToLightMode(),
            description: category.getDescription()
        )
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = sections[indexPath.section].1[indexPath.row].0
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        let vc = PlayViewController()
        vc.configure(for: viewModel)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ExploreVC : ChallengeCollectionViewCellDelegate {
    func didPressPlay(for challengeViewModel: ChallengeViewModel, videoViewModel: ChallengeVideoViewModel) {
        let exploreChallengeVC = ExploreChallengeViewController(challengeViewModel: challengeViewModel)
    
        navigationController?.pushViewController(exploreChallengeVC, animated: true)
    }
}
