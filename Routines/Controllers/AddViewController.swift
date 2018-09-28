//
//  AddViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/27/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift

class AddViewController: UIViewController, UINavigationControllerDelegate {
    
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelTapped))
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destination = segue.destination as! TableViewController
        destination.tableView.reloadData()
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    

}
