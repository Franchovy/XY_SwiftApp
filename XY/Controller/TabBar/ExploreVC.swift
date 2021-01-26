//
//  ExploreViewController.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import Foundation
import UIKit


class ExploreVC: UIViewController {
    
    var virals = [ViralModel]()
    
    private var viralView: ViralViewController?
    private var nextViralView: ViralViewController?
    private var currentViralIndex = 0
    
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
        
        fetchVirals()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.viralView?.player?.play()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.viralView?.player?.pause()
        }
    }
    
    override func viewDidLayoutSubviews() {
        guard let viralView = viralView else {
            return
        }
    }
    
    private func fetchVirals() {
        FirebaseDownload.getVirals { (result) in
            switch result {
            case .success(let viralModels):
                self.virals = viralModels
                
                // Load first viral
                self.nextViralView = ViralViewController(model: self.virals[self.currentViralIndex])
                
                self.createViralView(index: 0)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func createViralView(index: Int) {
        if let viralView = viralView {
            // Remove previous viral view
            viralView.player?.pause()
            viralView.view.removeFromSuperview()
            viralView.removeFromParent()
        }
        viralView = nil
            
        if nextViralView == nil {
            nextViralView = ViralViewController(model: self.virals[index])
            
            currentViralIndex += 1
        }
        
        let viralView = nextViralView!
        viralView.play()
        
        DispatchQueue.main.async {
            viralView.view.frame = self.view.bounds
            viralView.view.layer.cornerRadius = 15
            
            self.view.addSubview(viralView.view)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onViralTapped))
            viralView.view.addGestureRecognizer(tapGesture)
            
            let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onSwiping(panGestureRecognizer:)))
            swipeGesture.delegate = self
            viralView.view.addGestureRecognizer(swipeGesture)
            
            self.viralView = viralView
        }
        
        // Load next viral
        let nextViralView = ViralViewController(model: self.virals[index])
        
        self.nextViralView = nextViralView
        view.addSubview(nextViralView.view)
    }
    
    @objc func onSwiping(panGestureRecognizer: UIPanGestureRecognizer) {
        let translationX = panGestureRecognizer.translation(in: view).x
        let velocityX = panGestureRecognizer.velocity(in: view).x
        
        let transform = CGAffineTransform(
            translationX: translationX,
            y: 0
        )
        
        viralView?.view.transform = transform.rotated(by: translationX / 500)
        
        // Color for swipe
        if translationX > 0 {
            viralView?.shadowLayer.shadowColor = UIColor.green.cgColor
        } else {
            viralView?.shadowLayer.shadowColor = UIColor.red.cgColor
        }
        
        viralView?.shadowLayer.shadowOpacity = Float(abs(translationX) / 50)
        
        
        // On gesture finish
        guard panGestureRecognizer.state == .ended else {
          return
        }
        
        // Animate if needed
        if translationX > 50, velocityX > 10 {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                self.viralView?.view.transform = CGAffineTransform(translationX: 700, y: 0).rotated(by: 1)
            } completion: { (done) in
                if done {
                    self.onViralTapped()
                }
            }
        } else if translationX < -50, velocityX < -10 {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                self.viralView?.view.transform = CGAffineTransform(translationX: -700, y: 0).rotated(by: -1)
            } completion: { (done) in
                if done {
                    self.onViralTapped()
                }
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
                self.viralView?.view.transform = CGAffineTransform(translationX: 0, y: 0).rotated(by: 0)
                self.viralView?.shadowLayer.shadowOpacity = 0
            }
        }
    }
    
    
    @objc func onViralTapped() {
        currentViralIndex = (currentViralIndex + 1) % virals.count
        // Load new viral
        createViralView(index: currentViralIndex)
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
