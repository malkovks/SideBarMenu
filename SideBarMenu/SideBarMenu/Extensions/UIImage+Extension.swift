//
// File name: UIImage+Extension.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 29.01.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.

import UIKit

extension UIImage {
    
    private static let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .default)
    
    static let flash_on: UIImage = .init(systemName: "flashlight.on.fill")!.withConfiguration(config)
    static let flash_off: UIImage = .init(systemName: "flashlight.off.fill")!.withConfiguration(config)
    static let flash_always: UIImage = .init(systemName: "lightbulb.min.fill")!.withConfiguration(config)
    
}
