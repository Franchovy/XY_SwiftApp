//
//  ExploreChallengeViewController.swift
//  XY
//
//  Created by Maxime Franchot on 13/03/2021.
//

import UIKit
import AVFoundation

class ExploreChallengeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var collectionView: UICollectionView = {
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.64),
                heightDimension: .fractionalHeight(1.0)
            ),
            subitems: [item]
        )
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        
        let layout = UICollectionViewCompositionalLayout(section: sectionLayout)
        
        layout.configuration.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        collectionView.register(ChallengeVideoCollectionViewCell.self, forCellWithReuseIdentifier: ChallengeVideoCollectionViewCell.identifier)
        return collectionView
    }()
    
    private var currentViralIndex = 0
    private var viewModels = [ChallengeVideoViewModel]()
    private var challengeViewModel: ChallengeViewModel
    
    // MARK: - Initializers
    
    init(challengeViewModel: ChallengeViewModel) {
        self.challengeViewModel = challengeViewModel
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        view.backgroundColor = UIColor(named: "Black")
        
        navigationController?.navigationBar.isHidden = false
        
        ChallengesFirestoreManager.shared.getVideosForChallenge(challenge: challengeViewModel, limitTo: 5) { (videoModels) in
            if let videoModels = videoModels {
                var viewModels = [ChallengeVideoViewModel]()
                
                for videoModel in videoModels {
                    ChallengesViewModelBuilder.buildChallengeVideo(from: videoModel, challengeTitle: self.challengeViewModel.title, challengeDescription: self.challengeViewModel.description) { (viewModelPair) in
                        if let viewModelPair = viewModelPair {
                            viewModels.append(viewModelPair)

                            if viewModels.count == videoModels.count {
                                self.viewModels.append(contentsOf: viewModels)
                                self.collectionView.reloadData()
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
        
        collectionView.frame = CGRect(
            x: 0,
            y: 255,
            width: view.width,
            height: view.height/2
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChallengeVideoCollectionViewCell.identifier,
            for: indexPath
        ) as? ChallengeVideoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.row < viewModels.count {
            cell.configure(viewModel: challengeViewModel, videoViewModel: viewModels[indexPath.row], rankNumber: indexPath.row+1)
        } else {
            cell.configureEmpty(rankNumber: indexPath.row+1)
        }
        return cell
    }
}
