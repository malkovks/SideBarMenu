//
// File name: SecondViewController.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 11.12.2024.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.


import UIKit
import AVFoundation

class SecondViewController: UIViewController {
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
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
        let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .medium, scale: .medium)
        $0.setImage(UIImage(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle")?.withConfiguration(config), for: .normal)
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(didTapRotateCamera), for: .primaryActionTriggered)
        $0.tintColor = .white
        return $0
    }(UIButton(type: .system))

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupGestures()
        view.backgroundColor  = .systemIndigo
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(photoButton)
        view.addSubview(rotateCameraButton)
        
        photoButton.frame = CGRect(x: view.center.x - 35, y: view.frame.height - (tabBarController?.tabBar.frame.height)! - 100, width: 70, height: 70)
        rotateCameraButton.frame = CGRect(x: view.frame.size.width - 60 - 10, y: photoButton.center.y, width: 50, height: 50)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        if let tabBar = tabBarController?.tabBar {
            tabBar.isTranslucent = true
            tabBar.backgroundImage = UIImage()
            tabBar.shadowImage = UIImage()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if let tabBar = tabBarController?.tabBar {
            tabBar.isTranslucent = false
            tabBar.backgroundImage = nil
            tabBar.shadowImage = nil
        }
    }
    
    @objc private func didTapRotateCamera(){
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)
        
        let newPosition: AVCaptureDevice.Position = (currentInput.device.position == .back) ? .front : .back
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else { return }
        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            if captureSession.canAddInput(newInput) {
                captureSession.addInput(newInput)
            }
        } catch {
            print("❌ Ошибка при переключении камеры: \(error.localizedDescription)")
        }
        captureSession.commitConfiguration()
    }
    
    @objc private func didTapMakePhoto(){
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func didTapOnCameraLayer(_ sender: UITapGestureRecognizer){
        let point = sender.location(in: view)
        focus(at: point)
        showFocusIndicator(at: point)
    }
    
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
    
    private func focus(at point: CGPoint){
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        let pointSize = CGPoint(x: point.x / view.bounds.width, y: point.y / view.bounds.height)
        do {
            
            
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = pointSize
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = pointSize
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()
            
        } catch {
            print("❌ Ошибка: \(error)")
        }
    }
    
    private func setupGestures(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnCameraLayer))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession = AVCaptureSession()
            self.captureSession.sessionPreset = .photo
            
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("❌ Ошибка: камера не найдена")
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                if self.captureSession.canAddInput(input) {
                    self.captureSession.addInput(input)
                }
                
                self.photoOutput = AVCapturePhotoOutput()
                if self.captureSession.canAddOutput(self.photoOutput) {
                    self.captureSession.addOutput(self.photoOutput)
                }
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    self.previewLayer.videoGravity = .resizeAspectFill
                    self.previewLayer.frame = self.view.layer.bounds
                    self.view.layer.addSublayer(self.previewLayer)
                    
                    
                }
                
            } catch {
                print("❌ Ошибка настройки камеры: \(error)")
            }
        }
    }
}

extension SecondViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return 
        }
        let vc = PhotoCropViewController(image: image)
        navigationController?.pushViewController(vc, animated: true)
    }
}
