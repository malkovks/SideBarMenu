//
// File name: SecondViewController.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 11.12.2024.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.


import UIKit
import AVFoundation

enum FlashModesType: String, CaseIterable {
    case on
    case off
    case always
    
    var typeImage: UIImage {
        switch self {
        case .on:
            return .flash_on
        case .off:
            return .flash_off
        case .always:
            return .flash_always
        }
    }
}

class SecondViewController: UIViewController {
    
    private lazy var photoButton: UIButton = {
        $0.tintColor = .white
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 35
        $0.layer.borderWidth = 5
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.addTarget(self, action: #selector(didTapMakePhoto), for: .primaryActionTriggered)
        return $0
    }(UIButton(type: .system))
    
    private lazy var rotateCameraButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium, scale: .medium)
        $0.contentMode = .center
        $0.setImage(UIImage(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle")?.withConfiguration(config), for: .normal)
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(didTapRotateCamera), for: .primaryActionTriggered)
        $0.tintColor = .white
        return $0
    }(UIButton(type: .system))
    
    private lazy var flashButton: UIButton = {
        $0.contentMode = .center
        $0.tintColor = .white
        $0.setImage(.flash_off, for: .normal)
        $0.backgroundColor = .clear
        $0.menu = menu
        $0.showsMenuAsPrimaryAction = true
        return $0
    }(UIButton(type: .system))
    
    private let cameraManager: CameraManager = .init()
    
    
    private var flashMode: AVCaptureDevice.FlashMode = .off {
        didSet {
            switch flashMode {
                
            case .off:
                flashButton.setImage(.flash_off, for: .normal)
            case .on:
                flashButton.setImage(.flash_on, for: .normal)
            case .auto:
                flashButton.setImage(.flash_always, for: .normal)
            @unknown default:
                break
            }
            cameraManager.setupFlashMode(flashMode)
        }
    }
    
    private var menuItems: [UIAction] {
        return FlashModesType.allCases.map { type in
            return UIAction(title: type.rawValue,image: type.typeImage) { [weak self] _ in
                guard let self else { return }
                switch type {
                case .on:
                    flashMode = .on
                    cameraManager.setupTorchFlash(isFlashing: false)
                case .off:
                    flashMode = .off
                    cameraManager.setupTorchFlash(isFlashing: false)
                case .always:
                    flashMode = .auto
                    cameraManager.setupTorchFlash(isFlashing: true)
                }
            }
        }
    }
    
    private var menu: UIMenu {
        return UIMenu(title: "Flash mode", options: [], children: menuItems)
    }

    //MARK: - Main load methods
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraManager.setupCamera()
        setupGestures()
        DispatchQueue.main.async {
            let layer = self.cameraManager.getPreviewLayer()
            layer.frame = self.view.layer.bounds
            self.view.layer.addSublayer(layer)
        }
        view.backgroundColor  = .systemIndigo
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(photoButton)
        view.addSubview(rotateCameraButton)
        view.addSubview(flashButton)
        
        photoButton.frame = CGRect(x: view.center.x - 35, y: view.frame.height - (tabBarController?.tabBar.frame.height)! - 100, width: 70, height: 70)
        rotateCameraButton.frame = CGRect(x: view.frame.size.width - 60 - 10, y: photoButton.center.y - 25, width: 50, height: 50)
        flashButton.frame = CGRect(x: 20, y: photoButton.center.y - 25, width: 50, height: 50)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        cameraManager.startSession()
        if let tabBar = tabBarController?.tabBar {
            tabBar.isTranslucent = true
            tabBar.backgroundImage = UIImage()
            tabBar.shadowImage = UIImage()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        cameraManager.stopSession()
        if let tabBar = tabBarController?.tabBar {
            tabBar.isTranslucent = false
            tabBar.backgroundImage = nil
            tabBar.shadowImage = nil
        }
    }
    
    //MARK: - Actions
    @objc private func didTapRotateCamera(){
        cameraManager.switchCamera()
    }
    
    @objc private func didTapMakePhoto(){
        cameraManager.takePhoto(delegate: self)
    }
    
    @objc private func didTapOnCameraLayer(_ sender: UITapGestureRecognizer){
        let point = sender.location(in: view)
        cameraManager.focus(at: point, in: view)
        showFocusIndicator(at: point)
    }
    
    //MARK: - Setup methods
    private func showFocusIndicator(at point: CGPoint){
        let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        focusView.center = point
        focusView.layer.borderWidth = 2
        focusView.layer.borderColor = UIColor.white.cgColor
        focusView.layer.cornerRadius = 10
        focusView.alpha = 0
        
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25) {
            focusView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0.5, options: .curveEaseInOut) {
                focusView.alpha = 0
            } completion: { _ in
                focusView.removeFromSuperview()
            }
        }
    }
    
    private func setupGestures(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnCameraLayer))
        view.addGestureRecognizer(tapGesture)
    }
}

extension SecondViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return 
        }
        let vc = PhotoPreviewViewController(image: image)
        navigationController?.pushViewController(vc, animated: false)
    }
}
