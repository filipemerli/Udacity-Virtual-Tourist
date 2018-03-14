//
//  FlickrConstants.swift
//  Udacity Virtual Tourist
//
//  Created by Filipe Merli on 12/03/2018.
//  Copyright © 2018 Filipe Merli. All rights reserved.
//

import Foundation

extension FlickrAPIClient {
    struct FlickrConstants {
        static let myKey = "30c7bf758e9a97e92109a5235d307bd3"
        static var bboxRange = ""
        static let urlExemplo = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(myKey)&bbox=2.28%2C+48.84%2C+2.30%2C+48.86&safe_search=1&extras=url_m&per_page=1&page=1&format=json&nojsoncallback=1"
    }
}
