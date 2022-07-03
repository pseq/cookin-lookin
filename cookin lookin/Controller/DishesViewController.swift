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
        
        //TODO: заменить deprecated textLabel
//        cell.textLabel?.text = dish.name
        
        var content = cell.defaultContentConfiguration()
        content.text = dish.name
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
    
    //MARK: Addin dishes -
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
//        dishesArr[indexPath.row]
        let destinationVC = segue.destination as! IngredientsViewController
        if let indexPath = tableView.indexPathForSelectedRow {
//            print("LOOK AT THIS SHIT \(someshit ?? "NOTHIN SHIT")")
            destinationVC.selectedDish = dishesArr[indexPath.row]
//            print("HERES CAT ITEMS: \(categoryArray[indexPath.row].items)")
        }
        
    }
    
}

