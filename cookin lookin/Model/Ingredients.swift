//
//  Ingredients.swift
//  cookin lookin
//
//  Created by pseq on 15.12.2022.
//

import Foundation
import RealmSwift

class Ingredients: Object {
    @objc dynamic var inStore: Bool = false
    @objc dynamic var name: String = ""
    let dishes = List<Dishes>()
}
