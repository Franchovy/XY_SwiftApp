//
//  SearchBar.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

class SearchBar: UISearchBar {

    init() {
        super.init(frame: .zero)
        
        setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        barTintColor = UIColor(named: "XYBackground")
        isTranslucent = false
        placeholder = "Search"
        searchTextField.font = UIFont(name: "Raleway-Heavy", size: 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
