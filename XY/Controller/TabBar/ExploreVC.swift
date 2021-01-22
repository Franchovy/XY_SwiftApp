//
//  ExploreViewController.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import Foundation
import UIKit


class ExploreVC: UIViewController {
 
   
    @IBOutlet weak var ExploreTableView: UITableView!
  
    
    
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

        let cameraButton = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(openCamera))
        navigationItem.rightBarButtonItem = cameraButton
    }
    
    @objc func openCamera() {
        let cameraVC = CameraViewController()
        cameraVC.modalPresentationStyle = .fullScreen
        present(cameraVC, animated: true, completion: {})
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


