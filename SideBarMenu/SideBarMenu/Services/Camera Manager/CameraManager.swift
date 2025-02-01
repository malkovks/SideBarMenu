//
// File name: CameraManager.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 30.01.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.


import UIKit
import AVFoundation

final class CameraManager: NSObject {
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var currentDevice: AVCaptureDevice!
    
    var flashMode: AVCaptureDevice.FlashMode = .off
    var isTorchOn: Bool = false
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("❌ Ошибка: камера не найдена")
            return
        }
        currentDevice = device
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
        } catch {
            print("❌ Ошибка настройки камеры: \(error)")
        }
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.stopRunning()
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
        }
        return previewLayer
    }
    
    func switchCamera() {
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
    
    func setupFlashMode(_ mode: AVCaptureDevice.FlashMode) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasFlash else { return }
        
        do {
            try device.lockForConfiguration()
            if device.isFlashAvailable {
                device.flashMode = mode
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Error setting flash mode: \(error.localizedDescription)")
        }
    }
    
    func takePhoto(delegate: AVCapturePhotoCaptureDelegate) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
    func setupTorchFlash(isFlashing: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch, device.isTorchAvailable else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = isFlashing ? .on : .off
            isTorchOn = isFlashing
            device.unlockForConfiguration()
        } catch {
            print("Error setting torch mode: \(error.localizedDescription)")
        }
    }

    
    func focus(at point: CGPoint, in view: UIView) {
        guard let device = currentDevice else { return }
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
            print("❌ Ошибка фокусировки: \(error)")
        }
    }
}

