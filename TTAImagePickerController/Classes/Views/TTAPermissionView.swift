//
//  TTAPermissionView.swift
//  Pods-TTAImagePickerController_Example
//
//  Created by TobyoTenma on 09/07/2017.
//

import UIKit

class TTAPermissionView: UIView {
    
    enum TTAPermissionViewType {
        case photo, camera
    }
    fileprivate var type = TTAPermissionViewType.photo {
        didSet {
            configIconLabel()
        }
    }
    fileprivate let iconLabel = UILabel()
    fileprivate let tipLabel = UILabel()
    fileprivate let goSettingButton = UIButton(type: UIButtonType.system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    convenience init(type: TTAPermissionViewType) {
        self.init(frame: UIScreen.main.bounds)
        self.type = type
        configIconLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        superview?.layoutSubviews()
        layoutViews()
    }
}

// MARK: - UI

extension TTAPermissionView {
    func setupUI() {
        func addViews() {
            addSubview(iconLabel)
            addSubview(tipLabel)
            addSubview(goSettingButton)
        }
        func configViews() {
            iconLabel.textAlignment = .center
            iconLabel.font = UIFont.iconfont(size: UIFont.IconFontSize.photoMark)
            iconLabel.textColor = UIColor.lightGray
            
            configTipLabel()
            tipLabel.numberOfLines = 0
            tipLabel.textAlignment = .center
            tipLabel.font = UIFont.systemFont(ofSize: 16)
            
            goSettingButton.setTitle("Go Setting", for: .normal)
            goSettingButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            goSettingButton.addTarget(self, action: #selector(didClickGoSetting), for: .touchUpInside)
            
            iconLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tipLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            goSettingButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        addViews()
        configViews()
        layoutViews()
    }
    func layoutViews() {
        iconLabel.frame = CGRect(x: 0, y: iconTopMargin(), width: bounds.width, height: iconHeight())
        tipLabel.frame = CGRect(x: sideMargin(), y: iconLabel.frame.maxY + tipTopMargin(), width: bounds.width - 2 * sideMargin(), height: 50)
        goSettingButton.frame = CGRect(x: sideMargin(), y: tipLabel.frame.maxY + buttonTopMargin(), width: tipLabel.bounds.width, height: buttonHeight())
    }
    
    func configIconLabel() {
        let iconText: String
        switch type {
        case .photo:
            iconText = UIFont.IconFont.photoMark.rawValue
        case .camera:
            iconText = UIFont.IconFont.cameraMark.rawValue
        }
        iconLabel.text = iconText
    }
    
    func configTipLabel() {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        let tipString = "Allow \(appName ?? "App") to access your \(type == .photo ? "Album" : "Camera") in \"Settings -> Privacy -> Photos\""
        tipLabel.text = tipString
    }
}

// MARK: - Actions

extension TTAPermissionView {
    func didClickGoSetting() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
}

// MARK: - Const

extension TTAPermissionView {
    func iconTopMargin() -> CGFloat {
        return 200
    }
    func iconHeight() -> CGFloat {
        return 100
    }
    func tipTopMargin() -> CGFloat {
        return 10
    }
    func sideMargin() -> CGFloat {
        return 16
    }
    func buttonTopMargin() -> CGFloat {
        return tipTopMargin()
    }
    func buttonHeight() -> CGFloat {
        return 44
    }
}

// MARK: -
// MARK: - UIViewController Show Permission View

extension UIViewController {
    func showPermissionView(with type: TTAPermissionView.TTAPermissionViewType) {
        let permissionView = TTAPermissionView(type: type)
        permissionView.frame = view.bounds
        view.addSubview(permissionView)
    }
}
