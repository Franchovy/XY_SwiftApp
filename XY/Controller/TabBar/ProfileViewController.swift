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
        
        collection.decelerationRate = UIScrollView.DecelerationRate.fast
        
        return collection
    }()

    private var profileHeaderViewModel: ProfileViewModel?
    private var postViewModels = [PostViewModel]()
    
    private lazy var profileHeaderScrollHeight: CGFloat? = {
        guard let profileHeader = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(row: 0, section: 0)
        ) as? ProfileHeaderReusableView else {
            return nil
        }
        
        return profileHeader.getScrollPosition() - 70 - view.safeAreaInsets.top
    }()
    
    // MARK: - Lifecycle
    
    init(userId: String) {
        super.init(nibName: nil, bundle: nil)
        
        var tempLvlStore: Int? = nil
        var tempXPStore: Int? = nil
        
        // Fetch Profile Data
        ProfileManager.shared.fetchProfile(userId: userId) { [weak self] (result) in
            switch result {
            case .success(let model):
                // Configure ViewModel ( & Triggers fetch)
                self?.profileHeaderViewModel = ProfileViewModel(profileId: model.profileId, userId: userId)
                
                if let xp = tempXPStore, let level = tempLvlStore {
                    // Send initial xp update
                    self?.profileHeaderViewModel?.updateXP(XPModel(type: .user, xp: xp, level: level))
                }
                
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
        
        // Fetch data from user document
        FirestoreReferenceManager.root.collection(FirebaseKeys.CollectionPath.users).document(userId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print(error ?? "Error fetching xyname for userId: \(userId)")
                return
            }
            
            if let data = snapshot.data() {
                // Fetch XYName
                if let xyname = data[FirebaseKeys.UserKeys.xyname] as? String {
                    self.profileHeaderViewModel?.xyname = xyname
                }
                // Fetch initial level & xp
                if let xp = data[FirebaseKeys.UserKeys.xp] as? Int, let level = data[FirebaseKeys.UserKeys.level] as? Int {
                    let xpModel = XPModel(type: .user, xp: xp, level: level)
                    
                    self.profileHeaderViewModel?.updateXP(xpModel)
                    
                    guard let profileHeader = self.collectionView.supplementaryView(
                        forElementKind: UICollectionView.elementKindSectionHeader,
                        at: IndexPath(row: 0, section: 0)
                    ) as? ProfileHeaderReusableView else {
                        tempLvlStore = level
                        tempXPStore = xp
                        return
                    }
                    
                    profileHeader.onXpUpdate(xpModel)
                }
            }
        }
        
        // Register for XP Updates
        FirebaseSubscriptionManager.shared.registerXPUpdates(for: userId, ofType: .user) { [weak self] (xpModel) in
            self?.profileHeaderViewModel?.updateXP(xpModel)
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
        
        additionalSafeAreaInsets.top = .zero
//        edgesForExtendedLayout = .top
        
//        collectionView.register(ProfileScrollerReusableView.self, forCellWithReuseIdentifier: ProfileScrollerReusableView.identifier)
        
        collectionView.register(
            ProfileScrollerReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileScrollerReusableView.identifier
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
    
    var previousScrollY:CGFloat = 0.0
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let scrollY = scrollView.contentOffset.y

        guard let scrollToPos = profileHeaderScrollHeight else {
            return
        }
        
        if scrollY < 480 {
            if scrollY < previousScrollY {
                // Scroll up
                scrollView.scrollRectToVisible(
                    CGRect(
                        x: 0,
                        y: 0,
                        width: view.width,
                        height: view.height
                    ), animated: true)
            } else {
                // Scroll down
                scrollView.scrollRectToVisible(
                    CGRect(
                        x: 0,
                        y: scrollToPos,
                        width: view.width,
                        height: view.height
                    ), animated: true)
            }
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let scrollY = scrollView.contentOffset.y

        guard let scrollToPos = profileHeaderScrollHeight else {
            return
        }
        
        if scrollY < 480 {
            if scrollY < previousScrollY {
                // Scroll up
                scrollView.scrollRectToVisible(
                    CGRect(
                        x: 0,
                        y: 0,
                        width: view.width,
                        height: view.height
                    ), animated: true)
            } else {
                // Scroll down
                scrollView.scrollRectToVisible(
                    CGRect(
                        x: 0,
                        y: scrollToPos,
                        width: view.width,
                        height: view.height
                    ), animated: true)
            }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        previousScrollY = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollY = scrollView.contentOffset.y
        
        let alphaOffset = min(
            ceil(CGFloat(postViewModels.count) / 3) * (CGFloat(view.width) * 1/3),
            425
        )
        let alpha = min(CGFloat(scrollY - 25) / alphaOffset, 1.0)
        
        profileHeaderViewModel?.setOpacity(1 - alpha)
        
    }
    
    @objc private func didTapAnywhere() {
        // Send a message to header to stop editing
        guard let profileHeader = self.collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(row: 0, section: 0)
        ) as? ProfileHeaderReusableView else {
            return
        }
        
        profileHeader.endEditing(true)
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
        
        guard kind == UICollectionView.elementKindSectionHeader, let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileScrollerReusableView.identifier, for: indexPath) as? ProfileScrollerReusableView else {
            fatalError()
        }
        
        let aspectRatio: CGFloat = 605 / 375
        headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.width * aspectRatio
        )
        
        headerView.setUpNavigationBarForViewController(self)
        
        return headerView
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//        guard kind == UICollectionView.elementKindSectionHeader, let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath) as? ProfileHeaderReusableView else {
//            fatalError()
//        }
//
//
//        let aspectRatio: CGFloat = 605 / 375
//        headerView.frame = CGRect(
//            x: 0,
//            y: 0,
//            width: view.width,
//            height: view.width * aspectRatio
//        )
//
//        let tappedAnywhereExitEditingGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAnywhere))
//        headerView.isUserInteractionEnabled = true
//        headerView.addGestureRecognizer(tappedAnywhereExitEditingGesture)
//
//        guard let profileHeaderViewModel = profileHeaderViewModel else {
//            return headerView
//        }
//
//        headerView.configure(with: profileHeaderViewModel)
//        profileHeaderViewModel.delegate = headerView
//
//        return headerView
//    }
    
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
