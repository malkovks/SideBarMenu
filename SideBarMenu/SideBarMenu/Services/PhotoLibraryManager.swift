//
// File name: PhotoLibraryManager.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 31.01.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.

import UIKit
import Photos

final class PhotoLibraryManager: NSObject {
    static let shared = PhotoLibraryManager()
    
    private override init() {}
    
    func saveImageToLibrary(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        checkAuthorizationStatus { isSuccess in
            guard isSuccess else {
                completion(false)
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { isSuccess, error in
                guard error == nil else {
                    completion(false)
                    return
                }
                DispatchQueue.main.async {
                    completion(isSuccess)
                }
            }
        }
    }
    
    
    private func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            requestAccess(completion: completion)
        case .restricted, .denied, .limited:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    
    
    private func requestAccess(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
}
