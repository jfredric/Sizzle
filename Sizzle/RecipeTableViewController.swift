//
//  RecipeTableViewController.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/27/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import UIKit
import AVFoundation

class RecipeTableViewController: UITableViewController {
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var currentRecipe: Recipe!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentRecipe.totalSteps
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = (tableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell-ID", for: indexPath) as? HomeTableViewCell) else {
            fatalError("Error [Recipe]: Could not cast cell as HomeTableViewCell")
        }
        
        // Configure the cell...
        cell.titleLabel.text = currentRecipe.steps[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let speechText = currentRecipe.steps[indexPath.row]
        let speechUtterance = AVSpeechUtterance(string: speechText)
        speechSynthesizer.speak(speechUtterance)
    }

}
