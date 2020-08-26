//
//  DetailViewController.swift
//  RocketReserver
//
//  Created by Chatchai Lokniyom on 2020/08/26.
//  Copyright © 2020 RocketReserver. All rights reserved.
//

import UIKit
import Apollo

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var launchID: GraphQLID? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
      // Update the user interface for the detail item.
      guard
        let label = self.detailDescriptionLabel,
        let id = self.launchID else {
          return
      }

      label.text = "Launch \(id)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    

}

