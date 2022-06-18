//
//  IngredientsViewController.swift
//  cookin lookin
//
//  Created by pseq on 18.06.2022.
//

import UIKit
import CoreData

class IngredientsViewController: UITableViewController {

    var ingredsArr = [Ingredients]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //loadDishes()
    }
}
