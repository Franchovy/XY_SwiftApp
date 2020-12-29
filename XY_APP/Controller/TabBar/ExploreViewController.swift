//
//  ExploreViewController.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import Foundation
import UIKit


class ExploreViewController: UIViewController, UISearchBarDelegate {
 
   
    @IBOutlet var ExploreSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ExploreSearchBar.delegate = self
        navigationItem.titleView = ExploreSearchBar
        ExploreSearchBar.placeholder = "Search"
        
        var textFieldInsideSearchBar = ExploreSearchBar.value(forKey: "searchField") as? UITextField

        textFieldInsideSearchBar?.textColor = UIColor.white
        
        if let textFieldInsideSearchBar = self.ExploreSearchBar.value(forKey: "searchField") as? UITextField,
              let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {

                  //Magnifying glass
                  glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .gray
          }
    }
    
}



