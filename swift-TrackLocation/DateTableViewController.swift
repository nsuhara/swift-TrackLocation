//
//  DateTableViewController.swift
//  swift-TrackLocation
//
//  Created by nsuhara on 2018/11/24.
//  Copyright © 2018 nsuhara. All rights reserved.
//

import UIKit

class DateTableViewController: UITableViewController {

    struct UserDefaultsStandardStruct {
        let forKey = "com.nsuhara.swift-TrackLocation"
        let standard = UserDefaults.standard
        var date: [String]!
    }
    
    var Database = UserDefaultsStandardStruct()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize.
        loadData()
    }

    private func loadData() {
        if Database.standard.object(forKey: Database.forKey) == nil {
            Database.date = [String]()
        } else {
            Database.date = (Database.standard.dictionary(forKey: Database.forKey) as! [String: [String: [String: Double]]]).keys.sorted()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Database.date.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifierDate", for: indexPath)
        cell.textLabel?.text = Database.date![indexPath.row]
        return cell
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        // Prepare for moving to time table view.
        if identifier == "identifierTime" {
            let timeTableViewController = segue.destination as! TimeTableViewController
            timeTableViewController.Database.date = Database.date![(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }

    @IBAction func onTouchClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
