//
//  ProfileViewController.swift
//  XY
//
//  Created by Maxime Franchot on 28/01/2021.
//

import UIKit



class ProfileViewController: UIViewController {
    
    let collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.3))
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
        
        collection.backgroundColor = .green
        collection.showsVerticalScrollIndicator = false
        
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        
        collectionView.register(ProfileHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView")
        
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
    }
    
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

extension ProfileViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor =  [.blue, .red, .orange, .brown, .gray, .yellow, .systemPink, .cyan][Int.random(in: 0...7)]
        cell.layer.cornerRadius = 15
        
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
        
        return headerView
    }
    
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: 100, height: 100)
    }
}
