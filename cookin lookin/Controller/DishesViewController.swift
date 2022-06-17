//
//  ViewController.swift
//  cookin lookin
//
//  Created by pseq on 16.06.2022.
//

import UIKit
import CoreData

class DishesViewController: UITableViewController {

    var dishesArr = [Dishes]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //MARK: TableView stuff -
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dishesArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DishCell", for: indexPath)
        let dish = dishesArr[indexPath.item]
        
        // todo заменить deprecated textLabel 
        cell.textLabel?.text = dish.name
        
        return cell
    }
}

