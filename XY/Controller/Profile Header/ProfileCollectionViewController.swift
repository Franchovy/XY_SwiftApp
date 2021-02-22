//
//  ProfileCollectionViewController.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import UIKit

class ProfileCollectionViewController: UIViewController {

    
    private let collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1.0))
        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
        //2
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: fullPhotoItem,
            count: 3)
        //3
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collection.decelerationRate = UIScrollView.DecelerationRate.fast
        collection.layer.cornerRadius = 15
        
        collection.register(
            ProfileFlowCollectionViewCell.self,
            forCellWithReuseIdentifier: ProfileFlowCollectionViewCell.identifier
        )

        return collection
    }()
    
    private var postViewModels = [NewPostViewModel]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        collectionView.backgroundColor = UIColor(named: "Black")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds.inset(
            by: UIEdgeInsets(
                top: view.safeAreaInsets.top + 67,
                left: 0,
                bottom: view.safeAreaInsets.bottom,
                right: 0
            )
        )
    }
    
    public func configure(with models: [PostModel]) {
        let group = DispatchGroup()
        for postModel in models {
            group.enter()
            PostViewModelBuilder.build(from: postModel) { (postViewModel) in
                defer {
                    group.leave()
                }
                if let postViewModel = postViewModel {
                    self.postViewModels.append(postViewModel)
                }
            }
        }
        group.notify(queue: .main, work: DispatchWorkItem(block: {
            self.collectionView.reloadData()
        }))
    }
    
}


extension ProfileCollectionViewController : UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postViewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileFlowCollectionViewCell.identifier, for: indexPath) as? ProfileFlowCollectionViewCell else {
            fatalError("CollectionViewCell type unsupported")
        }
        
        cell.configure(viewModel: postViewModels[indexPath.row])
        
        cell.layer.cornerRadius = 15
        
//        cell.frame.size = CGSize(width: view.width * 1/3, height: view.width * 1/3)
        
        return cell
    }
    
    
    
}

