//
// File name: PhotoModel.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 01.02.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.

import UIKit

struct PhotoModel: Identifiable, Hashable {
    let id: UUID
    let image: Data
    let date: Date
    let title: String?
}

extension PhotoModel {
    init(from model: PhotoEntity){
        self.id = model.id ?? UUID()
        self.image = model.imageData ?? Data()
        self.date = model.date ?? Date()
        self.title = model.title
    }
}
