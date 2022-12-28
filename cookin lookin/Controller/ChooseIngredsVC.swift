//
//  IngredientsViewController.swift
//  cookin lookin
//
//  Created by pseq on 18.06.2022.
//

import UIKit
import RealmSwift

class ChooseIngredsVC: IngredientsViewController {

    @IBOutlet weak var titleView: UINavigationItem!
    
    override func viewWillAppear(_ animated: Bool) {
        loadIngreds(nil)
        //меняем заголовок
        if let parentDish = selectedDish {
            titleView.title = "Choose ingredients for \(parentDish.name)"
        }
    }

    //MARK: TableView stuff -
    // отдельный метод проставления галочек
    override func setIngredsCheckmark(ingredient: Ingredients) -> Bool {
        if selectedDish != nil {
            return ingredient.dishes.contains(selectedDish!)
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
        var checked = tableView.dequeueReusableCell(withIdentifier: "IngredCell", for: indexPath).accessoryType
        
        //когда тыкаем и ингредиент -- он добавляется к блюду
        if let ingredient = ingreds?[indexPath.row] {
            if let parentDish = self.selectedDish {
                if !ingredient.dishes.contains(parentDish) {
                    ingredient.dishes.append(parentDish)
                    checked = .checkmark
                } else {
                    if let parentIndex = ingredient.dishes.firstIndex(of: parentDish) {
                        ingredient.dishes.remove(at: parentIndex)
                    }
                    checked = .none
                }
                tableView.reloadData()
            }
        }


    }
}
