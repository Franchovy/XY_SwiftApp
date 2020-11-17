//
//  ViewController.swift
//  XY_beta
//
//  Created by Maxime Franchot on 17/11/2020.
//

import Foundation
import SwiftUI
import UIKit

struct SwiftUIViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SwiftUIViewController>) -> SwiftUIViewController.UIViewControllerType {
        
        let storyboard = UIStoryboard(name: "Main",bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "Home")
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SwiftUIViewController.UIViewControllerType, context: UIViewControllerRepresentableContext<SwiftUIViewController>) {
        
    }
    
}

class ViewController: UIViewController {

    let label:UILabel = {
        let label = UILabel()
        label.text = "Hello World"
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textColor = .systemBlue
        label.contentMode = .center
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
    }
    
}
