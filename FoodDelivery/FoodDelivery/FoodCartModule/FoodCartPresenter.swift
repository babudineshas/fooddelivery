//
//  FoodCartPresenter.swift
//  FoodDelivery
//
//  Created by Dinesh Babu on 9/11/20.
//  Copyright © 2020 Dinesh. All rights reserved.
//

import Foundation

class FoodCartPresenter: ViewToPresenterFoodCartProtocol {

    // MARK: Properties
    var view: PresenterToViewFoodCartProtocol?
    var interactor: PresenterToInteractorFoodCartProtocol?
    var router: PresenterToRouterFoodCartProtocol?
    
    func startRetrievingFoodCartItems() {
        interactor?.retrieveFoodCartItems()
    }
}

extension FoodCartPresenter: InteractorToPresenterFoodCartProtocol {
    func onRetrieveFoodCartItems(_ foodItems: [FoodItem]) {
        view?.onRetrieveFoodCartItemsResponse(foodItems)
    }
}
