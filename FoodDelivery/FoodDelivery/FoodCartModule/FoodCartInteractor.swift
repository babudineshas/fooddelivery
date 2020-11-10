//
//  FoodCartInteractor.swift
//  FoodDelivery
//
//  Created by Dinesh Babu on 9/11/20.
//  Copyright © 2020 Dinesh. All rights reserved.
//

import Foundation

class FoodCartInteractor: PresenterToInteractorFoodCartProtocol {

    // MARK: Properties
    var presenter: InteractorToPresenterFoodCartProtocol?
    
    func retrieveFoodCartItems() {
        presenter?.onRetrieveFoodCartItems(FoodCart.sharedCart.foodItems.value)
    }
}
