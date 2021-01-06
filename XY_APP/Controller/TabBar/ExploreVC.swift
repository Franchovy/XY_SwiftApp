//
//  ExploreViewController.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import Foundation
import UIKit


class ExploreVC: UIViewController, UISearchBarDelegate {
 
   
    @IBOutlet weak var ExploreTableView: UITableView!
    @IBOutlet var ExploreSearchBar: UISearchBar!
    
    var challenges: [ExploreViewCellModel] = [
        
        ExploreViewCellModel(circle: "0", challengesLabel: "Challenge_1"),
        ExploreViewCellModel(circle: "0", challengesLabel: "Challenge_2"),
        ExploreViewCellModel(circle: "0", challengesLabel: "Challenge_3"),
        ExploreViewCellModel(circle: "0", challengesLabel: "Challenge_4")
    
    ]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        ExploreTableView.dataSource = self
        
        let cellNib = UINib(nibName: "ExploreTableViewCell", bundle: nil)
                self.ExploreTableView.register(cellNib, forCellReuseIdentifier: "tableviewcellid")
        
        
       
        ExploreSearchBar.delegate = self
        
        navigationItem.titleView = ExploreSearchBar
        ExploreSearchBar.placeholder = "Search"
        
        let textFieldInsideSearchBar = ExploreSearchBar.value(forKey: "searchField") as? UITextField

        textFieldInsideSearchBar?.textColor = UIColor.white
        
        if let textFieldInsideSearchBar = self.ExploreSearchBar.value(forKey: "searchField") as? UITextField,
              let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {

                  //Magnifying glass
                  glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .gray
          }
    }
    
}


extension ExploreVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challenges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcellid", for: indexPath) as! ExploreTableViewCell
        cell.Label.text = challenges[indexPath.row].challengesLabel
        return cell
    }
    
}


