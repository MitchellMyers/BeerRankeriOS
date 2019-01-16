//
//  BeerInfoTableViewController.swift
//  BeerRanker
//
//  Created by Mitchell Myers on 1/15/19.
//  Copyright © 2019 BreMy Software. All rights reserved.
//

import Foundation
import UIKit

class BeerInfoTableViewController: UITableViewController {
    
    var beersToSearch : [String] = []
    var webScrapingService : WebScrapingService = WebScrapingService()
    var allBeerInfoTupples = [(String?, String?, String?)]()
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.findBeerRatings() { response in
//                        self.allBeerInfoTupples = response
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.findBeerRatings() { response in
//            self.allBeerInfoTupples = response
//        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.allBeerInfoTupples.count)
        return self.allBeerInfoTupples.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "beerInfoCell", for: indexPath)
        
        cell.textLabel?.text = self.allBeerInfoTupples[indexPath.row].0
        
        return cell
    }
    
//    private func findBeerRatings(completion: @escaping ([(String?, String?, String?)]) -> Void) {
//        var beerInfoTupples = [(String?, String?, String?)]()
//        for beerTitle in beersToSearch {
//            self.webScrapingService.scrapeGoogleSearch(beerPhraseToSearch: beerTitle) { response in
//                if let beerAdvUrl = response {
//                    self.webScrapingService.scrapeBeerAdvocate(beerAdvUrl: beerAdvUrl) { response in
//                        print(response)
//                        beerInfoTupples.append(response)
//                    }
//                }
//            }
//        }
//        completion(beerInfoTupples)
//    }
    
}
