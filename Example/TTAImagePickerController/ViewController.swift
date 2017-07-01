//
//  ViewController.swift
//  TTAImagePickerController
//
//  Created by TMTBO on 05/03/2017.
//  Copyright (c) 2017 TMTBO. All rights reserved.
//

import UIKit
import TTAImagePickerController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didClickShowImagePickerButton(_ sender: UIButton) {
        let imagePicker = TTAImagePickerController(selectedAsset: [TTAAsset]())
        imagePicker.selectItemTintColor = .red
        present(imagePicker, animated: true, completion: nil)
    }
    
}

