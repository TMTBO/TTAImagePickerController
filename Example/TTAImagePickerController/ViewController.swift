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
    @IBOutlet weak var allowTakePickerSwitch: UISwitch!
    @IBOutlet weak var allowDeleteImageSwitch: UISwitch!
    @IBOutlet weak var showLargeTitles: UISwitch!
    
    var selectedImages = [UIImage]()
    var selectedAssets = [TTAAsset]()
    override func viewDidLoad() {
        super.viewDidLoad()
        URLSession.shared.dataTask(with: URL(string: "https://www.tobyotenma.top/blog")!).resume()
    }

    @IBAction func didClickShowImagePickerButton(_ sender: UIButton) {
        // Create the image picket with the assets that you had selected which will show as selected in the picker
        let imagePicker = TTAImagePickerController(selectedAsset: selectedAssets)
        // Set pickerDelegate
        imagePicker.pickerDelegate = self
        // Set allow take picture in the picker
        imagePicker.allowTakePicture = allowTakePickerSwitch.isOn
        // Set allow user delete images in the picker
        imagePicker.allowDeleteImage = allowDeleteImageSwitch.isOn
        // Set support large titles for iOS 11
        imagePicker.supportLargeTitles = showLargeTitles.isOn
        // Set the max pick number, default is 9
        imagePicker.maxPickerNum = Int(maxImageCountTextField.text ?? "9") ?? 9
        
        // You can custom the picker apperance
//        imagePicker.selectItemTintColor = .red
//        imagePicker.barTintColor = .orange
//        imagePicker.tintColor = .cyan
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

// Confirm the `TTAImagePickerControllerDelegate`
extension ViewController: TTAImagePickerControllerDelegate {
    // implement the delegate method and when finished picking, you will get the images and assets that you have selected
    func imagePickerController(_ picker: TTAImagePickerControllerCompatiable, didFinishPicking images: [UIImage], assets: [TTAAsset]) {
        print("got the images")
        selectedImages = images
        selectedAssets = assets
        
        // Export Video and get the path
        var filePaths = [String?]()
        _ = assets.map {
            if $0.assetInfo.isVideo {
                TTAImagePickerController.fetchVideo(with: $0, completionHandler: { (outputPath) in
                    filePaths.append(outputPath)
                })
            }
        }
        
        
        imagesCollectionView.reloadData()
    }
}
// On the other hand, you can preview the images directly and deselected some of them
// What you need to do:
// Create a instance of `TTAPreviewViewController`
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let previewVc = TTAPreviewViewController(selected: selectedAssets, index: indexPath.item, delegate: self)
        present(previewVc, animated: true, completion: nil)
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
        cell.layer.contentsGravity = CALayerContentsGravity(rawValue: "resizeAspectFill")
        return cell
    }
}
