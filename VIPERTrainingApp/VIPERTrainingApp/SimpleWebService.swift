//
//  SimpleWebService.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/8/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation

class SimpleWebService {
    private let clientId = "309c9d6c844476c"
    private let baseUrl = "https://api.imgur.com/3/image"
    
    
    static let shared = SimpleWebService()
    private init() {
        let cache = URLCache(memoryCapacity: 40 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "offlineCache")
        URLCache.shared = cache
    }
}
