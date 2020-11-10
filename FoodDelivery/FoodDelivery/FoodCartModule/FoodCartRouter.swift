//
//  FoodCartRouter.swift
//  FoodDelivery
//
//  Created by Dinesh Babu on 9/11/20.
//  Copyright © 2020 Dinesh. All rights reserved.
//

import Foundation
import UIKit

class FoodCartRouter: PresenterToRouterFoodCartProtocol {
    
    // MARK: Static methods
    static func createFoodCartModule() -> FoodCartViewController {
        
        let view = UIStoryboard(name:"Main",bundle: Bundle.main).instantiateViewController(withIdentifier: "FoodCartViewController") as! FoodCartViewController
        
        var presenter: ViewToPresenterFoodCartProtocol & InteractorToPresenterFoodCartProtocol = FoodCartPresenter()
        var interactor: PresenterToInteractorFoodCartProtocol = FoodCartInteractor()
        let router: PresenterToRouterFoodCartProtocol = FoodCartRouter()
        
        view.foodCartPresenter = presenter
            presenter.view = view
            presenter.router = router
            presenter.interactor = interactor
                interactor.presenter = presenter
        
        return view
    }
    
}
