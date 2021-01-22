//
//  ProfileFlowTableViewCell.swift
//  XY_APP
//
//  Created by Simone on 09/01/2021.
//

import UIKit

class ProfileFlowTableViewCell: UITableViewCell, UICollectionViewDelegate {
    
    var postPrevCollection: [ProfilePostModel?] = []
    var posts: [PostModel] = []
    
    var ownerId: String? {
        didSet {
            fetchPosts()
        }
    }
    
    @IBOutlet weak var flowLabel: UILabel!
    @IBOutlet weak var profileCollectionView:
        UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        profileCollectionView.dataSource = self
        profileCollectionView.register(UINib(nibName: "ProfileFlowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "profileCollectionPostReusable")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInsetReference = .fromContentInset
        flowLayout.scrollDirection = .vertical
        let length = (profileCollectionView.frame.width / 3) - 5.1
        let size = CGSize(width: length, height: length)
        flowLayout.estimatedItemSize = size
        flowLayout.itemSize = size
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.profileCollectionView.collectionViewLayout = flowLayout
        
        self.profileCollectionView.showsHorizontalScrollIndicator = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fetchPosts() {
        FirebaseDownload.getFlowForProfile(userId: ownerId!) { posts, error in
            if let error = error { print("Error fetching posts for profile: \(error)") }
            
            if let posts = posts {
                for post in posts {
                    
                    let index = self.posts.count
                    self.posts.append(post)
                    
                    // Fetch image for post
                    FirebaseDownload.getImage(imageId: post.images!.first!) { image, error in
                        if let error = error { print("Error fetching image for post: \(error)")}
                        
                        if let image = image {
                            self.postImageFetched(index: index, image: image)
                        }
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        postPrevCollection = []
        posts = []
    }
    
    func postImageFetched(index: Int, image: UIImage) {
        if postPrevCollection.count == index {
            postPrevCollection.append(ProfilePostModel(imagePostPrev: image))
        } else if postPrevCollection.count > index {
            postPrevCollection[index] = ProfilePostModel(imagePostPrev: image)
        } else if postPrevCollection.count < index {
            var i = postPrevCollection.count
            while i < index {
                postPrevCollection.append(nil)
                i += 1
            }
            postPrevCollection.append(ProfilePostModel(imagePostPrev: image))
        }
        
        if !postPrevCollection.contains(where: { return $0 == nil })
            && postPrevCollection.count == posts.count {
            // Reload if all previews are loaded
            profileCollectionView.reloadData()
        }
    }

}

extension ProfileFlowTableViewCell : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCollectionPostReusable", for: indexPath) as! ProfileFlowCollectionViewCell
        
        cell.postPicPreview.image = postPrevCollection[indexPath.row]!.imagePostPrev
        
        return cell
    }
}
