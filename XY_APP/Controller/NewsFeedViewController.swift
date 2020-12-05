//
//  HomeViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit


class NewsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    // Data model: These strings will be the data for the table view cells
    var posts: [PostModel] = []
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 5
    
    // don't forget to hook this up from the storyboard
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var createPostTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Get posts from backend
        getPosts()
                        
        // Remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Along with auto layout, these are the keys for enabling variable cell height
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func submitPostButtonPressed(_ sender: Any) {
        if let text = self.createPostTextField.text {
            let newPost = PostModel(username: "user", content: text)
            newPost.submitPost(completion: {result in
                switch result {
                case .success:
                    // Refresh posts feed
                    self.getPosts()
                case .failure:
                    print("Error submitting post")
                }
            })
        }
    }
    
    func getPosts() {
        // Clear current posts in feed
        posts.removeAll()
        tableView.reloadData()
        
        // Get posts from backend
        PostModel.getAllPosts(completion: { result in
            switch result {
            case .success(let newposts):
                if let newposts = newposts {
                    self.posts.append(contentsOf: newposts)
                }
                self.tableView.reloadData()
            case .failure(let error):
                print("Failed to get posts! \(error)")
            }
        })
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:MyCustomCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MyCustomCell
        
        // set the text from the data model
        cell.nameLabel.text = self.posts[indexPath.row].username
        cell.contentLabel.text = self.posts[indexPath.row].content
        cell.contentLabel.numberOfLines = 0
        
        // add border and color
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageManager = ImageManager()
        //let uploadPicture = UIImage(named: "LogoXY")
        //if let imageData = uploadPicture?.pngData() {
        //    imageManager.uploadImage(data: imageData) { (imageResponse) in
        //        print("Received upload image response!!!")
        //    }
        //}
        
        // get image test
        let imageID = "57847d61-8212-4242-842c-898f85b18bb3"
        imageManager.downloadImage(imageID: imageID, completion: {result in
            if let result = result {
                print("Result from request: ", result)
                let imageData = result.imageData
                
                if let base64Decoded = Data(base64Encoded: imageData, options: Data.Base64DecodingOptions(rawValue: 0)) {
                        // Convert back to a string
                        print("Decoded: \(base64Decoded)")
                        
                        let img = UIImageView(image: UIImage(data: base64Decoded))
                        tableView.addSubview(img)
                    }
                
            }
        })
        
        //let image = UIImageView(image: UIImage(named: "J2NTP9Er4Ad3kRsms7XRoD"))
        
        //tableView.setNeedsLayout()

    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

class MyCustomCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
        
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}

class ButtonCell: UITableViewCell {
    @IBOutlet weak var createPostButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}
