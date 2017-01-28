//
//  ViewController.swift
//  FastList
//
//  Created by Agustinus Sutandi and Abdullah Syed on 1/25/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cellContent = [String]()

    @IBAction func addPressed(_ sender: Any) {
        print("Add button pressed")
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cellContent.count
        
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = cellContent[indexPath.row]
        
        return cell
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("FastList View Controller")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        //let itemAdd = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let Item = result.value(forKey: "name") as? String {
                        print(Item)
                        cellContent.append(Item)
                    }
                }
            } else {
                
                print("No results")
            }
        } catch {
            
            print("Couldn't fetch")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

