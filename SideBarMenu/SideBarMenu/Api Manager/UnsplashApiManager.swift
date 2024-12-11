//
// File name: UnsplashApiManager.swift
// Package: SideBarMenu
//
// Created by Malkov Konstantin on 10.12.2024.
// Copyright (c) 2024 Malkov Konstantin . All rights reserved.
//
//struct UnsplashKeys {
//    static let appId = "685043"
//    static let accessKey = "_KOXeupaFsfLKTBgY0KygN9vRowBm3aVu06H1_PFRp8"
//    static let secretKey = "x6BEkHgvuau0X2lu2FGQALLkPxl2v37111pJ2Ele6Og"
//    static let baseURL = "https://api.unsplash.com/"
//}

import Foundation

class UnsplashApiManager {
    static func fetchImages(count: Int, completion: @escaping ((_ models: [UnsplashPhotos]?) -> Void) ){
        let baseURL = "https://api.unsplash.com/"
        guard let accessKey = ProcessInfo.processInfo.environment["UNSPLASH_ACCESS_KEY"] else {
            print("Missing access key")
            completion(nil)
            return
        }
        let path = "photos/random/?client_id=\(accessKey)&count=\(count)"
        let url = baseURL + path
        
        guard let url = URL(string: url) else {
            print("Incorrect URL: \(url)")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error network: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("❌ Error: empty data: \(response?.description ?? "")")
                completion(nil)
                return
            }
            
            do {
                let decode = JSONDecoder()
                decode.dateDecodingStrategy = .iso8601
                decode.keyDecodingStrategy = .convertFromSnakeCase
                
                let photos = try decode.decode([UnsplashPhotos].self, from: data)
                DispatchQueue.main.async {
                    completion(photos)
                }
            } catch {
                print("❌ Error parsing JSON structure: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}

