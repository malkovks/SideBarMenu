//
// File name: UIImageView+Extension.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 11.12.2024.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.
import UIKit

extension UIImageView {
    func loadImage(from url: URL,imageId id: String, placeholder: UIImage? = nil,completion:  @escaping (_ image: UIImage?,_ id: String) -> Void) {
        self.image = placeholder
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let data = try? Data(contentsOf: url), let newImage = UIImage(data: data) else {
                completion(nil,id)
                return
            }
            
            DispatchQueue.main.async {
                if self?.image?.pngData() != newImage.pngData() {
                    self?.image = newImage
                    completion(newImage,id)
                } else {
                    completion(nil,id)
                }
            }
        }
    }
}

