//
//  PreviewViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit
import AVFoundation

class PreviewViewController: UIViewController {
    
    let videoView = VideoPlayerView()
    let previewVideoURL: URL

    init(previewVideoURL: URL) {
        self.previewVideoURL = previewVideoURL
        
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(videoView)
        
        videoView.setUpVideo(videoURL: previewVideoURL, withRate: 1.0, audioEnable: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureBackButton(.xmark)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoView.frame = view.bounds
    }
    
    @objc private func didTapNext() {
        if CreateChallengeManager.shared.title != nil && CreateChallengeManager.shared.description != nil {
            let vc = SendChallengeViewController()
            
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = CreateChallengeDescriptionViewController()
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
