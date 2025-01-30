//
// File name: AVCaptureManager.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 29.01.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.


import AVFoundation
import UIKit

class AVCaptureManager: NSObject {
    static let shared = AVCaptureManager()
    
    private override init() {}
    
    func checkCameraPermission(viewController: UIViewController) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch cameraAuthorizationStatus {
        case .notDetermined:
            requestCameraPermission()
        case .authorized:
            print("Доступ к камере разрешен")
        case .denied, .restricted:
            showCameraAccessDeniedAlert(viewController)
        @unknown default:
            fatalError("Неизвестный статус доступа к камере")
        }
    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Доступ к камере предоставлен")
            } else {
                print("Доступ к камере отклонен")
            }
        }
    }

    func showCameraAccessDeniedAlert(_ vc: UIViewController) {
        let alert = UIAlertController(
            title: "Доступ к камере запрещен",
            message: "Пожалуйста, разрешите доступ к камере в настройках приложения.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Настройки", style: .cancel, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        vc.present(alert, animated: true, completion: nil)
    }
}
