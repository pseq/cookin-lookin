//
//  ViewController.swift
//  cookin lookin
//
//  Created by pseq on 16.06.2022.
//

import UIKit
import CoreData

class DishesViewController: UITableViewController {

    //here will be a realm version
    var dishesArr = [Dishes]()
    // костыльная переменная для навигации
    var selectedDish: Dishes?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        //content.image = UIImage(systemName: "circlebadge.fill")
        //content.imageProperties.tintColor = dishCheckout(dish)
        
        let imgV = UIImageView(image: UIImage(systemName: "circlebadge.fill"))
        imgV.tintColor = dishCheckout(dish)
        cell.accessoryView = imgV
        
//        // раскраска ячеек
//        cell.backgroundColor = dishCheckout(dish)
        
        cell.contentConfiguration = content
                
//        // фон ячеек
//        let imageView = UIImageView()
//        let image = UIImage(named: "cell_img")
//        imageView.image = image
//        cell.backgroundView = imageView
        
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
        // сортировка
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            dishesArr = try context.fetch(request)
        } catch {
            print("Error load dishes from CoreData: \(error)")
        }
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
            let newDish = Dishes(context: self.context)
            newDish.name = textField.text ?? ""
            self.dishesArr.append(newDish)
            self.saveDishes()
            
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
        selectedDish = dishesArr[indexPath.row]
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
            [weak self] (action, view, completionHandler) in self?.deleteDish(indexPath.row)
            completionHandler(true)
        }
        swipeDishLeft.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [swipeDishLeft])
    }
    
    func deleteDish (_ dishIndex: Int) {
        context.delete(dishesArr[dishIndex])
        dishesArr.remove(at: dishIndex)
        saveDishes()
    }
    
    
    //MARK: Dish Checkout -
    func dishCheckout(_ dish: Dishes) -> UIColor {
        let requestInStore = Ingredients.fetchRequest() //: NSFetchRequest<Dishes>
        let requestAllCount = Ingredients.fetchRequest() //: NSFetchRequest<Dishes>
        // запросы ингредиентов блюда имеющихся и не имеющихся в наличии
        requestInStore.predicate = NSPredicate(format: "%@ IN dishes.name AND inStore = true", dish.name!)
        requestAllCount.predicate = NSPredicate(format: "%@ IN dishes.name", dish.name!)
        
        var inStoreCount = 0
        var allCount = 0
        
        // считаем ингридиенты имеющиеся и не имеющиеся в наличии для данного блюда
        do {
            inStoreCount = try context.count(for: requestInStore)
            allCount = try context.count(for: requestAllCount)
        } catch {
            print("Error count ingreds in CoreData: \(error)")
        }

//        if allCount == 0 {
//            return .clear
//        } else if inStoreCount == allCount {
//            return UIColor(named: "cellGreen")!
//        } else if Double(inStoreCount)/Double(allCount) < 0.6 {
//            return UIColor(named: "cellRed")!
//        } else {
//            return UIColor(named: "cellYellow")!
//        }
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

