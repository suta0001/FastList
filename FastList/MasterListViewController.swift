//
//  MasterListViewController.swift
//  FastList
//
//  Created by Abdullah on 1/28/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import CoreData

class MasterListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    var cellContent = [String]()
    var activeCell = String()
    
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
    
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            let deleteValue = cellContent[indexPath.row]
            
            cellContent.remove(at: indexPath.row)
            
            table.reloadData()
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
            
            request.predicate = NSPredicate(format: "name = %@", deleteValue)
            
            request.returnsObjectsAsFaults = false
            
            
            do {
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if (result.value(forKey: "name") as? String) != nil {
                            
                            context.delete(result)
                            
                            do {
                                try context.save()
                            } catch {
                                print("There was an error saving after deleting item")
                            }
                        }
                        
                    }
                }
            } catch {
                print("Error deleting item")
            }
            
        }
    }

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        activeCell = cellContent[indexPath.row]
        print(activeCell)
        performSegue(withIdentifier: "editItem", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editItem" {
            
            let addItemViewController = segue.destination as! AddItemViewController
            
            print("Active Value is " + activeCell)
            
            addItemViewController.activeCell = activeCell
            
            
            let deleteValue = activeCell
            
            table.reloadData()
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
            
            request.predicate = NSPredicate(format: "name = %@", deleteValue)
            
            request.returnsObjectsAsFaults = false
            
            
            do {
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if (result.value(forKey: "name") as? String) != nil {
                            
                            context.delete(result)
                            
                            do {
                                try context.save()
                            } catch {
                                print("There was an error saving after deleting item")
                            }
                        }
                        
                    }
                }
            } catch {
                print("Error deleting item")
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        print("Master List View Controller")

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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
