//
//  DataModel.swift
//  NewsAppDemo
//
//  Created by Priya Arora on 22/07/19.
//  Copyright © 2019 Priya Arora. All rights reserved.
//

import Foundation

struct Articles: Codable {
    var articles: [Article]
}

struct Article: Codable {
    var author: String?
    var title: String?
    var name: String?
    var date: String?
    var description: String?
    var image_url: String?
    var url: String?
    
    
    private enum CodingKeys: String, CodingKey {
        case author
        case title
        case name
        case date = "publishedAt"
        case description
        case image_url = "urlToImage"
        case url
    }
}
