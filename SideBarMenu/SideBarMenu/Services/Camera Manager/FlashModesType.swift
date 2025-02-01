//
// File name: FlashModesType.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 01.02.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.

import UIKit

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
