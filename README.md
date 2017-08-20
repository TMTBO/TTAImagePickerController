# TTAImagePickerController

English | [中文](https://github.com/TMTBO/TTAImagePickerController/blob/master/README_zh.md)

**A Lightweight image selection framework**

[![CI Status](http://img.shields.io/travis/TMTBO/TTAImagePickerController.svg?style=flat)](https://travis-ci.org/TMTBO/TTAImagePickerController)
[![Version](https://img.shields.io/cocoapods/v/TTAImagePickerController.svg?style=flat)](http://cocoapods.org/pods/TTAImagePickerController)
[![License](https://img.shields.io/cocoapods/l/TTAImagePickerController.svg?style=flat)](http://cocoapods.org/pods/TTAImagePickerController)
[![Platform](https://img.shields.io/cocoapods/p/TTAImagePickerController.svg?style=flat)](http://cocoapods.org/pods/TTAImagePickerController)

## Feature

* A Lightweight image selection framework, Low memory consumption
* Support Device orientation and iPad
* Almost identical to the `UIImagePickerController` interface, easy to get started
* Convenient preview function
* A lot of small details

## ScreenShot

![ScreenShot](https://github.com/TMTBO/TTAImagePickerController/blob/master/TTAImagePicker_all.png)

## Example

To run the example project, clone the repo, and run `pod install` from the `Example` directory first.

## Requirements

* iOS > 8.0
* swift >= 3.0

## Installation

* `TTAImagePickerController` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:`pod "TTAImagePickerController" `

*  Manual import：
	Drag and drop All files in the `TTAImagePickerController` folder to project, import the main file：`import TTAImagePickerController`

## How to use

**1. Create**

```
// Create the image picker with the assets that you had selected which will show as selected in the picker
let imagePicker = TTAImagePickerController(selectedAsset: selectedAssets)
// Set pickerDelegate
imagePicker.pickerDelegate = self
// Set allow take picture in the picker, default: true
imagePicker.allowTakePicture = allowTakePickerSwitch.isOn
// Set allow user delete images in the picker, default: false
imagePicker.allowDeleteImage = allowDeleteImageSwitch.isOn
// Set the max pick number, default is 9
imagePicker.maxPickerNum = Int(maxImageCountTextField.text ?? "9") ?? 9
        
// You can custom the picker apperance
// imagePicker.selectItemTintColor = .red
// imagePicker.barTintColor = .orange
// imagePicker.tintColor = .cyan
        
present(imagePicker, animated: true, completion: nil)
```

**2. Confirm and implement delegate**

```
// implement the delegate method and when finished picking, you will get the images and assets that you have selected
func imagePickerController(_ picker: TTAImagePickerControllerCompatiable, didFinishPicking images: [UIImage], assets: [TTAAsset]) {
	print("got the images")
	selectedImages = images
	selectedAssets = assets
	imagesCollectionView.reloadData()
}
```

**Extra function you can get**

```
// On the other hand, you can preview the images directly and deselected some of them
// What you need to do:
// Create a instance of `TTAPreviewViewController` (dependency the delegate in step 2)
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let previewVc = TTAPreviewViewController(selected: selectedAssets, index: indexPath.item, delegate: self)
        present(previewVc, animated: true, completion: nil)
    }
}
```

## Recnet Add

* 20170820
> Add Camera Support
> Support Image deleteation in picker

* 20170806
> Gif Support
> Video Support

## What to do next
1. Your advice is welcome

## Author

TobyoTenma, tmtbo@hotmail.com

## License

TTAImagePickerController is available under the MIT license. See the LICENSE file for more info.
