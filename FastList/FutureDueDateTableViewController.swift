//
//  FutureDueDateTableViewController.swift
//  FastList
//
//  Created by Agustinus Sutandi on 2/16/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit

class FutureDueDateTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    let futureDueDates = [
        ("15 minutes", 15 * 60),
        ("30 minutes", 30 * 60),
        ("45 minutes", 45 * 60),
        ("60 minutes", 60 * 60),
        ("1 day", 24 * 60 * 60),
        ("1 week", 7 * 24 * 60 * 60),
        ("1 year", 52 * 7 * 24 * 60 * 60)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setCheckmark()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return futureDueDates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FutureDueDateCell", for: indexPath)
        cell.textLabel?.text = futureDueDates[indexPath.row].0

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        let futureDateSetting = futureDueDates[indexPath.row]
        UserDefaults.standard.set(futureDateSetting.0, forKey: "futureDateToDisplayInSeconds")
        UserDefaults.standard.set(futureDateSetting.1, forKey: "futureDateValueInSeconds")
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.none
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Helper Functions
    
    private func setCheckmark() {
        let savedDueDate = UserDefaults.standard.string(forKey: "futureDateToDisplayInSeconds") ?? "1 week"
        let rowIndex = indexOf(toFind: savedDueDate, in: futureDueDates)
        let indexPath = IndexPath(row: rowIndex, section: 0)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    
    private func indexOf(toFind: String, in array: [(String, Int)]) -> Int {
        var index = 0
        while index < array.count {
            if toFind == array[index].0 {
                break
            }
            index += 1
        }
        return index
    }
}
