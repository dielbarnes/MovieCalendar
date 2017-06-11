//
//  StringHelper.swift
//  MovieCalendar
//
//  Created by Diel on 11/06/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

extension String {
    
    func dictionaryFromQueryStringComponents() -> [String: String] {
        
        var dict: [String: String] = [:]
        
        for keyValue in self.components(separatedBy: "&") {
            let components = keyValue.components(separatedBy: "=")
            let key = components[0]
            let value = components[1]
            dict[key] = value.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
        }
        
        return dict
    }
}
