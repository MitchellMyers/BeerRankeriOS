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
    var beerInfo: String?
    
    override func viewDidLoad() {
        // Do something
        let updatedInfo = beerInfo ?? "Not long enough"
        beerInfoLabel.text = updatedInfo
//        print(updatedInfo)
    }
    
}
