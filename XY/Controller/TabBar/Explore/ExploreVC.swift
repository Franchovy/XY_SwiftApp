//
//  ExploreViewController.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import Foundation
import UIKit
import AVFoundation

class ExploreVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 1.6
        layout.minimumLineSpacing = 1.2
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(CategorySectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategorySectionReusableView.identifier)
        collectionView.register(_ChallengeCollectionViewCell.self, forCellWithReuseIdentifier: _ChallengeCollectionViewCell.identifier)
        return collectionView
    }()
    
    let createNewButton:GradientBorderButtonWithShadow = {
        let button = GradientBorderButtonWithShadow()
        button.setTitle("Create New", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 38)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundColor(color: .black)
        button.setGradient(Global.xyGradient)
        button.alpha = 0.8
        return button
    }()
    
    private var currentViralIndex = 0
    private var sections = [(String, [(ChallengeViewModel, ChallengeVideoViewModel)?])]()
    private var categories = [ChallengeModel.Categories]()
    private var models = [(ChallengeModel, ChallengeVideoModel)]()
    
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)

        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        
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
        
//        for category in categories {
        if let category = categories.last {
            ChallengesFirestoreManager.shared.getChallengesAndVideos(
                category: category
            ) { (pairs) in
                if let pairs = pairs {
                    self.models = pairs
                    
                    self.sections.append(("Player Challenges", [(ChallengeViewModel, ChallengeVideoViewModel)?](repeating: nil, count: pairs.count)))
                    self.collectionView.reloadData()
                }
            }
        }
        
        let titleView = UIImageView(image: UIImage(named: "XYNavbarLogo"))
        
        let tripleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tripleTapDebugOp(_:)))
        tripleTapGesture.numberOfTapsRequired = 3
        titleView.addGestureRecognizer(tripleTapGesture)
        titleView.isUserInteractionEnabled = true
        navigationItem.titleView = titleView
        
    }
    
    // DEBUG STUFF
    @objc private func tripleTapDebugOp(_ gestureRecognizer: UIGestureRecognizer) {
        if let view = gestureRecognizer.view {
            UIView.animate(withDuration: 0.3) {
                view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } completion: { (done) in
                if done {
                    UIView.animate(withDuration: 0.3) {
                        view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }
                }
            }
        }
        
        UserDefaults.standard.setValue(nil, forKey: "introMessageSeen")
    
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
        navigationController?.navigationBar.isTranslucent = false

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        for cell in collectionView.visibleCells {
            if let cell = cell as? _ChallengeCollectionViewCell {
                cell.stopVideo()
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
//            loadMore()
        }
    }
    
    // MARK: - CollectionView functions
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 //sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].1.count //sections[section].1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: _ChallengeCollectionViewCell.identifier,
            for: indexPath
        ) as? _ChallengeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        
        if let pair = sections[indexPath.section].1[indexPath.row] {
            cell.configure(viewModel: pair.0, videoViewModel: pair.1)
        } else {
            fetchForItem(at: indexPath)
        }
        
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
        
        guard let pair = sections[indexPath.section].1[indexPath.row], let cell = collectionView.cellForItem(at: indexPath) as? _ChallengeCollectionViewCell else {
            return
        }
        
        let vc = WatchViewController(for: pair.0)
        vc.setFirstVideo(pair.1, heroID: "vid")
        isHeroEnabled = true
        cell.isHeroEnabled = true
        cell.heroID = "vid"
        
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            fetchForItem(at: indexPath)
        }
    }
    
    func fetchForItem(at indexPath: IndexPath) {
        
        var pair = models[indexPath.row]
        
        ChallengesViewModelBuilder.buildChallengeAndVideo(from: pair.1, challengeModel: pair.0) { (viewModelPair) in
            if let viewModelPair = viewModelPair {
                self.sections[indexPath.section].1[indexPath.row] = viewModelPair
                
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSize = view.width / 3 - 1.6
        return CGSize(width: horizontalSize, height: horizontalSize * 1.626)
    }
}

extension ExploreVC : ChallengeCollectionViewCellDelegate {
    func didPressPlay(for challengeViewModel: ChallengeViewModel, videoViewModel: ChallengeVideoViewModel) {
        let exploreChallengeVC = ExploreChallengeViewController(challengeViewModel: challengeViewModel)
    
        navigationController?.pushViewController(exploreChallengeVC, animated: true)
    }
}
