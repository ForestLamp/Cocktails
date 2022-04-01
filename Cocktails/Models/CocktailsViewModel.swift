//
//  CocktailsViewModel.swift
//  Cocktails
//
//  Created by Alex Ch. on 31.03.2022.
//

import Foundation

class DrinkViewModel {
    let model: Drink
    var isChoosen: Bool = false
    var name: String {
        model.strDrink
    }
    
    init(model: Drink) {
        self.model = model
    }
}
