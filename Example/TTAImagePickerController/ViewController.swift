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

    @IBOutlet weak var maxImageCountTextField: UITextField!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var selectedImages = [UIImage]()
    var selectedAssets = [TTAAsset]()
    override func viewDidLoad() {
        super.viewDidLoad()
        URLSession.shared.dataTask(with: URL(string: "https://www.tobyotenma.top/blog")!).resume()
    }

    @IBAction func didClickShowImagePickerButton(_ sender: UIButton) {
        let imagePicker = TTAImagePickerController(selectedAsset: selectedAssets)
        imagePicker.pickerDelegate = self
        imagePicker.maxPickerNum = Int(maxImageCountTextField.text ?? "9") ?? 9
        
//        imagePicker.selectItemTintColor = .red
//        imagePicker.barTintColor = .orange
//        imagePicker.tintColor = .cyan
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(UICollectionViewCell.self)", for: indexPath)
        cell.layer.contents = selectedImages[indexPath.item].cgImage
        cell.layer.contentsScale = UIScreen.main.scale
        cell.layer.contentsGravity = "resizeAspectFill"
        return cell
    }
}

extension ViewController: TTAImagePickerControllerDelegate {
    func imagePickerController(_ picker: TTAImagePickerController, didFinishPicking images: [UIImage], assets: [TTAAsset]) {
        print("got the images")
        selectedImages = images
        selectedAssets = assets
        imagesCollectionView.reloadData()
    }
}
