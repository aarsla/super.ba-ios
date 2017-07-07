//
//  Article.swift
//  super
//
//  Created by Aid Arslanagic on 15/06/2017.
//  Copyright © 2017 Simpastudio. All rights reserved.
//

import Foundation
import ObjectMapper

class ArticlesResponse: Mappable {
    var articles: [Article]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        articles <- map["articles"]
    }
}

class Article: Mappable {
    var title: String?
    var link: String?
    var description: String?
    var imageUrl: String?
    var date: Date?
    var source: Source?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        link <- map["link"]
        description <- map["description"]
        imageUrl <- map["image"]
        date <- (map["pubDate.sec"], DateTransform())
        source <- map["source"]
    }
}

extension Article: Equatable {
    static func == (lhs: Article, rhs: Article) -> Bool {
        return
            lhs.imageUrl == rhs.imageUrl && lhs.source?.title == rhs.source?.title && lhs.date == rhs.date
    }
}
