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
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 25)
        label.textColor = UIColor(named: "XYTint")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let createdByLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 15)
        label.textColor = UIColor(named: "XYTint")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let playButton: GradientBorderButtonWithShadow = {
        let button = GradientBorderButtonWithShadow()
        button.setTitle("Play", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 33)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundColor(color: .black)
        button.setGradient(Global.xyGradient)
        return button
    }()
    
    private let timerIcon = TimerIcon(labelText: "1 Min")
    
    private var currentViralIndex = 0
    private var viewModels = [ChallengeVideoViewModel]()
    private var challengeViewModel: ChallengeViewModel
    
    // MARK: - Initializers
    
    init(challengeViewModel: ChallengeViewModel) {
        self.challengeViewModel = challengeViewModel
        
        super.init(nibName: nil, bundle: nil)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        createdByLabel.text = "Created by:\n @\(challengeViewModel.creator.nickname)"
        descriptionLabel.text = challengeViewModel.description
        
        view.addSubview(timerIcon)
        view.addSubview(descriptionLabel)
        view.addSubview(collectionView)
        view.addSubview(playButton)
        view.addSubview(createdByLabel)
        
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        view.backgroundColor = UIColor(named: "Black")
        let gradientLabel = GradientLabel(text: challengeViewModel.title, fontSize: 26, gradientColours: challengeViewModel.category.getGradientAdaptedToLightMode())
        gradientLabel.sizeToFit()
        navigationItem.titleView = gradientLabel
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let text = descriptionLabel.text {
            let boundingSize = CGSize(width: view.width - 30, height: .greatestFiniteMagnitude)
            let textRect = text.boundingRect(
                with: boundingSize,
                options: .usesLineFragmentOrigin,
                attributes: [.font : descriptionLabel.font],
                context: nil
            )
            
            descriptionLabel.frame = CGRect(
                x: 15,
                y: view.safeAreaInsets.top + 87 - textRect.height,
                width: view.width - 30,
                height: textRect.height
            )
        }
        
        createdByLabel.sizeToFit()
        createdByLabel.frame = CGRect(
            x: 0,
            y: descriptionLabel.bottom + 15,
            width: view.width,
            height: 60
        )
        
        let timerIconSize:CGFloat = 56.94
        timerIcon.frame = CGRect(
            x: (view.width - timerIconSize)/2,
            y: view.safeAreaInsets.top + 87,
            width: timerIconSize,
            height: timerIconSize
        )
        
        collectionView.frame = CGRect(
            x: 0,
            y: 255,
            width: view.width,
            height: view.height/2
        )
        
        let playButtonSize = CGSize(width: 131.86, height: 47.17)
        playButton.frame = CGRect(
            x: (view.width - playButtonSize.width)/2,
            y: view.height - playButtonSize.height - 32,
            width: playButtonSize.width,
            height: playButtonSize.height
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
            cell.configure(viewModel: challengeViewModel, videoViewModel: viewModels[indexPath.row])
        } else {
            cell.configureEmpty()
        }
        return cell
    }
    
    @objc private func didTapPlay() {
        TabBarViewController.instance.startChallenge(challenge: challengeViewModel)
    }
}
