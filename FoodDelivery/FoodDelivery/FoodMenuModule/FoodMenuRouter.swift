//
//  FoodMenuRouter.swift
//  FoodDelivery
//
//  Created by Dinesh Babu on 9/11/20.
//  Copyright © 2020 Dinesh. All rights reserved.
//

import Foundation
import UIKit

class FoodMenuRouter: PresenterToRouterFoodMenuProtocol {
    
    // MARK: Static methods
    static func createFoodMenuModule() -> FoodMenuViewController {
        
        let view = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "FoodMenuViewController") as! FoodMenuViewController
        
        var presenter: ViewToPresenterFoodMenuProtocol & InteractorToPresenterFoodMenuProtocol = FoodMenuPresenter()
        var interactor: PresenterToInteractorFoodMenuProtocol = FoodMenuInteractor()
        let router: PresenterToRouterFoodMenuProtocol = FoodMenuRouter()
        
        view.foodMenuPresenter = presenter
            presenter.view = view
            presenter.router = router
            presenter.interactor = interactor
                interactor.presenter = presenter
        
        return view
    }
    
}
