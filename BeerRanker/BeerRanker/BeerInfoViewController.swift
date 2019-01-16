//
//  BeerInfoViewController.swift
//  BeerRanker
//
//  Created by Mitchell Myers on 1/14/19.
//  Copyright © 2019 BreMy Software. All rights reserved.
//

import UIKit

class BeerInfoViewController: UIViewController {
    
    
    @IBOutlet weak var beerInfoLabel: UILabel!
    var beersToSearch : [String] = []
    var webScrapingService : WebScrapingService = WebScrapingService()
    
    override func viewDidLoad() {
        // Do something
        findBeerRatings()
    }
    
    private func findBeerRatings() {
        for beerTitle in beersToSearch {
            
            self.webScrapingService.scrapeGoogleSearch(beerPhraseToSearch: beerTitle) { response in
                if let beerAdvUrl = response {
                    self.webScrapingService.scrapeBeerAdvocate(beerAdvUrl: beerAdvUrl) { response in
                        print(beerTitle)
                        print(response)
                    }
                }
            }
        }
    }
    
}
