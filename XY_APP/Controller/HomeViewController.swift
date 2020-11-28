//
//  HomeViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Data model: These strings will be the data for the table view cells
    let animalsName: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    let animals: [String] = [
            "Ten horses:  horse horse horse horse horse horse horse horse horse horse ",
            "Three cows:  cow, cow, cow",
            "One camel:  camel",
            "Ninety-nine sheep:  sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep baaaa sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep sheep",
            "Thirty goats:  goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat goat "]
    
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Along with auto layout, these are the keys for enabling variable cell height
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.animals.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:MyCustomCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MyCustomCell
        
        // set the text from the data model
        cell.nameLabel.text = self.animalsName[indexPath.row]
        cell.contentLabel.text = self.animals[indexPath.row]
        cell.contentLabel.numberOfLines = 0
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}


class MyCustomCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
}

class ViewTableCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

