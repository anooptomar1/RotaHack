//
//  RHSplashViewController.swift
//  ARKitImageRecognition
//
//  Created by Vlad Bonta on 17/11/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit

class RHSplashViewController: UIViewController {
    
    @IBOutlet weak private var phoneImageView: UIImageView!
    @IBOutlet weak private var arImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let translate = CGAffineTransform(translationX: 0, y: -300)
        self.arImageView.transform = translate
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
            let translate = CGAffineTransform(translationX: 0, y: 0)
            let scale = CGAffineTransform(scaleX: 1.4, y: 1.4)
            
            self.arImageView.transform = translate.concatenating(scale)
        }) { _ in
            self.performSegue(withIdentifier: "StartAR", sender: nil)
        }
        
    }
}
