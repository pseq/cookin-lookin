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
        if let parentDish = selectedDish {
            return ingredient.dishes.contains(where: {$0.name == parentDish.name})
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
        //когда тыкаем в ингредиент -- он добавляется к блюду
        if let ingredient = ingreds?[indexPath.row] {
            if let parentDish = selectedDish {
                if !ingredient.dishes.contains(where: {$0.name == parentDish.name}) {
                    do {
                        try realm.write {
                            ingredient.dishes.append(parentDish)
                        }
                    } catch {
                        print("Error append ingred to dish: \(error)")
                    }
                } else {
                    if let parentIndex = ingredient.dishes.firstIndex(where: {$0.name == parentDish.name}) {

                        do {
                            try realm.write {
                                ingredient.dishes.remove(at: parentIndex)
                            }
                        } catch {
                            print("Error remove ingred from dish: \(error)")
                        }
                    }
                }
                tableView.reloadData()
            }
        }


    }
}
