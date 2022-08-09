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
        loadDishes()
    }

    //MARK: TableView stuff -
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dishesArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DishCell", for: indexPath)
        let dish = dishesArr[indexPath.item]
        
        var content = cell.defaultContentConfiguration()
        content.text = dish.name
        cell.backgroundColor = dishCheckout(dish)
        cell.contentConfiguration = content
        
        return cell
    }
    
    //MARK: Data manipulation stuff -
    func saveDishes() {
        do {
            try context.save()
        } catch {
            print("Error save dishes to CoreData: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadDishes() {
        let request = Dishes.fetchRequest() //: NSFetchRequest<Dishes>
        do {
            dishesArr = try context.fetch(request)
        } catch {
            print("Error load dishes from CoreData: \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: Buttons -
    @IBAction func ingredsBtnPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showIngreds", sender: self)
    }
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()

        let alert = UIAlertController(title: "Add a dish", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newDish = Dishes(context: self.context)
            newDish.name = textField.text ?? ""
            self.dishesArr.append(newDish)
            self.saveDishes()
            
            self.performSegue(withIdentifier: "showIngreds", sender: self)
        }
        
        let actionDis = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }

        alert.addTextField { (alerTextField) in
            alerTextField.placeholder = "Type new dish"
            textField = alerTextField
        }

        alert.addAction(action)
        alert.addAction(actionDis)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Select Dish Methods -
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showIngreds", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! IngredientsViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedDish = dishesArr[indexPath.row]
//            print("DISH COMP: \(dishesArr[indexPath.row].dishComponents)")
        }
        
    }
    
    //MARK: Dish Checkout -
    func dishCheckout(_ dish: Dishes) -> UIColor {
        let requestInStore = Ingredients.fetchRequest() //: NSFetchRequest<Dishes>
        let requestAllCount = Ingredients.fetchRequest() //: NSFetchRequest<Dishes>
        requestInStore.predicate = NSPredicate(format: "%@ IN dishes.name AND inStore = true", dish.name!)
        requestAllCount.predicate = NSPredicate(format: "%@ IN dishes.name", dish.name!)
//        var ingredsArr = [Ingredients]()

//        do {
//            ingredsArr = try context.fetch(request)
//        } catch {
//            print("Error load ingreds from CoreData: \(error)")
//        }
        
        var inStoreCount = 0
        var allCount = 0
        
        do {
            inStoreCount = try context.count(for: requestInStore)
            allCount = try context.count(for: requestAllCount)
        } catch {
            print("Error count ingreds in CoreData: \(error)")
        }
        
        switch (inStoreCount - outStoreCount) {
        case <#pattern#>:
            <#code#>
        default:
            <#code#>
        }
        
        if ingredsArr.count > 0 {
            return .green
        } else {
            return .red
        }
    }
}

