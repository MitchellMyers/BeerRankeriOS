//
//  WebScrapingService.swift
//  BeerRanker
//
//  Created by Mitchell Myers on 1/15/19.
//  Copyright © 2019 BreMy Software. All rights reserved.
//

import Foundation
import Kanna
import Alamofire

class WebScrapingService {
    
    func scrapeGoogleSearch(beerPhraseToSearch: String, completion: @escaping (String?) -> Void) {
        var queryString = beerPhraseToSearch + "+beer+advocate"
        queryString = queryString.replacingOccurrences(of: " ", with: "+")
        queryString = queryString.replacingOccurrences(of: "%", with: "%25")
        let googleSearchUrl = "https://www.google.com/search?q=" + queryString + "&oq=" + queryString
        AF.request(googleSearchUrl).responseString { response in
            if let html = response.result.value {
                let beerAdvUrl = self.pullBeerAdvPageFromSearch(html: html, htmlKey: "https://www.beeradvocate.com/beer/")
                completion(beerAdvUrl)
            }
        }
    }
    
    func scrapeBeerAdvocate(beerAdvUrl: String, completion: @escaping ((String?, String?, String?)) -> Void) {
        var beerRating : String?
        var numBeerReviews : String?
        var beerAbv : String?
        AF.request(beerAdvUrl).responseString { response in
            if let html = response.result.value {
                beerRating = self.pullBeerInfo(html: html, htmlKey: "ba-ravg\">")
                numBeerReviews = self.pullBeerInfo(html: html, htmlKey: "ba-ratings\">")
                if let beerAbvOp = self.pullBeerInfo(html: html, htmlKey: "(ABV):</b>") {
                    beerAbv = beerAbvOp.trimmingCharacters(in: CharacterSet.init(charactersIn: " \n"))
                }
                completion((beerRating, numBeerReviews, beerAbv))
            }
        }
    }
    
    private func pullBeerInfo(html: String, htmlKey: String) -> String? {
        if let index = html.endIndex(of: htmlKey) {
            let substring = html[index...]
            let stringUncut = String(substring)
            if let endIndex = stringUncut.firstIndex(of: "<") {
                let rating = stringUncut[..<endIndex]
                return String(rating)
            }
        }
        return nil
    }
    
    private func pullBeerAdvPageFromSearch(html: String, htmlKey: String) -> String? {
        if let index = html.index(of: htmlKey) {
            let substring = html[index...]
            let stringUncut = String(substring)
            if let endIndex = stringUncut.firstIndex(of: "\"") {
                let beerAdvUrl = stringUncut[..<endIndex]
                return String(beerAdvUrl)
            }
        }
        return nil
    }
    
}

extension StringProtocol where Index == String.Index {
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range.lowerBound)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
