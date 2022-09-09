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
    var selectedDish : Dishes?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadIngreds(selectedDish)
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
    
    func loadIngreds(_ forDish: Dishes?) {
        let request = Ingredients.fetchRequest() //: NSFetchRequest<Dishes>
        
//        request.predicate = NSPredicate(format: "ANY dishes.name MATCHES %@", selectedDish!.name!)
        //потом заменить на выбор предиката из параметров
        if let parentDish = forDish {
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
        //кнопка плюс в ингредиентах -- создать и добавить к блюду новый
        //makeNewIngred()
        //временно -- открыть ChooseIngreds
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
            let newIngred = Ingredients(context: self.context)
            newIngred.name = textField.text ?? ""
            newIngred.inStore = false
            // добавляем ингредиенту родительское блюдо
            // нужно ли блюду добавить ингредиент, или это случится автоматически?
            // нужно походу
            if let parentDish = self.selectedDish {
                newIngred.addToDishes(parentDish)
                //print("ADDIN PARENT DISH \(parentDish.name) TO INGRED \(newIngred.name)")
            }
            //print("AND NOW \(newIngred.name) HAS PARENT DISH \(newIngred.dishes)")
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
        
        let ingred = ingredsArr[indexPath.row]
        ingred.inStore = !ingred.inStore
        
        saveIngreds()
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
//        context.delete(dishesArr[dishIndex])
//        dishesArr.remove(at: dishIndex)
//        saveDishes()
    }
}
