//
//  ExploreViewController.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import Foundation
import UIKit


class ExploreVC: UIViewController {
    
    var moments = [MomentModel]()
    
    private var momentView: MomentViewController?
    private var currentMomentIndex = 0
    
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
        
        fetchMoments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.async {
            self.momentView?.player?.play()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        
        DispatchQueue.main.async {
            self.momentView?.player?.pause()
        }
    }
    
    override func viewDidLayoutSubviews() {
        guard let momentView = momentView else {
            return
        }
    }
    
    private func fetchMoments() {
        FirebaseDownload.getMoments { (result) in
            switch result {
            case .success(let momentModels):
                self.moments = momentModels
                
                // Load first moment
                self.createMomentView(index: 0)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func createMomentView(index: Int) {
        if let momentView = momentView {
            // Remove previous moment view
            momentView.player?.pause()
            momentView.view.removeFromSuperview()
            momentView.removeFromParent()
        }
        
        let momentView = MomentViewController(model: self.moments[index])
        
        DispatchQueue.main.async {
            momentView.view.frame = self.view.bounds
            self.view.addSubview(momentView.view)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onMomentTapped))
            momentView.view.addGestureRecognizer(tapGesture)
            
            self.momentView = momentView
        }
    }
    
    @objc func onMomentTapped() {
        currentMomentIndex = (currentMomentIndex + 1) % moments.count
        // Load new moment
        createMomentView(index: currentMomentIndex)
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


