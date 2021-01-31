//
//  ExploreViewController.swift
//  XY_APP
//
//  Created by Simone on 29/12/2020.
//

import Foundation
import UIKit


class ExploreVC: UIViewController {
    
    private let noViralsLeftLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "tintColor_grey")
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        label.alpha = 0.0
        label.text = "No virals left!"
        return label
    }()
    
    private let whyNotUploadLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "tintColor_grey")
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        label.alpha = 0.0
        label.text = "Why not upload one?"
        return label
    }()
    
    private var virals = [ViralModel]()
    
    private var viralView: ViralViewController?
    private var nextViralView: ViralViewController?
    private var currentViralIndex = 0
    
    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(noViralsLeftLabel)
        view.addSubview(whyNotUploadLabel)
        
        view.backgroundColor = UIColor(named: "Black")
        
        navigationController?.navigationBar.isHidden = false
                
        fetchVirals()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.viralView?.player?.play()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DispatchQueue.main.async {
            self.viralView?.player?.pause()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        noViralsLeftLabel.sizeToFit()
        noViralsLeftLabel.frame = CGRect(
            x: (view.width - noViralsLeftLabel.width)/2,
            y: view.center.y - 15,
            width: noViralsLeftLabel.width,
            height: noViralsLeftLabel.height
        )
        
        whyNotUploadLabel.sizeToFit()
        whyNotUploadLabel.frame = CGRect(
            x: (view.width - whyNotUploadLabel.width)/2,
            y: noViralsLeftLabel.bottom + 30,
            width: whyNotUploadLabel.width,
            height: whyNotUploadLabel.height
        )
    }
    
    // MARK: - Private functions
    
    private func fetchVirals() {
        FirebaseDownload.getVirals { (result) in
            switch result {
            case .success(let viralModels):
                guard viralModels.count > 0 else {
                    self.noViralsLeftLabel.isHidden = false
                    return
                }
                
                self.virals = viralModels
                
                // Load first viral
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
            nextViralView = ViralViewController(model: self.virals[currentViralIndex])
            currentViralIndex += 1
        }
        
        let viralView = nextViralView!
        viralView.play()

        
        DispatchQueue.main.async {
            
            guard self.currentViralIndex <= self.virals.count else {
                UIView.animate(withDuration: 0.4, delay: 1.0) {
                    self.noViralsLeftLabel.alpha = 1.0
                } completion: { done in
                    if done {
                        UIView.animate(withDuration: 0.4, delay: 1.0) {
                            self.whyNotUploadLabel.alpha = 1.0
                        }
                    }
                }
                
                return
            }
            
            if !self.view.subviews.contains(viralView.view) {
                self.view.addSubview(viralView.view)
                viralView.view.frame = CGRect(
                    x: 0,
                    y: self.view.safeAreaInsets.top,
                    width: self.view.width,
                    height: self.view.height - self.view.safeAreaInsets.top
                )
            } else {
                self.view.bringSubviewToFront(viralView.view)
            }
            
            let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onSwiping(panGestureRecognizer:)))
            viralView.view.addGestureRecognizer(swipeGesture)
            
            self.viralView = viralView
        }
        
        if currentViralIndex > self.virals.count-1 {
            return
        }
        
        // Load next viral
        let nextViralView = ViralViewController(model: self.virals[currentViralIndex])
        
        self.nextViralView = nextViralView
        view.insertSubview(nextViralView.view, belowSubview: viralView.view)
        nextViralView.view.frame = CGRect(
            x: 0,
            y: self.view.safeAreaInsets.top,
            width: self.view.width,
            height: self.view.height - view.safeAreaInsets.top
        )
    }
    
    private func onViralSwipedRight(viral: ViralModel) {
        FirebaseFunctionsManager.shared.swipeRight(viralId: viral.id)
        
        currentViralIndex = currentViralIndex + 1
        createViralView(index: currentViralIndex)
    }
    
    private func onViralSwipedLeft(viral: ViralModel) {
        FirebaseFunctionsManager.shared.swipeLeft(viralId: viral.id)
        
        currentViralIndex = currentViralIndex + 1
        createViralView(index: currentViralIndex)
    }
    
    // MARK: - Objc / Gesture recognizers
    
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
        guard panGestureRecognizer.state == .ended, let viralView = self.viralView else {
          return
        }
        
        // Animate if needed
        if translationX > 50, velocityX > 10 {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                viralView.view.transform = CGAffineTransform(translationX: 700, y: 0).rotated(by: 1)
            } completion: { (done) in
                if done {
                    self.onViralSwipedRight(viral: viralView.model)
                }
            }
        } else if translationX < -50, velocityX < -10 {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                viralView.view.transform = CGAffineTransform(translationX: -700, y: 0).rotated(by: -1)
            } completion: { (done) in
                if done {
                    self.onViralSwipedLeft(viral: viralView.model)
                }
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
                viralView.view.transform = CGAffineTransform(translationX: 0, y: 0).rotated(by: 0)
                viralView.shadowLayer.shadowOpacity = 0
            }
        }
    }
}
