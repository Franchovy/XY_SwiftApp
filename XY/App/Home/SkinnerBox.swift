//
//  SkinnerBox.swift
//  XY
//
//  Created by Maxime Franchot on 04/05/2021.
//

import UIKit

class SkinnerBox: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var cellData = [
        ("Profile Image", UIImage(systemName: "eyes")!, "Add a profile image for friends to see you"),
        ("Find Friends", UIImage(systemName: "eyes")!, "Find at least one friend to start a challenge")
    ]
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 250, height: 142)
        layout.scrollDirection = .horizontal
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        showsHorizontalScrollIndicator = false
        
        backgroundColor = .clear
        
        delegate = self
        dataSource = self
        
        register(SkinnerBoxCollectionViewCell.self, forCellWithReuseIdentifier: SkinnerBoxCollectionViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkinnerBoxCollectionViewCell.identifier, for: indexPath) as! SkinnerBoxCollectionViewCell
        
        cell.configure(
            title: cellData[indexPath.row].0,
            image: cellData[indexPath.row].1,
            description: cellData[indexPath.row].2
        )
        
        return cell
    }
    

}
