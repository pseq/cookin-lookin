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
    var selectedDish : Dishes? {
        didSet{
            loadIngreds()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadIngreds()
    }

    //MARK: TableView stuff -
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredsArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredCell", for: indexPath)
        let ingredient = ingredsArr[indexPath.item]
        
        var content = cell.defaultContentConfiguration()
        content.text = ingredient.name
        cell.contentConfiguration = content
        cell.accessoryType = ingredient.inStore ? .checkmark: .none
        
        return cell
    }
    
    //MARK: Data manipulation stuff -
    func saveIngreds() {
        do {
            try context.save()
        } catch {
            print("Error save ingreds to CoreData: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadIngreds() {
        let request = Ingredients.fetchRequest() //: NSFetchRequest<Dishes>
        
//        print("LOAD INGREDS - SELECTED.DISH: \(selectedDish!.name!)")

//        request.predicate = NSPredicate(format: "ANY dishes.name MATCHES %@", selectedDish!.name!)
        //потом заменить на выбор предиката из параметров
        if let parentDish = selectedDish {
            request.predicate = NSPredicate(format: "%@ IN dishes.name", parentDish.name!)
        }
        
        do {
            ingredsArr = try context.fetch(request)
        } catch {
            print("Error load ingreds from CoreData: \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: Addin ingreds -
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()

        let alert = UIAlertController(title: "Add a ingredient", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newIngred = Ingredients(context: self.context)
            newIngred.name = textField.text ?? ""
            newIngred.inStore = false
            // добавляем ингредиенту родительское блюдо
            // нужно ли блюду добавить ингредиент, или это случится автоматически?
            // нужно походу
            if let parentDish = self.selectedDish {
                newIngred.addToDishes(parentDish)
                print("ADDIN PARENT DISH \(parentDish.name) TO INGRED \(newIngred.name)")
            }
            print("AND NOW \(newIngred.name) HAS PARENT DISH \(newIngred.dishes)")
            self.ingredsArr.append(newIngred)
            self.saveIngreds()
        }
        
        let actionDis = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }

        alert.addTextField { (alerTextField) in
            alerTextField.placeholder = "Type new ingredient"
            textField = alerTextField
        }

        alert.addAction(action)
        alert.addAction(actionDis)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Select Ingreds Methods -
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "showIngreds", sender: self)
//        print("AND HERE: \(ingredsArr[indexPath.row].name ?? "NONAME") WE HAVE SOME DISHES: \(ingredsArr[indexPath.row].dishes)")
        
        let ingred = ingredsArr[indexPath.row]
        ingred.inStore = !ingred.inStore
        
        saveIngreds()
    }
    
}
