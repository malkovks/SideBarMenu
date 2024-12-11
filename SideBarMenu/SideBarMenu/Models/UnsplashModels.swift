//
// File name: UnsplashModels.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 11.12.2024.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.


import UIKit

struct UnsplashPhotos: Codable {
    let id: String
    let createdAt: Date?
    let updatedAt: Date?
    let width: Int?
    let height: Int?
    let color: String?
    let blurHash: String?
    let downloads: Int?
    let likes: Int?
    let likedByUser: Bool?
    let description: String?
    let exif: Exif?
    let location: Location?
    let currentUserCollections: [Collection]?
    let urls: Urls?
    let links: Links?
    let user: User?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width, height, color
        case blurHash = "blur_hash"
        case downloads, likes
        case likedByUser = "liked_by_user"
        case description, exif, location
        case currentUserCollections = "current_user_collections"
        case urls, links, user
    }
}

// MARK: - Collection
struct Collection: Codable {
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case id
    }
}

// MARK: - Exif
struct Exif: Codable {
    let make: String?
    let model: String?
    let exposureTime: String?
    let aperture: String?
    let focalLength: String?
    let iso: Int?

    enum CodingKeys: String, CodingKey {
        case make, model
        case exposureTime = "exposure_time"
        case aperture
        case focalLength = "focal_length"
        case iso
    }
}

// MARK: - Location
struct Location: Codable {
    let name: String?
    let city: String?
    let country: String?
    let position: Position?
}

// MARK: - Position
struct Position: Codable {
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Urls
struct Urls: Codable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
}

// MARK: - Links
struct Links: Codable {
    let selfLink: String?
    let html: String?
    let download: String?
    let downloadLocation: String?

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case html, download
        case downloadLocation = "download_location"
    }
}

// MARK: - User
struct User: Codable {
    let id: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}


let mockPhotos: [UnsplashPhotos] = [
    UnsplashPhotos(id: "vBQ1icxQrdw", createdAt: nil, updatedAt: nil, width: 7680, height: 4320, color: "#a6a68c", blurHash: nil, downloads: 9351, likes: 70, likedByUser: nil, description: "8k 3d render", exif: nil, location: nil, currentUserCollections: nil, urls: Urls(raw: nil, full: nil, regular: "https://images.unsplash.com/photo-1731600800681-3970e965bb95?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2ODUwNDN8MHwxfHJhbmRvbXx8fHx8fHx8fDE3MzM4ODI0MTB8&ixlib=rb-4.0.3&q=80&w=1080", small: nil, thumb: nil), links: Links(selfLink: "https://api.unsplash.com/photos/a-close-up-of-a-cell-phone-on-a-wall-vBQ1icxQrdw", html: nil, download: "https://unsplash.com/photos/vBQ1icxQrdw/download?ixid=M3w2ODUwNDN8MHwxfHJhbmRvbXx8fHx8fHx8fDE3MzM4ODI0MTB8", downloadLocation: nil), user: nil),
    UnsplashPhotos(id: "fuHYNH6etbQ", createdAt: nil, updatedAt: nil, width: 4496, height: 3000, color: "#d9d9c0", blurHash: nil, downloads: 6420, likes: 46, likedByUser: nil, description: "Spring night shoot, jaguar fashion", exif: nil, location: Location(name: "Long Beach, CA, USA", city: "Long Beach", country: "United States", position: Position(latitude: 33.77005, longitude: -118.193739)), currentUserCollections: nil, urls: Urls(raw: "https://images.unsplash.com/photo-1732167372202-30be36e1168e?ixid=M3w2ODUwNDN8MHwxfHJhbmRvbXx8fHx8fHx8fDE3MzM4ODI0MTB8&ixlib=rb-4.0.3", full: nil, regular: "https://images.unsplash.com/photo-1732167372202-30be36e1168e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2ODUwNDN8MHwxfHJhbmRvbXx8fHx8fHx8fDE3MzM4ODI0MTB8&ixlib=rb-4.0.3&q=80&w=1080", small: nil, thumb: nil), links: Links(selfLink: "https://api.unsplash.com/photos/a-woman-in-a-gold-dress-standing-on-a-balcony-fuHYNH6etbQ", html: nil, download: "https://unsplash.com/photos/fuHYNH6etbQ/download?ixid=M3w2ODUwNDN8MHwxfHJhbmRvbXx8fHx8fHx8fDE3MzM4ODI0MTB8", downloadLocation: nil), user: nil),
    UnsplashPhotos(id: "CwbnBCXgssk", createdAt: nil, updatedAt: nil, width: 5472, height: 3290, color: "#a68c8c", blurHash: nil, downloads: 6928, likes: 59, likedByUser: nil, description: "\"End of the Day\"", exif: nil, location: Location(name: "Staffal, Aosta Valley, Italy", city: "Staffal", country: "Italy", position: Position(latitude: 45.858874, longitude: 7.811838)), currentUserCollections: nil, urls: Urls(raw: "https://images.unsplash.com/photo-1732470878984-f35c1a805e3f?ixid=M3w2ODUwNDN8MHwxfHJhbmRvbXx8fHx8fHx8fDE3MzM4ODI0MTB8&ixlib=rb-4.0.3", full: nil, regular: "https://images.unsplash.com/photo-1732470878984-f35c1a805e3f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2ODUwNDN8MHwxfHJhbmRvbXx8fHx8fHx8fDE3MzM4ODI0MTB8&ixlib=rb-4.0.3&q=80&w=1080", small: nil, thumb: nil), links: Links(selfLink: "https://api.unsplash.com/photos/a-mountain-covered-in-snow-at-sunset-CwbnBCXgssk", html: nil, download: "https://unsplash.com/photos/CwbnBCXgssk/download?ixid=M3w2ODUwNDN8MHwxfHJhbmRvbXx8fHx8fHx8fDE3MzM4ODI0MTB8", downloadLocation: nil), user: nil)
]
