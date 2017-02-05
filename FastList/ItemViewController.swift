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
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    weak var item: Item?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        itemName.delegate = self
        
        // When editing an existing Item, need to use passed info.
        if let item = item {
            itemName.text = item.name
        }

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
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let name = itemName.text ?? ""
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let item = self.item ?? (NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedObjectContext) as? Item)
        
        item!.name = name
        item!.locationLongitude = tempLocationLongitude
        item!.locationLatitude = tempLocationLatitude
        item!.locationTitle = tempLocationTitle
        
        print("\(item!.name) \(item!.locationLatitude) \(item!.locationLongitude) \(item!.locationTitle)")

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
    
}

extension ItemViewController:LocationInfo {
    
    func sendValue(title: String, longitude: Double, latitude: Double) {
        tempLocationLongitude = longitude
        tempLocationLatitude = latitude
        tempLocationTitle = title
        print("\(tempLocationTitle)")
    }
}