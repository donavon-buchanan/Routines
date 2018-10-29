//
//  TableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
//import Pulsator

class TableViewController: SwipeTableViewController, UITabBarControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func unwindToTableViewController(segue:UIStoryboardSegue){}
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //stopNavBarAnimation(pulsator: addButtonPulsator)
    }
    
    
    // Get the default Realm
    let realm = try! Realm()

    //var segments: Results<Segments>?
    var items: Results<Items>?
    
    //Options Properties
    let optionsRealm = try! Realm()
    var optionsObject: Options?
    //var firstItemAdded: Bool?
    let optionsKey = "optionsKey"
    
//    let dayString = "All Day"
//    let morningString = "Morning"
//    let afternoonString = "Afternoon"
//    let eveningString = "Evening"
//    let nightString = "Night"
    
    let segmentStringArray: [String] = ["Morning", "Afternoon", "Evening", "Night", "All Day"]
    
    //Set segment after adding an item
    var setSegment: Int?
    func changeSegment() {
        if let segment = setSegment {
            reloadTableView()
            tabBarController?.selectedIndex = segment
            setSegment = nil
        }
    }
    
    //Add button pulse animation object
//    let addButtonPulsator : Pulsator = Pulsator()
//    let addButtonPulseView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        let footerView = UIView()
        footerView.backgroundColor = .clear
        self.tableView.tableFooterView = footerView
        
        //self.tableView.rowHeight = 54
        
        loadData()

        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tabBarController?.delegate = self
        self.navigationController?.delegate = self
        guard let selectedTab = tabBarController?.selectedIndex else { fatalError() }
        items = loadItems(segment: selectedTab)
        reloadTableView()
        print("Selected tab is \(selectedTab)")
        
        //TODO: !!!! check if this should be moved !!!!
        //setupPulsingButtonView(pulsator: addButtonPulsator, pulseView: addButtonPulseView)
        
        //load options
        loadOptions()
        
        //TODO: These seem similar in pupose. Maybe call the animation check from the first item check if firstItemAdded == false
        checkIfFirstItemAdded()
        //checkIfPingAnimationShouldRun()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        changeSegment()
        //checkIfAnimationShouldRun()
    }
    
    //Trying to animate the transition from one tab to another even though I'm only using a single table view. Not yet working
//    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//
//        let fromView: UIView = tabBarController.selectedViewController!.view
//        let toView  : UIView = viewController.view
//        if fromView == toView {
//            return false
//        }
//
//        UIView.transition(from: fromView, to: toView, duration: 0.3, options: UIView.AnimationOptions.transitionCrossDissolve) { (finished:Bool) in
//
//        }
//
//        return true
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
//        var activeSegments = 0
//        for segment in 0...4 {
//            if countForSegment(section: segment) > 0 {
//                activeSegments += 1
//            }
//        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows, always at least 1 for default text
//        if countForSegment(section: section) > 0 {
//            return countForSegment(section: section)
//        } else {
//            return 1
//        }
//        return countForSegment(section: section)
        return self.items?.count ?? 0
    }
    
//    //Segment Titles
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return segmentStringArray[section]
//    }
    
//    TBH, I don't remember why I put this here. But it doesn't seem to be necessary anymore
//    //@available(iOS 11.0, *)
//    func visibleRect(for tableView: UITableView) -> CGRect? {
//        if #available(iOS 11.0, *) {
//            return tableView.safeAreaLayoutGuide.layoutFrame
//        } else {
//            // Fallback on earlier versions
//            let topInset = navigationController?.navigationBar.frame.height ?? 0
//            let bottomInset = navigationController?.toolbar?.frame.height ?? 0
//            let bounds = tableView.bounds
//
//            return CGRect(x: bounds.origin.x, y: bounds.origin.y + topInset, width: bounds.width, height: bounds.height - bottomInset)
//        }
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        guard let item = self.items?[indexPath.row] else { fatalError() }
//        if item.segment == section {
//            cell.textLabel?.text = item.title
//        }
        cell.textLabel?.text = item.title
        
        //old code for showing glyphs on cells per section
//        let imageView = UIImageView(frame: CGRect(x: 7, y: 7, width: 40, height: 40))
//
//        switch section {
//        case 1:
//            imageView.image = UIImage(named: "afternoon")
//            cell.backgroundView = UIView()
//            cell.backgroundView!.addSubview(imageView)
//        case 2:
//            imageView.image = UIImage(named: "evening")
//            cell.backgroundView = UIView()
//            cell.backgroundView!.addSubview(imageView)
//        case 3:
//            imageView.image = UIImage(named: "night")
//            cell.backgroundView = UIView()
//            cell.backgroundView!.addSubview(imageView)
//        default:
//            imageView.image = UIImage(named: "morning")
//            cell.backgroundView = UIView()
//            cell.backgroundView!.addSubview(imageView)
//        }
//
//        cell.indentationWidth = 10
//        cell.indentationLevel = 3
//        cell.backgroundColor = .none
//        //default text if no items in segment
//        if countForSegment(section: section) > 0 {
//            let item = performSearch(segment: section)[indexPath.row]
//            if item.segment == section {
//                cell.textLabel?.text = item.title
//            }
//        } else {
//            cell.textLabel?.text = "Your \(segmentStringArray[indexPath.section].lowercased()) is clear!"
//        }
        
        return cell
    }
    
//    //Only make cells swipeable if it's actually referencing an existing item object
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .right else { return nil}
//
//        let section = indexPath.section
//        let itemCount = countForSegment(section: section)
//
//        if itemCount > 0 {
//            let completeAction = SwipeAction(style: .destructive, title: "Complete") { (action, indexPath) in
//                // handle action by updating model with deletion
//                self.updateModel(at: indexPath)
//                //action.fulfill(with: .reset)
//                //tableView.reloadData()
//                //editActionsOptionsForRowAt takes care of the table reload
//            }
//            return [completeAction]
//        } else {
//            return []
//        }
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
//        let destinationVC = segue.destination as! AddTableViewController
//        // Pass the selected object to the new view controller.
//        if let indexPath = tableView.indexPathForSelectedRow {
//            let section = tableView.indexPathForSelectedRow?.section
//            destinationVC.item = performSearch(segment: section!)[indexPath.row]
//        }
//
//        //Set right bar item as "Save"
//        destinationVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: destinationVC, action: #selector(destinationVC.saveButtonPressed))
//        //Disable button until all values are filled
//        destinationVC.navigationItem.rightBarButtonItem?.isEnabled = false
        
        if segue.identifier == "addSegue" {
            //TODO: Figure out why number of pulses seems to change after this
            //stopNavBarAnimation(pulsator: addButtonPulsator)
            
            let destination = segue.destination as! AddTableViewController
            //set segment based on current tab
            guard let selectedTab = tabBarController?.selectedIndex else { fatalError() }
            destination.editingSegment = selectedTab
            //Set right bar item as "Save"
            destination.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: destination, action: #selector(destination.saveButtonPressed))
            //Disable button until all values are filled
            destination.navigationItem.rightBarButtonItem?.isEnabled = false
        }

        if segue.identifier == "editSegue" {
            let destination = segue.destination as! AddTableViewController
            //Set right bar item as "Save"
            destination.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: destination, action: #selector(destination.saveButtonPressed))
            //Disable button until a value is changed
            destination.navigationItem.rightBarButtonItem?.isEnabled = false
            //pass in current item
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let item = self.items?[indexPath.row] else { fatalError() }
                destination.item = item
            }
        }
    }
    

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let item = items?[indexPath.row] {
//            do {
//                try realm.write {
//                    item.completed = !item.completed
//                }
//            } catch {
//                print("Error saving completed status: \(error)")
//            }
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//        tableView.reloadData()
//    }
    
    //MARK: - Model Manipulation Methods
    //Load segments
//    func loadSegments() {
//        segments = realm.objects(Segments.self)
//        //self.tableView.reloadData()
//    }
    
    func loadData() {
        items = realm.objects(Items.self)
    }
    
    //Filter items to relevant segment and return those items
    func loadItems(segment: Int) -> Results<Items> {
        //        guard let filteredItems = items?.filter("segment = \(segment)").sorted(byKeyPath: "dateModified", ascending: true) else { fatalError() }
        //TODO: This could probably still be more efficient. Find a way to load the items minimally
        guard let filteredItems = items?.filter("segment = \(segment)") else { fatalError() }
        print("loadItems run")
        //self.tableView.reloadData()
        return filteredItems
    }
    
    //Override empty delete func from super
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)

        guard let items = self.items else { fatalError() }
        let item = items[indexPath.row]
        
        print("Deleting item with title: \(String(describing: item.title))")
        do {
            try self.realm.write {
                self.realm.delete(item)
            }
        } catch {
            print("Error deleting item: \(error)")
        }
    }
    
    //TODO: Animate reload - not working as intended
    func reloadTableView() {
//        let range = NSMakeRange(0, self.tableView.numberOfSections)
//        let sections = NSIndexSet(indexesIn: range)
//        self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        self.tableView.reloadData()
        setViewBackgroundGraphic()
        //checkIfAnimationShouldRun()
    }
    
//    //Ask for which section and count the items matching that section index to segment property
//    func countForSegment(section: Int) -> Int {
//        loadItems()
//        let count = performSearch(segment: section).count
//        print("countForSegment run")
//        print("count for segment \(section) is \(count)")
//        return count
//    }
    
    //Set background graphic if there's no cells in the view.
    //Easiest method is to just use the filtered items count
    let backgroundImage = UIImageView()
    func setViewBackgroundGraphic() {
        backgroundImage.image = UIImage(imageLiteralResourceName: "inlay")
        backgroundImage.contentMode = .scaleAspectFit
        
        if self.tableView.subviews.contains(backgroundImage) {
            return
        } else {
            self.tableView.addSubview(backgroundImage)
            //let IMAGE_SIZE:CGFloat = UIScreen.main.bounds.width * 0.65
            let navBarHeight = self.navigationController?.navigationBar.bounds.height
            let tabBarHeight = self.tabBarController?.tabBar.bounds.height
            //I don't honestly know why this next line works. But it does, pretty well. It was mostly trial and error.
            let offsetHeight = (tabBarHeight! + navBarHeight!) * 0.7
            let OFFSET:CGFloat = -offsetHeight
            
            backgroundImage.translatesAutoresizingMaskIntoConstraints = false
            //backgroundImage.widthAnchor.constraint(equalToConstant: IMAGE_SIZE).isActive = true
            //backgroundImage.heightAnchor.constraint(equalToConstant: IMAGE_SIZE).isActive = true
            backgroundImage.centerXAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor).isActive = true
            backgroundImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: OFFSET).isActive = true
            backgroundImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 20).isActive = true
            backgroundImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        }
    }
    
    //MARK: - Navigation Bar Customizations

    
//    func checkIfPingAnimationShouldRun() {
//
//        if let itemAdded = optionsObject?.firstItemAdded {
//            print("First item status: \(itemAdded)")
//            if itemAdded == false {
//                //print("Running ping animation")
//                //startNavBarAnimation(pulsator: addButtonPulsator)
//            } else {
//
//            }
//        }
//
//    }
    
//    func checkIfAnimationShouldRun() {
//        let itemsCount = realm.objects(Items.self).count
//        print("Checking count for animation: \(itemsCount)")
//        if itemsCount < 1 {
//            startNavBarAnimation(pulsator: addButtonPulsator)
//        } else {
//            stopNavBarAnimation(pulsator: addButtonPulsator)
//        }
//    }
//
//    func setupPulsingButtonView(pulsator: Pulsator, pulseView: UIView) {
//
//        let navbar = navigationController!.navigationBar
//        guard let rightButtonView = self.addBarButtonItem.value(forKey: "view") as? UIView else {
//            fatalError("Couldn't pull view from button")
//        }
//        let addButtonView = UIView()
//        addButtonView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//        addButtonView.contentMode = .scaleAspectFit
//        addButtonView.backgroundColor = .red
//        let addButtonItem = UIBarButtonItem(customView: addButtonView)
//        let buttonImageView = UIImageView(image: UIImage(imageLiteralResourceName: "add button"))
//        addButtonView.addSubview(buttonImageView)
//        buttonImageView.translatesAutoresizingMaskIntoConstraints = false
//        buttonImageView.centerXAnchor.constraint(equalTo: addButtonView.leftAnchor).isActive = true
//        buttonImageView.centerYAnchor.constraint(equalTo: addButtonView.centerYAnchor).isActive = true
//
//
//        self.navigationItem.rightBarButtonItem = addButtonItem
//
//        addButtonView.addSubview(pulseView)
//        let navWidth = navbar.bounds.width
//        print("navWidth: \(navWidth)")
    
//        let screenWidth = UIScreen.main.bounds.width
//        print("screenWidth: \(screenWidth)")
//        var safeAreaRight: CGFloat = 0
//        if #available(iOS 11.0, *) {
//            safeAreaRight = navbar.safeAreaLayoutGuide.layoutFrame.size.width
//        } else {
//            safeAreaRight = 10// Fallback on earlier versions
//        }
//        print("safeAreaRight: \(safeAreaRight)")
//        navbar.addSubview(pulseView)
//        pulseView.layer.addSublayer(pulsator)
//        pulseView.translatesAutoresizingMaskIntoConstraints = false
//        pulseView.rightAnchor.constraint(equalTo: navbar.rightAnchor, constant: safeAreaRight).isActive = true
//        pulseView.centerYAnchor.constraint(equalTo: navbar.centerYAnchor).isActive = true
//        pulseView.layer.addSublayer(pulsator)
//        print("pulsing view set up")
//
//    }
//
//    func startNavBarAnimation(pulsator: Pulsator) {
//        print("running animation")
//        // Create object after view appears then run func
//        pulsator.radius = 80.0
//        pulsator.numPulse = 3
//        pulsator.pulseInterval = 3
//        pulsator.timingFunction = CAMediaTimingFunction(name: .easeOut)
//        //pulsator.animationDuration = 2.5
//        pulsator.start()
//    }
//
//    func stopNavBarAnimation(pulsator: Pulsator) {
//        print("stopping animation")
//        pulsator.stop()
//    }
    
}
