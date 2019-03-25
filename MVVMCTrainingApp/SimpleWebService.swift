//
//  SimpleWebService.swift
//  MVVMCTrainingApp
//
//  Created by sdk on 3/25/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation

class SimpleWebService {
    private let apiKey = "aec8a424ccf89565e11d39fe96df8749"
    private let baseUrl = "https://api.themoviedb.org/3/movie/"
    private let urlSuffixPopularMovies = "popular"
    private let urlSuffixYoutubeLinkInfo = "videos"
    
    private let parameterAPIKey = "api_key"
    private let parameterPageKey = "page"
    
    static let shared = SimpleWebService()
    private init() {
        let cache = URLCache(memoryCapacity: 40 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "offlineCache")
        URLCache.shared = cache
    }
    
    func getPopularMovies(forPage page: Int, withAftermathClosure aftermathClosure: @escaping (Bool, [MovieDescription]?) -> Void) {
        let popularMoviesUrlString = baseUrl + urlSuffixPopularMovies
        var url = URLComponents(string: popularMoviesUrlString)!
        
        url.queryItems = [
            URLQueryItem(name: parameterAPIKey, value: apiKey),
            URLQueryItem(name: parameterPageKey, value: String(page))
        ]
        guard let finalUrl = url.url else {return}
        let task = URLSession.shared.dataTask(with: finalUrl) { (data, response, error) in
            var success = false
            defer {
                if !success {
                    aftermathClosure(false, nil)
                }
            }
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Oops..")
                return
            }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
                guard let jsonRootDictionary = jsonResponse as? [String: Any] else {
                    return
                }
                guard let jsonArray = jsonRootDictionary["results"] as? [[String: Any]] else {
                    return
                }
                var model = [MovieDescription]()
                model = jsonArray.compactMap{ (dictionary) in
                    return MovieDescription(dictionary)
                }
                success = true
                aftermathClosure(true, model)
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    
    func getDetailedDescription(byMovieID movieID: String, withAftermathClosure aftermathClosure: @escaping (Bool, MovieDetailed?) -> Void) {
        let detailedDescriptionUrlString = baseUrl + movieID
        var url = URLComponents(string: detailedDescriptionUrlString)!
        
        url.queryItems = [
            URLQueryItem(name: parameterAPIKey, value: apiKey)
        ]
        guard let finalUrl = url.url else {return}
        let task = URLSession.shared.dataTask(with: finalUrl) { (data, response, error) in
            var success = false
            defer {
                if !success {
                    aftermathClosure(false, nil)
                }
            }
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Oops..")
                return
            }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
                guard let jsonRootDictionary = jsonResponse as? [String: Any] else {
                    return
                }
                let model = MovieDetailed(jsonRootDictionary)
                success = true
                aftermathClosure(true, model)
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    
    func getYouTubeVideoId(byMovieID movieID: String, withAftermathClosure aftermathClosure: @escaping (Bool, String?) -> Void) {
        let youtubeIdUrlString = baseUrl + movieID + "/" + urlSuffixYoutubeLinkInfo
        var url = URLComponents(string: youtubeIdUrlString)!
        url.queryItems = [
            URLQueryItem(name: parameterAPIKey, value: apiKey)
        ]
        guard let finalUrl = url.url else {return}
        let task = URLSession.shared.dataTask(with: finalUrl) { (data, response, error) in
            var success = false
            defer {
                if !success {
                    aftermathClosure(false, nil)
                }
            }
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Oops..")
                return
            }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
                guard let jsonRootDictionary = jsonResponse as? [String: Any] else {
                    return
                }
                guard let jsonArray = jsonRootDictionary["results"] as? [[String: Any]] else {
                    return
                }
                var youTubeVideoId: String?
                for dictionary in jsonArray {
                    if let theFirstFoundYTVideo = dictionary["key"] as? String {
                        youTubeVideoId = theFirstFoundYTVideo
                        break
                    }
                }
                success = true
                aftermathClosure(true, youTubeVideoId)
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
}