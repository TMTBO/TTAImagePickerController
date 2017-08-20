# TTAImagePickerController

中文 | [English](https://github.com/TMTBO/TTAImagePickerController/blob/master/README.md)

**一个轻量级图片选择框架**

[![CI Status](http://img.shields.io/travis/TMTBO/TTAImagePickerController.svg?style=flat)](https://travis-ci.org/TMTBO/TTAImagePickerController)
[![Version](https://img.shields.io/cocoapods/v/TTAImagePickerController.svg?style=flat)](http://cocoapods.org/pods/TTAImagePickerController)
[![License](https://img.shields.io/cocoapods/l/TTAImagePickerController.svg?style=flat)](http://cocoapods.org/pods/TTAImagePickerController)
[![Platform](https://img.shields.io/cocoapods/p/TTAImagePickerController.svg?style=flat)](http://cocoapods.org/pods/TTAImagePickerController)

## 特点

* 个轻量级图片选择框架,内存占用低
* 适配屏幕旋转和 iPad
*  与 `UIImagePickerController` 相似的接口, 容易上手使用
* 便捷胡图片预览功能
* 许多小细节

## 屏幕截图

![ScreenShot](https://github.com/TMTBO/TTAImagePickerController/blob/master/TTAImagePicker_all.png)

## 示例程序

运行示例工程,先从 github 上克隆,再在 `Example` 文件夹运行 `pod install`.

## 版本要求

* iOS > 8.0
* swift >= 3.0

## 安装

* `TTAImagePickerController` 可以通过 [CocoaPods](http://cocoapods.org) 安装. 把`pod "TTAImagePickerController" `添加到你的 `Podfile` 文件中

* 手动导入：
	将 `TTAImagePickerController` 文件夹中的所有文件拖到你的工程中,在使用到的文件中导入`import TTAImagePickerController`

## 如何使用

**1. 创建**

```
// 用已经选中的 assets 创建 imagePicker, 这个已经选中的 assets 数组中的元素将在 imagePicker 中标记为已选中
let imagePicker = TTAImagePickerController(selectedAsset: selectedAssets)
// 设置代理
imagePicker.pickerDelegate = self
// 设置是否允许用户在选择器的拍照, 默认允许
imagePicker.allowTakePicture = allowTakePickerSwitch.isOn
// 设置是否允许用户在选择器的删除照片, 默认不允许
imagePicker.allowDeleteImage = allowDeleteImageSwitch.isOn
// 设置最大可选图片个数, 默认为 9 张
imagePicker.maxPickerNum = Int(maxImageCountTextField.text ?? "9") ?? 9
        
// 你可以自定义选择器的外观
// imagePicker.selectItemTintColor = .red
// imagePicker.barTintColor = .orange
// imagePicker.tintColor = .cyan
        
present(imagePicker, animated: true, completion: nil)
```

**2. 遵循并实现协议**

```
// 实现协议方法,当选择完成后,你可以在这个方法中得到回调,获取你所选中的 图片数组 和 assets
func imagePickerController(_ picker: TTAImagePickerControllerCompatiable, didFinishPicking images: [UIImage], assets: [TTAAsset]) {
	print("获取到图片")
	selectedImages = images
	selectedAssets = assets
	imagesCollectionView.reloadData()
}
```

**你可以获得的额外的功能**

```
// 你可以直接预览并操作你已经选中的 图片
// 你需要做的:
// 创建一个 `TTAPreviewViewController` 实例 (这里依赖步骤 2 中的代理方法)
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let previewVc = TTAPreviewViewController(selected: selectedAssets, index: indexPath.item, delegate: self)
        present(previewVc, animated: true, completion: nil)
    }
}
```

## 最近添加

* 20170820
> 添加拍照支持
> 允许用户在选择器的删除图片

* 20170806
> Gif 预览支持
> 视频预览支持

## 接下来
1.期待你的建议

## Author

TobyoTenma, tmtbo@hotmail.com

## License

TTAImagePickerController is available under the MIT license. See the LICENSE file for more info.
