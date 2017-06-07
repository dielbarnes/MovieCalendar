//
//  Movie.swift
//  MovieCalendar
//
//  Created by Diel Barnes on 02/06/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

import Foundation
import UIKit

struct Movie {
    
    var id: Int
    var title: String
    var poster: UIImage?
    var posterPath: String?
    var backdrop: UIImage?
    var backdropPath: String?
    var genres: [String]?
    var cast: [Cast]?
    var plot: String?
    var trailerPath: String?
    var releaseDate: Date
}
