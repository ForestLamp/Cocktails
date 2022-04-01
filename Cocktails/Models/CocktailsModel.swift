//
//  CocktailsModel.swift
//  Cocktails
//
//  Created by Alex Ch. on 28.03.2022.
//

import Foundation

struct Drinks: Codable {
    let drinks: [Drink]
}

struct Drink: Codable {
    let strDrink, idDrink: String
}
