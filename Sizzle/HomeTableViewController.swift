//
//  HomeTableViewController.swift
//  Sizzle
//
//  Created by Joshua Fredrickson on 11/27/17.
//  Copyright © 2017 Joshua Fredrickson. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var recipeList: [Recipe] = [Recipe.testEggs(),Recipe.short(),Recipe.long()]

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
        return recipeList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = (tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell-ID", for: indexPath) as? HomeTableViewCell) else {
            fatalError("Error [Home]: Could not cast cell as HomeTableViewCell")
        }

        // Configure the cell...
        cell.titleLabel.text = recipeList[indexPath.row].title

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "listToRecipeSegue-ID", sender: indexPath)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let indexPath = sender as! IndexPath
        let recipeViewController = segue.destination as! RecipeTableViewController
        
        recipeViewController.currentRecipe = recipeList[indexPath.row]
    }
    

}
