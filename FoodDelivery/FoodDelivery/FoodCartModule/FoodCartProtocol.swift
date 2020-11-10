//
//  FoodCartProtocol.swift
//  FoodDelivery
//
//  Created by Dinesh Babu on 9/11/20.
//  Copyright © 2020 Dinesh. All rights reserved.
//

import Foundation


// MARK: View Output (Presenter -> View)
protocol PresenterToViewFoodCartProtocol {

   func onRetrieveFoodCartItemsResponse(_ foodItems: [FoodItem])
}


// MARK: View Input (View -> Presenter)
protocol ViewToPresenterFoodCartProtocol {
    
    var view: PresenterToViewFoodCartProtocol? { get set }
    var interactor: PresenterToInteractorFoodCartProtocol? { get set }
    var router: PresenterToRouterFoodCartProtocol? { get set }
    
    func startRetrievingFoodCartItems()
}


// MARK: Interactor Input (Presenter -> Interactor)
protocol PresenterToInteractorFoodCartProtocol {

    var presenter: InteractorToPresenterFoodCartProtocol? { get set }
    
    func retrieveFoodCartItems()
}


// MARK: Interactor Output (Interactor -> Presenter)
protocol InteractorToPresenterFoodCartProtocol {

    func onRetrieveFoodCartItems(_ foodItems: [FoodItem])
}


// MARK: Router Input (Presenter -> Router)
protocol PresenterToRouterFoodCartProtocol : class {

    static func createFoodCartModule() -> FoodCartViewController
}
