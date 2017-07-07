//
//  Source.swift
//  super
//
//  Created by Aid Arslanagic on 05/07/2017.
//  Copyright © 2017 Simpastudio. All rights reserved.
//

import Foundation
import ObjectMapper

class SourcesResponse: Mappable {
    var sources: [Source]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        sources <- map["sources"]
    }
}

class Source: Mappable {
    var title: String?
    var url: String?
    var logo: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        url <- map["url"]
        logo <- map["logo"]
    }
}
