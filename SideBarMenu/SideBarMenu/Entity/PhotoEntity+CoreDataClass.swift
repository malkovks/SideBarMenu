//
// File name: PhotoEntity+CoreDataClass.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 31.01.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.

//

import Foundation
import CoreData

@objc(PhotoEntity)
public class PhotoEntity: NSManagedObject { }

extension PhotoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoEntity> {
        return NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var imageData: Data?
    @NSManaged public var date: Date?
    @NSManaged public var title: String?

}

extension PhotoEntity : Identifiable { }
