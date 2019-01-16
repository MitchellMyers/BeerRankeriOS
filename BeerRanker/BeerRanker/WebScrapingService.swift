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
        print("Here 1")
        AF.request(googleSearchUrl).responseString { response in
            print("Here 2")
            if let html = response.result.value {
                print("Here 3")
                let beerAdvUrl = self.pullBeerAdvPageFromSearch(html: html, htmlKey: "https://www.beeradvocate.com/beer/")
                completion(beerAdvUrl)
            }
        }
    }
    
    func scrapeBeerAdvocate(beerAdvUrl: String, completion: @escaping (BeerStats) -> Void) {
        var beerName : String?
        var beerRating : String?
        var numBeerReviews : String?
        var beerAbv : String?
        print("Here 5")
        AF.request(beerAdvUrl).responseString { response in
            print("Here 6")
            if let html = response.result.value {
                print("Here 7")
                beerName = self.scrapeInfo(html: html, htmlKey: "<title>", htmlStopKey: " | Beer")
                beerRating = self.scrapeInfo(html: html, htmlKey: "ba-ravg\">", htmlStopKey: "<")
                numBeerReviews = self.scrapeInfo(html: html, htmlKey: "ba-ratings\">", htmlStopKey: "<")
                if let beerAbvOp = self.scrapeInfo(html: html, htmlKey: "(ABV):</b>", htmlStopKey: "<") {
                    beerAbv = beerAbvOp.trimmingCharacters(in: CharacterSet.init(charactersIn: " \n"))
                }
                completion(BeerStats(beerName: beerName, rating: beerRating, numRatings: numBeerReviews, abv: beerAbv))
            }
        }
    }
    
    private func scrapeInfo(html: String, htmlKey: String, htmlStopKey: String) -> String? {
        if let index = html.endIndex(of: htmlKey) {
            let substring = html[index...]
            let stringUncut = String(substring)
            if let endIndex = stringUncut.index(of: htmlStopKey) {
                let scrappedInfo = stringUncut[..<endIndex]
                return String(scrappedInfo)
            }
        }
        return nil
    }
    
    private func pullBeerAdvPageFromSearch(html: String, htmlKey: String) -> String? {
        print("Here 4")
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
