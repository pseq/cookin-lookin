//
//  IngredientsViewController.swift
//  cookin lookin
//
//  Created by pseq on 18.06.2022.
//

import UIKit
import RealmSwift

class IngredientsViewController: UITableViewController {

    let realm = try! Realm()
    var ingreds: Results<Ingredients>?
//    var ingreds: List<Ingredients>?
    var selectedDish: Dishes?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadIngreds(selectedDish)
    }

    //MARK: TableView stuff -
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingreds?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredCell", for: indexPath)
        
        if let ingredient = ingreds?[indexPath.item] {
            var content = cell.defaultContentConfiguration()
            content.text = ingredient.name
            cell.contentConfiguration = content

            cell.accessoryType = setIngredsCheckmark(ingredient: ingredient) ? .checkmark: .none
        }
        return cell
    }
    
    // отдельный метод проставления галочек
    func setIngredsCheckmark(ingredient: Ingredients) -> Bool {
        return ingredient.inStore
    }
    
    //MARK: Data manipulation stuff -
    func saveIngreds(_ ingredient: Ingredients) {
        do {
            try realm.write {
                realm.add(ingredient)
            }
        } catch {
            print("Error save dishes to Realm: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadIngreds(_ forDish: Dishes?) {
        
        // сортировка
//        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        if let parentDish = forDish {
            ingreds = realm.objects(Ingredients.self).filter("%@ IN dishes.name", parentDish.name)
        } else {
            ingreds = realm.objects(Ingredients.self)
        }
        tableView.reloadData()
    }
    
    //MARK: Addin ingreds -
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        //кнопка плюс в ингредиентах -- создать и добавить к блюду новый
        if selectedDish == nil {
            makeNewIngred()
        } else {
            performSegue(withIdentifier: "ShowChooseIngreds", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ChooseIngredsVC
        //тут передаём выбору ингредиентов родительское блюдо
        destinationVC.selectedDish = selectedDish
    }
    
    func makeNewIngred() {
        var textField = UITextField()

        let alert = UIAlertController(title: "Add a ingredient", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newIngred = Ingredients()
            newIngred.name = textField.text ?? ""
            newIngred.inStore = false
            // добавляем ингридиенту родительское блюдо ??и новый ингридиент в блюдо
            if let parentDish = self.selectedDish {
                newIngred.dishes.append(parentDish)
            }
            self.saveIngreds(newIngred)
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
        
        if let ingred = ingreds?[indexPath.row] {
            do {
                try realm.write {
                    ingred.inStore = !ingred.inStore
                }
            } catch {
                print("Error mark ingred: \(error)")
            }
            tableView.reloadData()
        }
    }
    
    //MARK: Delete Ingreds -
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let swipe = UIContextualAction(style: .normal, title: "Delete") {
            [weak self] (action, view, completionHandler) in self?.deleteIngred(indexPath.row)
            completionHandler(true)
        }
        swipe.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [swipe])
    }
    
    func deleteIngred (_ itemIndex: Int) {
        
        func goDelete () {
//            self.context.delete(self.ingredsArr[itemIndex])
            //self.ingreds.remove(at: itemIndex)
//            self.saveIngreds()
        }
        
//        if let dishes = ingredsArr[itemIndex].dishes {
//            if dishes.count > 0 {
//                //Если есть привязанные блюда -- выводим предупреждение перед удалением
//                var alertText = "\(ingredsArr[itemIndex].name ?? "Error ingred name!!!") in dishes:\n"
//                //делаем список блюд
//                for dishElement in dishes {
//                    let dish = dishElement as! Dishes
//                    alertText += "\(dish.name  ?? "Error dish!!!")\n"
//                }
//                
//                let alert = UIAlertController(title: alertText, message: "", preferredStyle: .alert)
//                let action = UIAlertAction(title: "Delete from all dishes", style: .default) { (action) in
//                    //удаляем
//                    goDelete()
//                }
//                
//                let actionDis = UIAlertAction(title: "Cancel", style: .default) { (action) in
//                    alert.dismiss(animated: true, completion: nil)
//                    return
//                }
//
//                alert.addAction(action)
//                alert.addAction(actionDis)
//                present(alert, animated: true, completion: nil)
//            } else { goDelete() }
//        }
    }
}
