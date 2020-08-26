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
    private var missionPatchImageView: UIImageView = UIImageView()
    private var missionNameLabel: UILabel = UILabel()
    private var rocketNameLabel: UILabel = UILabel()
    private var launchSiteLabel: UILabel = UILabel()
    private var bookCancelButton: UIBarButtonItem = UIBarButtonItem(title: "Book Now!", style: .plain, target: nil, action: nil)
    
    private var launch: LaunchDetailsQuery.Data.Launch? {
        didSet {
            configureView()
        }
    }
    
    var launchID: GraphQLID? {
        didSet {
            loadLaunchDetails()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        missionPatchImageView.translatesAutoresizingMaskIntoConstraints = false
        missionNameLabel.translatesAutoresizingMaskIntoConstraints = false
        rocketNameLabel.translatesAutoresizingMaskIntoConstraints = false
        launchSiteLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let outerStack = UIStackView()
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        outerStack.axis = .horizontal
        outerStack.alignment = .center
        outerStack.distribution = .fill
        outerStack.spacing = 20
        
        view.addSubview(outerStack)
        outerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        outerStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        outerStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        outerStack.addArrangedSubview(missionPatchImageView)
        missionPatchImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
        missionPatchImageView.widthAnchor.constraint(equalTo: missionPatchImageView.heightAnchor, multiplier: 1.0).isActive = true
        
        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.alignment = .fill
        innerStack.distribution = .equalSpacing
        innerStack.spacing = 8
        innerStack.addArrangedSubview(missionNameLabel)
        innerStack.addArrangedSubview(rocketNameLabel)
        innerStack.addArrangedSubview(launchSiteLabel)
        
        outerStack.addArrangedSubview(innerStack)
        
        navigationController?.navigationItem.rightBarButtonItem = bookCancelButton
        
        // Label customize
        missionNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        launchSiteLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        rocketNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        missionNameLabel.text = "Loading..."
        launchSiteLabel.text = nil
        rocketNameLabel.text = nil
    }
    
    
    func configureView() {
        // Update the user interface for the detail item.
        guard let launch = launch else {
            return
        }
        
        self.missionNameLabel.text = launch.mission?.name
        self.title = launch.mission?.name
        
        let placeholder = UIImage(named: "placeholder")!
        
        if let missionPatch = launch.mission?.missionPatch {
            self.missionPatchImageView.sd_setImage(with: URL(string: missionPatch)!, placeholderImage: placeholder)
        } else {
            self.missionPatchImageView.image = placeholder
        }
        
        if let site = launch.site {
            self.launchSiteLabel.text = "Launching from \(site)"
        } else {
            self.launchSiteLabel.text = nil
        }
        
        if
            let rocketName = launch.rocket?.name ,
            let rocketType = launch.rocket?.type {
            self.rocketNameLabel.text = "🚀 \(rocketName) (\(rocketType))"
        } else {
            self.rocketNameLabel.text = nil
        }
        
        if launch.isBooked {
            self.bookCancelButton.title = "Cancel trip"
            self.bookCancelButton.tintColor = .red
        } else {
            self.bookCancelButton.title = "Book now!"
            self.bookCancelButton.tintColor = self.view.tintColor
        }
    }
    
    private func loadLaunchDetails() {
        guard let launchID = launchID, launchID != launch?.id else { return }
        Network.shared.apollo.fetch(query: LaunchDetailsQuery(id: launchID)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("NETWORK ERROR: \(error)")
            case .success(let graphQLResult):
                if let launch = graphQLResult.data?.launch {
                    self.launch = launch
                }
                if let errors = graphQLResult.errors {
                    print("GRAPHQL ERRORS: \(errors)")
                }
            }
        }
    }
    
}

