//
//  ProfileViewController.swift
//  XY
//
//  Created by Maxime Franchot on 28/01/2021.
//

import UIKit



class ProfileViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalWidth(605 / 375))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collection
    }()

    private var profileHeaderViewModel: ProfileViewModel?
    private var postViewModels = [PostViewModel]()
    
    // MARK: - Lifecycle
    
//    init(profileId: String) {
//        self?.profileHeaderViewModel = ProfileViewModel(profileId: profileId, userId: nil)
//
//        FirebaseDownload.getFlowForProfile(userId: userId) { [weak self] (postModels, error) in
//            if let eror = error {
//                print("Error fetching posts for profile!")
//            }
//
//            if let postModels = postModels {
//                for postModel in postModels {
//                    // Configure ViewModel
//                    self?.postViewModels.append(PostViewModel(from: postModel))
//                }
//                self?.collectionView.reloadData()
//            }
//        }
//    }
    
    init(userId: String) {
        super.init(nibName: nil, bundle: nil)
        
        // Fetch Profile Data
        ProfileManager.shared.fetchProfile(userId: userId) { [weak self] (result) in
            switch result {
            case .success(let model):
                // Configure ViewModel ( & Triggers fetch)
                self?.profileHeaderViewModel = ProfileViewModel(profileId: model.profileId, userId: userId)
                
                guard let strongSelf = self, let profileHeader = strongSelf.collectionView.supplementaryView(
                    forElementKind: UICollectionView.elementKindSectionHeader,
                    at: IndexPath(row: 0, section: 0)
                ) as? ProfileHeaderReusableView else {
                    return
                }
                
                profileHeader.configure(with: strongSelf.profileHeaderViewModel!)
                strongSelf.profileHeaderViewModel?.delegate = profileHeader
                
            case .failure(let error):
                print("Error fetching profile for user: \(userId)")
                print(error)
                return
            }
        }
        
        // Fetch Posts for this user
        FirebaseDownload.getFlowForProfile(userId: userId) { [weak self] (postModels, error) in
            if let eror = error {
                print("Error fetching posts for profile!")
            }
            
            if let postModels = postModels {
                for postModel in postModels {
                    // Configure ViewModel
                    self?.postViewModels.append(PostViewModel(from: postModel))
                }
                self?.collectionView.reloadData()
            }
        }
        
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print(error ?? "Error fetching xyname for userId: \(userId)")
                return
            }
            
            if let data = snapshot.data(), let xyname = data[FirebaseKeys.UserKeys.xyname] as? String {
                self.profileHeaderViewModel?.xyname = xyname
                
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            ProfileFlowCollectionViewCell.self,
            forCellWithReuseIdentifier: ProfileFlowCollectionViewCell.identifier
        )
        
        collectionView.register(
            ProfileHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "headerView"
        )
        
        view.addSubview(collectionView)
        
        view.backgroundColor = UIColor(named: "Black")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.height
        )
        
//        print("Bottom: \(collectionView.bottom)")
        view.frame.size.height = min(collectionView.bottom, 1081)
        
    }
    
    // MARK: - Private functions
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - CollectionView Extension

extension ProfileViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postViewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileFlowCollectionViewCell.identifier, for: indexPath) as? ProfileFlowCollectionViewCell else {
            fatalError("CollectionViewCell type unsupported")
        }
        
        cell.configure(viewModel: postViewModels[indexPath.row])
        
        cell.layer.cornerRadius = 15
        
        cell.frame.size = CGSize(width: view.width * 1/3, height: view.width * 1/3)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader, let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath) as? ProfileHeaderReusableView else {
            fatalError()
        }
        
        
        let aspectRatio: CGFloat = 605 / 375
        headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.width * aspectRatio
        )
        
        guard let profileHeaderViewModel = profileHeaderViewModel else {
            return headerView
        }
        
        headerView.configure(with: profileHeaderViewModel)
        profileHeaderViewModel.delegate = headerView
        
        return headerView
    }
    
}

//MARK: - DelegateFlowLayout Extension

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: 100, height: 100)
    }
}
