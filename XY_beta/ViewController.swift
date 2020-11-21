//
//  ViewController.swift
//  XY_beta
//
//  Created by Maxime Franchot on 21/11/2020.
//

import UIKit

<<<<<<< HEAD
struct ViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewController>) -> ViewController.UIViewControllerType {
        
       
    
        
        let storyboard = UIStoryboard(name: "Main",bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "Home")
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ViewController.UIViewControllerType, context: UIViewControllerRepresentableContext<ViewController>) {
        
=======
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
>>>>>>> main
    }


}

<<<<<<< HEAD

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
=======
>>>>>>> main
