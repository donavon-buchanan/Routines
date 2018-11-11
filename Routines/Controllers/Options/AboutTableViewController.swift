//
//  AboutTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 10/29/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {
    
    @IBOutlet weak var versionNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionNumberLabel.text = setVersionNumberLabel()
        setViewBackgroundGraphic()

    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "versionCell")
//        cell?.textLabel?.text = setVersionNumberLabel()
//        return cell!
//    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int
        switch section {
        case 0:
            numberOfRows = 1
        case 1:
            numberOfRows = 5
        case 2:
            numberOfRows = 1
        default:
            numberOfRows = 0
        }
        
        return numberOfRows
    }
    
    func setVersionNumberLabel() -> String {
        guard let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String else  { fatalError("Failed to get version number")}
        //print("App Version: \(String(describing: appVersion))")
        guard let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as? String else  { fatalError("Failed to get build number")}
        //print("Build NUmber: \(buildNumber)")
        let versionString = "Version: \(appVersion), Build: \(buildNumber)"
        
        //return "fuck you"
        return versionString
    }
    
    //Set background graphic
    func setViewBackgroundGraphic() {
        
        let backgroundImageView = UIImageView()
        let backgroundImage = UIImage(imageLiteralResourceName: "inlay")
        
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFit
        
        self.tableView.backgroundView = backgroundImageView
    }
    
}
