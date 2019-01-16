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
    
    var allBeerStats = [BeerStats]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.allBeerStats = allBeerStats.sorted(by: {
            let rateOne = $0.rating ?? "0.0"
            let rateTwo = $1.rating ?? "0.0"
            return rateOne.floatValue > rateTwo.floatValue
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allBeerStats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "beerInfoCell", for: indexPath)
        let beerStats = self.allBeerStats[indexPath.row]
        let beerRating = beerStats.rating ?? "N/A"
        let beerNumRatings = beerStats.numRatings ?? "N/A"
        let beerAbv = beerStats.abv ?? "N/A"
        let beerDetailString = "Rating: " + beerRating + " | Number of Ratings: " + beerNumRatings + " | ABV: " + beerAbv
        cell.textLabel?.text = beerStats.beerName
        cell.detailTextLabel?.text = beerDetailString
        
        return cell
    }
    
}
