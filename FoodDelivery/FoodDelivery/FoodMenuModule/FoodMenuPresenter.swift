//
//  FoodMenuPresenter.swift
//  FoodDelivery
//
//  Created by Dinesh Babu on 9/11/20.
//  Copyright © 2020 Dinesh. All rights reserved.
//

import Foundation

class FoodMenuPresenter: ViewToPresenterFoodMenuProtocol {

    // MARK: Properties
    var view: PresenterToViewFoodMenuProtocol?
    var interactor: PresenterToInteractorFoodMenuProtocol?
    var router: PresenterToRouterFoodMenuProtocol?
    
    func startReceivingFoodItems() {
        interactor?.retrieveFoodItems()
    }
}

extension FoodMenuPresenter: InteractorToPresenterFoodMenuProtocol {
    
    func onReceivingFoodItemsSuccess(_ foodItems: [FoodItem], _ foodPromoItems: [FoodItem]) {
        view?.onReceivingFoodItemsSuccessResponse(foodItems, foodPromoItems)
    }
    
    func onReceivingFoodItemsFailure(_ error: Error) {
        view?.onReceivingFoodItemsFailureResponse(error)
    }
}
