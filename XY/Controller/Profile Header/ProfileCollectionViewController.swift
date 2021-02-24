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
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: fullPhotoItem,
            count: 3)
        
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
    
    private var configured = false
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
        guard configured == false else {
            return
        }
        
        postViewModels = []
        
        for postModel in models {
            let loadingViewModel = PostViewModelBuilder.build(from: postModel) { (postViewModel) in

                if let postViewModel = postViewModel {
                    let index = self.postViewModels.firstIndex(where: { $0.id == postViewModel.id })!
                    self.postViewModels[index] = postViewModel
                    self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                    
                }
            }
            self.postViewModels.append(loadingViewModel)
        }
        
        self.collectionView.reloadData()
        configured = true
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ProfileFlowCollectionViewCell else {
            return
        }
        
        let originalTransform = cell.transform
        let shrinkTransform = cell.transform.scaledBy(x: 0.95, y: 0.95)
        
        UIView.animate(withDuration: 0.2) {
            cell.transform = shrinkTransform
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.2) {
                    cell.transform = originalTransform
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            cell.heroID = "post"
            
            let vc = PostViewController()
            vc.configure(with: self.postViewModels[indexPath.row])
            vc.isHeroEnabled = true
            
            vc.onDismiss = { cell.heroID = "" }
            
            vc.setHeroIDs(forPost: "post", forCaption: "", forImage: "")
            
            self.navigationController?.isHeroEnabled = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

