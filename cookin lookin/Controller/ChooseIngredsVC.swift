//
//  IngredientsViewController.swift
//  cookin lookin
//
//  Created by pseq on 18.06.2022.
//

import UIKit
import CoreData

class ChooseIngredsVC: IngredientsViewController {

    @IBOutlet weak var titleView: UINavigationItem!
    
    override func viewWillAppear(_ animated: Bool) {
        loadIngreds(nil)
        //меняем заголовок
        if let parentDish = selectedDish {
            titleView.title = "Choose ingredients for \(parentDish.name!)"
        }
    }

    //MARK: TableView stuff -
    // отдельный метод проставления галочек
    override func setIngredsCheckmark(ingredient: Ingredients) -> Bool {
        if selectedDish != nil {
            return ingredient.dishes!.contains(selectedDish!)
        } else {
            return ingredient.inStore }
    }
    
    //MARK: Addin ingreds -
    @IBAction override func addBtnPressed(_ sender: UIBarButtonItem) {
        //кнопка плюс в ингредиентах -- создать и добавить к блюду новый
        makeNewIngred()
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
    
    //MARK: Delete Ingreds -
    // Отключаем возможность удаления ингридиентов в окне выбора ингридиентов для блюда
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}
