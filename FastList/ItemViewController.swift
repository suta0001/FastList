//
//  ItemViewController.swift
//  FastList
//
//  Created by Abdullah Syed and Agustinus Sutandi on 1/28/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import CoreData

protocol LocationInfo{
    func sendValue(title:String, longitude:Double, latitude:Double)
}

class ItemViewController: UIViewController, UITextFieldDelegate {

    
    // MARK: - Properties
    
    var tempLocationLongitude = 0.0
    var tempLocationLatitude = 0.0
    var tempLocationTitle = ""
    var tempLocationChanged = false
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var dueDate: UIDatePicker!
    @IBOutlet weak var hasDueDate: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var locationLabel: UIButton!
    weak var item: Item?
    weak var location: Location?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        itemName.delegate = self
        locationLabel.setTitle("Select Location", for: [])
        // When editing an existing Item, need to use passed info.
        if let item = item {
            itemName.text = item.name
            if(item.locationTitle != "") {
                locationLabel.setTitle(item.locationTitle, for: [])
            } else {
                locationLabel.setTitle("Select Location", for: [])
            }
            if item.dueDate == nil {
                hasDueDate.isOn = false
                dueDate.setDate(Date(), animated: true)
            } else {
                hasDueDate.isOn = true
                dueDate.setDate(item.dueDate as! Date, animated: true)
            }
        }
        dueDateLabel.text = formatDateLabel(date: dueDate.date)


        // Update Save button state.
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - UIKit Overrides
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Keyboard disappears when tapped outside the text field.
        self.view.endEditing(true)
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        itemName.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }

    
    // MARK: - Actions

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleDueDateSwitch(_ sender: UISwitch) {
        hasDueDate.setOn(!hasDueDate.isOn, animated: true)
    }
    
    @IBAction func changeDueDate(_ sender: UIDatePicker) {
        dueDateLabel.text = formatDateLabel(date: sender.date)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let name = itemName.text ?? ""
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        if item == nil {
            item = (NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedObjectContext) as! Item)
            item!.isCompleted = false
            item!.creationDate = Date() as NSDate
            item!.completedDate = nil
            item!.hasDueDate = 0
            item!.locationTitle = ""
            
        }
        
        item!.name = name
        if(tempLocationChanged) {
            item!.locationTitle = tempLocationTitle
        }
        

        if hasDueDate.isOn {
            item!.dueDate = dueDate.date as NSDate
            item!.hasDueDate = 1
        } else {
            item!.dueDate = nil
            item!.hasDueDate = 0
        }
        
        if(tempLocationTitle != ""){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Item")
        request.predicate = NSPredicate(format: "locationTitle != %@",tempLocationTitle)
        request.returnsObjectsAsFaults = false
        do {
            let results = try managedObjectContext.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if var count = result.value(forKey: "count") as? Int32 {
                        count = count + 1;
                        result.setValue(count, forKey: "count")
                    }
                }
            } else {
                location = (NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext) as! Location)
                location!.locationTitle = tempLocationTitle
                location!.locationLatitude = tempLocationLatitude
                location!.locationLongitude = tempLocationLongitude
                location!.count = 1
                appDelegate.startMonitoring(title: tempLocationTitle, longitude: tempLocationLatitude, latitude: tempLocationLongitude)

            }
        } catch {
            
        }
        }
        
      
        appDelegate.saveContext()
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "LocationSelect":
            guard let itemViewController = (segue.destination as? UINavigationController)?.topViewController as? LocationSelectViewController else {
                fatalError("Destination not valid: \(segue.destination)")
            }
            
            itemViewController.LocationInfoDelegate = self
        default:
            fatalError("Invalid segue: \(segue.identifier)")
        }
    }
    
    // MARK: - Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = itemName.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    private func formatDateLabel(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}

extension ItemViewController:LocationInfo {
    
    func sendValue(title: String, longitude: Double, latitude: Double) {
        tempLocationLongitude = longitude
        tempLocationLatitude = latitude
        tempLocationTitle = title
        tempLocationChanged = true;
        print("\(tempLocationTitle)")
        if(tempLocationTitle != "") {
            locationLabel.setTitle(tempLocationTitle, for: [])
        }
    }
}
