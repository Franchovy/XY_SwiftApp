//
//  FriendsViewController.swift
//  XY_APP
//
//  Created by Simone on 07/12/2020.
//

import Foundation
import UIKit

class XYworldVC: UIViewController, UISearchBarDelegate {
    
    
    @IBOutlet var xyworldSearchBar: UISearchBar!
    @IBOutlet var xyworldTableView: UITableView!
    
    var onlineFriends: [OnlineFriendsModel] = [
        
        OnlineFriendsModel(label: "Online Now")
    ]
    
    var suggestedPeople: [SuggestedTableViewModel] = [
        
        SuggestedTableViewModel(suggested: "Suggested", suggestedTip: "Tap the profile image to follow new people")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        xyworldTableView.dataSource = self
        
        let cellNib = UINib(nibName: "OnlineFriendsTableViewCell", bundle: nil)
        self.xyworldTableView.register(cellNib, forCellReuseIdentifier: "tableviewcellidOnline")
        
        xyworldTableView.register(UINib(nibName: "suggestedTableViewCell", bundle: nil), forCellReuseIdentifier: "tableviewsuggestedID")
        
        // Search bar
        xyworldSearchBar.delegate = self
        navigationItem.titleView = xyworldSearchBar
        xyworldSearchBar.placeholder = "Search"
        
        let textFieldInsideSearchBar = xyworldSearchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        if let textFieldInsideSearchBar = self.xyworldSearchBar.value(forKey: "searchField") as? UITextField,
           let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
            
            //Magnifying glass
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .gray
            
            
        }
        
    }
    
}

extension XYworldVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + suggestedPeople.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcellidOnline", for: indexPath) as! OnlineFriendsTableViewCell
            cell.onlineFriendsLabel.text = onlineFriends[indexPath.row].label
            return cell
            
        } else {
            
            let suggested = suggestedPeople[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewsuggestedID", for: indexPath) as! suggestedTableViewCell
            return cell
        }
        
    }
    
    
    struct SuggestedTableViewModel {
        
        var suggested: String
        var suggestedTip: String
        
    }
}
