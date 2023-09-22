//
//  SearchPhotosResponse.swift
//  virtual-tourist
//
//  Created by Becca Kauper on 9/13/23.
//

import Foundation

struct SearchPhotosResponse: Codable {
    let photos: PhotoObject
}

struct PhotoObject: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: Int
    let photo: [PhotoData]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}

struct PhotoData: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
}

/*
 {
     "photos": {
         "page": 1,
         "pages": 136882,
         "perpage": 2,
         "total": 273764,
         "photo": [
             {
                 "id": "53173357794",
                 "owner": "185355931@N08",
                 "secret": "67e54fe7fc",
                 "server": "65535",
                 "farm": 66,
                 "title": "536 London skyline, UK",
                 "ispublic": 1,
                 "isfriend": 0,
                 "isfamily": 0
             },
             {
                 "id": "53170559879",
                 "owner": "82911286@N03",
                 "secret": "7a536047b4",
                 "server": "65535",
                 "farm": 66,
                 "title": "Stemma del Podest\u00e0 Gabriele Ginori",
                 "ispublic": 1,
                 "isfriend": 0,
                 "isfamily": 0
             }
         ]
     },
     "stat": "ok"
 }
 */
