//
//  ARProductInfoView.swift
//  ARKitImageRecognition
//
//  Created by Vlad Bonta on 17/11/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit

class ARProductInfoView: UIView {
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!

    
    override func awakeFromNib() {
        self.imageView.layer.masksToBounds = false
        self.imageView.layer.borderColor = UIColor.black.cgColor
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.clipsToBounds = true
    }
    
    func setup(with imageModel: ARImageModel) {
        self.indicatorView.startAnimating()
        self.indicatorView.hidesWhenStopped = true
        self.imageView.layer.borderWidth = 0
        self.indicatorView.isHidden = false
        
        self.layoutIfNeeded()
        
        if let imageURL = imageModel.infoImageURL,
            let url = URL(string: imageURL) {
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {                        
                        self.imageView.image = UIImage(data: data)
                        self.layoutIfNeeded()
                        self.indicatorView.stopAnimating()
                        self.indicatorView.isHidden = true
                    }
                }
                catch{
                    print(error)
                }
            }
        }
        textView.text = imageModel.infoImageDescription ?? ""
        titleLabel.text = imageModel.title
    }
}
