//
//  AddItemViewController.swift
//  FastList
//
//  Created by Abdullah on 1/28/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import CoreData

class AddItemViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var itemNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Add Item View Controller")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButton(_ sender: Any) {
        print(itemNameTextField.text ?? "Error")
    }
    
    // Keyboard disappears when tapped outside the text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Keyboard disappers after enter button pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        itemNameTextField.resignFirstResponder()
        
        return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(itemNameTextField.text ?? "Error")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let itemAdd = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)
        
        itemAdd.setValue(itemNameTextField.text ?? "Error", forKey: "name")
        
        do {
            try context.save()
            
            print("Saved")
        } catch {
            
            print("There was an error")
        }
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
