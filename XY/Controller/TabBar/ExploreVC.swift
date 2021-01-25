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
    private var nextMomentView: MomentViewController?
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
        DispatchQueue.main.async {
            self.momentView?.player?.play()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
                self.nextMomentView = MomentViewController(model: self.moments[self.currentMomentIndex])
                
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
        momentView = nil
            
        if nextMomentView == nil {
            nextMomentView = MomentViewController(model: self.moments[index])
            
            currentMomentIndex += 1
        }
        
        let momentView = nextMomentView!
        momentView.play()
        
        DispatchQueue.main.async {
            momentView.view.frame = self.view.bounds
            momentView.view.layer.cornerRadius = 15
            
            self.view.addSubview(momentView.view)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onMomentTapped))
            momentView.view.addGestureRecognizer(tapGesture)
            
            let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onSwiping(panGestureRecognizer:)))
            swipeGesture.delegate = self
            momentView.view.addGestureRecognizer(swipeGesture)
            
            self.momentView = momentView
        }
        
        // Load next moment
        let nextMomentView = MomentViewController(model: self.moments[index])
        
        self.nextMomentView = nextMomentView
        view.addSubview(nextMomentView.view)
    }
    
    @objc func onSwiping(panGestureRecognizer: UIPanGestureRecognizer) {
        let translationX = panGestureRecognizer.translation(in: view).x
        let velocityX = panGestureRecognizer.velocity(in: view).x
        
        let transform = CGAffineTransform(
            translationX: translationX,
            y: 0
        )
        
        momentView?.view.transform = transform.rotated(by: translationX / 500)
        
        // Color for swipe
        if translationX > 0 {
            momentView?.shadowLayer.shadowColor = UIColor.green.cgColor
        } else {
            momentView?.shadowLayer.shadowColor = UIColor.red.cgColor
        }
        
        momentView?.shadowLayer.shadowOpacity = Float(abs(translationX) / 50)
        
        
        // On gesture finish
        guard panGestureRecognizer.state == .ended else {
          return
        }
        
        // Animate if needed
        if translationX > 50, velocityX > 10 {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                self.momentView?.view.transform = CGAffineTransform(translationX: 700, y: 0).rotated(by: 1)
            } completion: { (done) in
                if done {
                    self.onMomentTapped()
                }
            }
        } else if translationX < -50, velocityX < -10 {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                self.momentView?.view.transform = CGAffineTransform(translationX: -700, y: 0).rotated(by: -1)
            } completion: { (done) in
                if done {
                    self.onMomentTapped()
                }
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
                self.momentView?.view.transform = CGAffineTransform(translationX: 0, y: 0).rotated(by: 0)
                self.momentView?.shadowLayer.shadowOpacity = 0
            }
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


extension ExploreVC : UIGestureRecognizerDelegate {
    
}
