//
//  suggestedTableViewCell.swift
//  XY_APP
//
//  Created by Simone on 10/01/2021.
//

import UIKit

class suggestedTableViewCell: UITableViewCell, UICollectionViewDelegate {

    @IBOutlet weak var suggestedLabel: UILabel!
    @IBOutlet weak var suggestedAdviceLabel: UILabel!
    @IBOutlet weak var suggestedCollectionView: UICollectionView!
    
    var suggestedPeople: [SuggestedPics] = [
    
        SuggestedPics(momentPreview: UIImage(named: "Moments_Elon")!, profPicSuggested: UIImage(named: "elonmusk_profilepicture")!, XYnameLabel: "Elon Musk"),
        SuggestedPics(momentPreview: UIImage(named: "Moments_Elon")!, profPicSuggested: UIImage(named: "elonmusk_profilepicture")!, XYnameLabel: "Elon Musk"),
        SuggestedPics(momentPreview: UIImage(named: "Moments_Elon")!, profPicSuggested: UIImage(named: "elonmusk_profilepicture")!, XYnameLabel: "Elon Musk")
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        suggestedCollectionView.dataSource = self
        
        suggestedCollectionView.register(UINib(nibName: "suggestedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionviewsuggestedID")
        
    }
    
}


extension suggestedTableViewCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestedPeople.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionviewsuggestedID", for: indexPath) as!suggestedCollectionViewCell
        cell.suggestedPrevMoment.image = suggestedPeople[indexPath.row].momentPreview
        cell.suggestedProfPic.image = suggestedPeople[indexPath.row].profPicSuggested
       return cell
        
    }
    
    
}


struct SuggestedPics {
    var momentPreview: UIImage
    var profPicSuggested: UIImage
    var XYnameLabel: String
}
