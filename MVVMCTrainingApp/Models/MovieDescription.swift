//
//  MovieDescription.swift
//  MVVMCTrainingApp
//
//  Created by sdk on 3/25/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation

struct MovieDescription {//sorry, no time for Codable. I've tried ))) :(
    var posterPath: String?
    var adult: Bool
    var overview: String
    var release_date: String
    var genreIds: [Int]
    var id: Int
    var originalTitle: String
    var originalLanguage: String
    var title: String
    var backdrop_path: String?
    var popularity: Double
    var vote_count: Int
    var video: Bool
    var vote_average: Double
    
    init(_ dictionary: [String: Any]) {
         posterPath = dictionary["poster_path"] as? String
         adult = dictionary["adult"] as? Bool ?? false
         overview = dictionary["overview"] as? String ?? ""
         release_date = dictionary["release_date"] as? String ?? ""
         genreIds = dictionary["genre_ids"] as? [Int] ?? []
         id = dictionary["id"] as? Int ?? 0
         originalTitle = dictionary["original_title"] as? String ?? ""
         originalLanguage = dictionary["original_language"] as? String ?? ""
         title = dictionary["title"] as? String ?? ""
         backdrop_path = dictionary["backdrop_path"] as? String
         popularity = dictionary["popularity"] as? Double ?? 0
         vote_count = dictionary["vote_count"] as? Int ?? 0
         video = dictionary["video"] as? Bool ?? false
         vote_average = dictionary["vote_average"] as? Double ?? 0
    }
}
