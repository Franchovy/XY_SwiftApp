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
    
    private let xyWorldComingLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "tintColor_grey")
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        label.alpha = 0.0
        label.text = "XY World Coming Soon"
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "tintColor_grey")
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        label.alpha = 0.0
        label.text = "02/05/2021"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(xyWorldComingLabel)
        view.addSubview(dateLabel)
        
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
        
        let tappedAnywhereGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedAnywhereGesture))
        view.addGestureRecognizer(tappedAnywhereGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        xyWorldComingLabel.sizeToFit()
        xyWorldComingLabel.frame = CGRect(
            x: (view.width - xyWorldComingLabel.width)/2,
            y: view.center.y - 70,
            width: xyWorldComingLabel.width,
            height: xyWorldComingLabel.height
        )
        
        dateLabel.sizeToFit()
        dateLabel.frame = CGRect(
            x: (view.width - dateLabel.width)/2,
            y: xyWorldComingLabel.bottom + 20,
            width: dateLabel.width,
            height: dateLabel.height
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 20) {
            self.xyWorldComingLabel.alpha = 1.0
        }
        
        UIView.animate(withDuration: 20, delay: 10) {
            self.dateLabel.alpha = 0.3
        }
    }
    
    @objc private func tappedAnywhereGesture() {
        xyworldSearchBar.resignFirstResponder()
    }
    
}
