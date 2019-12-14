//
//  ViewController.swift
//  CropView
//
//  Created by Ahmed Khalaf on 12/14/19.
//  Copyright © 2019 Ahmed Khalaf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var innerStackView: UIStackView!
    @IBOutlet private weak var originalImageView: UIImageView!
    @IBOutlet private weak var resultImageView: UIImageView!
    @IBOutlet private weak var cropView: CropView!
    
    @IBAction private func applyButtonTapped(_ sender: UIButton) {
        innerStackView.isHidden = true
        resultImageView.isHidden = false
        resultImageView.image = cropView.apply(to: originalImageView.image!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

