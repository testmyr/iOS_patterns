//
//  MovieDetailed.swift
//  MVVMCTrainingApp
//
//  Created by sdk on 3/25/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation

struct MovieDetailed {
    var genres: [String]?
    var overview: String
    var releaseDate: String
    var title: String
    
    init(_ dictionary: [String: Any]) {
        if let genresArray = dictionary["genres"] as? Array<Any> {
            genres = genresArray.compactMap { element in
                if let elementDictionary = element as? Dictionary<String, Any> {
                    if let genreName = elementDictionary["name"] as? String {
                        return genreName
                    }
                }
                return nil
            }
        }
        overview = dictionary["overview"] as? String ?? ""
        releaseDate = dictionary["release_date"] as? String ?? ""
        title = dictionary["title"] as? String ?? ""
    }
}
