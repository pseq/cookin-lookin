//
//  IngredientsViewController.swift
//  cookin lookin
//
//  Created by pseq on 18.06.2022.
//

import UIKit
import CoreData

class ChooseIngredsVC: UITableViewController {

    @IBOutlet weak var titleView: UINavigationItem!
    var ingredsArr = [Ingredients]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedDish : Dishes?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadIngreds()
        //меняем заголовок
        if let parentDish = selectedDish {
            titleView.title = "Choose ingredients for \(parentDish.name!)"
        }
        
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
        //если ингредиент уже добавлен к блюду -- ставим ему галку
        if let parentDish = selectedDish {
            cell.accessoryType = ingredient.dishes!.contains(parentDish) ? .checkmark: .none
        }
        
        // фон ячеек
        let imageView = UIImageView()
        let image = UIImage(named: "cell_img")
        imageView.image = image
        cell.backgroundView = imageView
        
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

        do {
            ingredsArr = try context.fetch(request)
        } catch {
            print("Error load ingreds from CoreData: \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: Addin ingreds -
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        //кнопка плюс в ингредиентах -- создать и добавить к блюду новый
        makeNewIngred()
    }
    
    func makeNewIngred() {
        var textField = UITextField()

        let alert = UIAlertController(title: "Add a ingredient", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newIngred = Ingredients(context: self.context)
            newIngred.name = textField.text ?? ""
            newIngred.inStore = false
            // добавляем ингредиенту родительское блюдо
            if let parentDish = self.selectedDish {
                newIngred.addToDishes(parentDish)
            }
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
        let ingredient = ingredsArr[indexPath.row]
        var checked = tableView.dequeueReusableCell(withIdentifier: "IngredCell", for: indexPath).accessoryType
        //когда тыкаем и ингредиент -- он добавляется к блюду
        if let parentDish = self.selectedDish {
            if !ingredient.dishes!.contains(parentDish) {
                ingredient.addToDishes(parentDish)
                checked = .checkmark
            } else {
                ingredient.removeFromDishes(parentDish)
                checked = .none
            }
            tableView.reloadData()
        }
    }
    
}
