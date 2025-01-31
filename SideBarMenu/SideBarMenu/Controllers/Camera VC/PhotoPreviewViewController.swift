//
// File name: PhotoPreviewViewController.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 29.01.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.

import UIKit

class PhotoPreviewViewController: UIViewController {
    
    private let coreDataManager: CoreDataManager = .shared
    private let photoManager: PhotoLibraryManager = .shared
    
    private lazy var imageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        return $0
    }(UIImageView())
    
    private var saveImageButton: UIBarButtonItem {
        return .init(image: UIImage(systemName: "externaldrive") , style: .done, target: self, action: #selector(didTapToSaveImage))
    }
    
    private var saveImageToAlbumButton: UIBarButtonItem {
        return .init(image: UIImage(systemName: "photo") , style: .done, target: self, action: #selector(didTapToSaveImageToPhoto))
    }
    
    private var backBarButton: UIBarButtonItem {
        return .init(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(didTapPopViewController))
    }
    
    private let image: UIImage
    private var isImageSaved: Bool = false
    
    init(image: UIImage){
        self.image = image
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        
        imageView.image = image
        navigationItem.setRightBarButtonItems([saveImageButton,saveImageToAlbumButton], animated: true)
        navigationItem.setLeftBarButtonItems([backBarButton], animated: true)
    }
    
    @objc private func didTapPopViewController(){
        if !isImageSaved {
            presentAlertForSaving()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func didTapToSaveImage(){
        presentAlertView()
    }
    
    @objc private func didTapToSaveImageToPhoto(){
        checkAccessToPhotoLibrary()
    }
    
    private func presentAlertForSaving(){
        let alert = UIAlertController(title: "Warning", message: "You did not save captured image. Do you want to save it?", preferredStyle: .alert)
        let mediaSaveAction = UIAlertAction(title: "Save to Library", style: .default) { _ in
            self.didTapToSaveImageToPhoto()
        }
        
        let coreDataAction = UIAlertAction(title: "Save to Storage", style: .default) { _ in
            self.didTapToSaveImage()
        }
        let cancelAction = UIAlertAction(title: "Don't save", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(mediaSaveAction)
        alert.addAction(coreDataAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
        
    }
    
    private func checkAccessToPhotoLibrary(){
        photoManager.saveImageToLibrary(image) { [weak self] isSuccess in
            guard let self else { return }
            if !isSuccess {
                presentAlert(title: "Check your permission for Photo Library")
            } else {
                isImageSaved = true
                presentAlert(title: "Image saved successfully")
            }
        }
    }
    
    private func presentAlertView() {
        let alert = UIAlertController(title: "Save image", message: "Do you want to save image?", preferredStyle: .alert)
        alert.severity = .critical
        alert.addTextField { textField in
            textField.placeholder = "Enter the name(optional)"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let textField = alert.textFields?.first {
                let text = textField.text
                isImageSaved = true
                coreDataManager.savePhoto(image, title: text)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func saveImageToLibrary(){
        
    }
}
