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
