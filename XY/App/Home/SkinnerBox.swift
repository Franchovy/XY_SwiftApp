//
//  SkinnerBox.swift
//  XY
//
//  Created by Maxime Franchot on 04/05/2021.
//

import UIKit

class SkinnerBox: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 250, height: 142)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 50)
        
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
        return SkinnerBoxManager.shared.uncompletedTaskDescriptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkinnerBoxCollectionViewCell.identifier, for: indexPath) as! SkinnerBoxCollectionViewCell
        
        cell.configure(
            title: SkinnerBoxManager.shared.getTask(number: indexPath.row).0,
            image: SkinnerBoxManager.shared.getTask(number: indexPath.row).1,
            description: SkinnerBoxManager.shared.getTask(number: indexPath.row).2
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let taskNumber = indexPath.row
        
        if taskNumber < SkinnerBoxManager.shared.taskNumber {
            scrollToItem(
                at: IndexPath(row: SkinnerBoxManager.shared.taskNumber, section: 0),
                at: .left,
                animated: true
            )
        } else if taskNumber > SkinnerBoxManager.shared.taskNumber {
            scrollToItem(
                at: IndexPath(row: 0, section: 0),
                at: .left,
                animated: true
            )
        } else {
            SkinnerBoxManager.shared.pressedTask(taskNumber: taskNumber)
        }
    }
    
}
