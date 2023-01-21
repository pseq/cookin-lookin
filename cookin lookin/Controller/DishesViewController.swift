//
//  ViewController.swift
//  cookin lookin
//
//  Created by pseq on 16.06.2022.
//

import UIKit
import RealmSwift
import ChameleonFramework

class DishesViewController: UITableViewController {

    let realm = try! Realm()
    var dishes: Results<Dishes>?
    
    // костыльная переменная для навигации
    var selectedDish: Dishes?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDishes()
    }

    //MARK: TableView stuff -
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dishes?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DishCell", for: indexPath)
        let dish = dishes?[indexPath.item]
        
        var content = cell.defaultContentConfiguration()
        
        content.text = dish?.name ?? "No dishes"
        
        // раскраска ячеек
        if let realDish = dish {
            let imgV = UIImageView(image: UIImage(systemName: "circlebadge.fill"))
            imgV.tintColor = dishCheckout(realDish)
            cell.accessoryView = imgV
            // here we will plays with colors now
            
            
            
//            cell.accessoryView?.layer.borderColor = UIColor.black.cgColor
//            cell.accessoryView?.layer.borderWidth = 3
//
            cell.backgroundColor = RandomFlatColor() 
            
            cell.contentConfiguration = content
        }
        
        return cell
    }
    
    //MARK: Data manipulation stuff -
    func save(dish: Dishes) {
        do {
            try realm.write {
                realm.add(dish)
            }
        } catch {
            print("Error save dishes to Realm: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadDishes() {
        dishes = realm.objects(Dishes.self).sorted(byKeyPath: "name")
        tableView.reloadData()
    }
    
    //MARK: Buttons -
    @IBAction func ingredsBtnPressed(_ sender: UIBarButtonItem) {
        //показать все ингридиенты
        selectedDish = nil
        performSegue(withIdentifier: "showIngreds", sender: self)
    }
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()

        let alert = UIAlertController(title: "Add a dish", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newDish = Dishes()
            newDish.name = textField.text ?? ""
            self.save(dish: newDish)
            
            //показать ингридиенты для нового блюда
            self.selectedDish = newDish
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
        //показать ингридиенты выбранного блюда
        selectedDish = dishes![indexPath.row]
        performSegue(withIdentifier: "showIngreds", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! IngredientsViewController
        //указывает, какие ингридиенты показывать
        destinationVC.selectedDish = selectedDish
    }
    
    //MARK: Delete Dish -
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let swipeDishLeft = UIContextualAction(style: .normal, title: "Delete") {
            [weak self] (action, view, completionHandler) in self?.deleteDish(self!.dishes![indexPath.row])
            completionHandler(true)
      }
        swipeDishLeft.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [swipeDishLeft])
    }
    
    func deleteDish (_ dish: Dishes) {
        do {
            try realm.write {
                realm.delete(dish)
                tableView.reloadData()
            }
        } catch {
            print("Error delete dish: \(error)")
        }
    }
        
    //MARK: Dish Checkout -
    func dishCheckout(_ dish: Dishes) -> UIColor {
        // считаем ингридиенты имеющиеся и не имеющиеся в наличии для данного блюда
        let inStoreCount = realm.objects(Ingredients.self).filter("%@ IN dishes.name AND inStore = true", dish.name).count
        let allCount = realm.objects(Ingredients.self).filter("%@ IN dishes.name", dish.name).count

        if allCount == 0 {
            return .clear
        } else if inStoreCount == allCount {
            return .green
        } else if Double(inStoreCount)/Double(allCount) < 0.6 {
            return .red
        } else {
            return .yellow
        }
    }
}

