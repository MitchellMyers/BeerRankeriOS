//
//  BeerStats.swift
//  BeerRanker
//
//  Created by Mitchell Myers on 1/16/19.
//  Copyright © 2019 BreMy Software. All rights reserved.
//

import Foundation

class BeerStats {
    
    var beerName : String?
    var rating: String?
    var numRatings: String?
    var abv : String?
    
    init(beerName: String?, rating: String?, numRatings: String?, abv: String?) {
        self.beerName = beerName
        self.rating = rating
        self.numRatings = numRatings
        self.abv = abv
    }
    
    func isEmpty() -> Bool {
        return self.beerName == nil && self.rating == nil && self.numRatings == nil && self.abv == nil
    }
    
    func isBrewery() -> Bool {
        return self.abv == nil || self.abv == "N/A"
    }
    
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}
