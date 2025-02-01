//
// File name: CoreDataManager.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 31.01.2025.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.

import UIKit
import CoreData

final class CoreDataManager: NSObject {
    static let shared = CoreDataManager()
    
    private override init() {}
    
    private let persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoriteImages")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    //MARK: - Actions with storage
    func loadPhotos() -> [PhotoEntity] {
        let request: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching photos: \(error.localizedDescription)")
            return []
        }
    }
    
    func savePhoto(_ image: UIImage, title: String?){
        let newPhoto = PhotoEntity(context: context)
        newPhoto.id = UUID()
        newPhoto.imageData = image.jpegData(compressionQuality: 1.0)
        newPhoto.date = Date()
        newPhoto.title = title
        
        do {
            try context.save()
        } catch {
            print("Error saving photo: \(error.localizedDescription)")
        }
    }
    
    func deletePhoto(_ model: PhotoModel){
        let fetchRequest = NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", model.id.uuidString)
        
        do {
            if let photo = try context.fetch(fetchRequest).first {
                context.delete(photo)
                try context.save()
            }
        } catch {
            print("Error deleting photo: \(error.localizedDescription)")
        }
    }
}
