//
//  ExploreTableViewCell.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import UIKit

class ExploreTableViewCell: UITableViewCell, UICollectionViewDelegate {
    
    var momentsRow: [ExploreViewCollectionModel] = [
        
        ExploreViewCollectionModel(previewImage: UIImage(named: "Moment_2")!),
        ExploreViewCollectionModel(previewImage: UIImage(named: "Moment_2")!),
        ExploreViewCollectionModel(previewImage: UIImage(named: "Moment_2")!),
        ExploreViewCollectionModel(previewImage: UIImage(named: "Moment_2")!)
        
    ]
    
    @IBOutlet weak var Circle: UIView!
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var ChallengesCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ChallengesCollectionView.dataSource = self
        ChallengesCollectionView.delegate = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 90, height: 125)
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.minimumInteritemSpacing = 10.0
        self.ChallengesCollectionView.collectionViewLayout = flowLayout
        self.ChallengesCollectionView.showsHorizontalScrollIndicator = false
        
        let cellNib = UINib(nibName: "ExploreCollectionViewCell", bundle: nil)
        self.ChallengesCollectionView.register(cellNib, forCellWithReuseIdentifier: "collectionviewcellid")
    }
    
}

extension ExploreTableViewCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return momentsRow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionviewcellid", for: indexPath) as! ExploreCollectionViewCell
        cell.momentsPreview.image = momentsRow[indexPath.row].previewImage
        return cell
    }
    
}
