//
//  FoodCartViewController.swift
//  FoodDelivery
//
//  Created by Dinesh Babu on 6/11/20.
//  Copyright © 2020 Dinesh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FoodCartViewController: UIViewController {
    @IBOutlet weak private var backButton: UIButton!
    @IBOutlet weak private var foodCartBackButtonYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var foodManagerItemsView: UICollectionView!
    
    @IBOutlet weak private var foodCartItemsView: UITableView!
    @IBOutlet weak private var foodCartTotalLbl: UILabel!
    
    @IBOutlet weak private var foodCartPaymentButton: BadgeButton!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window1 = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window1?.windowScene?.statusBarManager?.statusBarFrame.height ?? 30
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        foodCartBackButtonYConstraint.constant = statusBarHeight
        
        initFoodManagerItemsView()
        initFoodCartItemsView()
        
        foodCartPaymentButton.badge = ""
        
        foodCartPresenter?.startRetrievingFoodCartItems()
    }

    // MARK: - Properties
    var foodCartPresenter: ViewToPresenterFoodCartProtocol?
    
    private let disposeBag = DisposeBag()
    private let foodManagerItems = Observable.just(["My Cart", "My Orders", "My Info"])
    private let foodCartItemsRelay: BehaviorRelay<[FoodItemSummary]> = BehaviorRelay(value: [])
}

extension FoodCartViewController: PresenterToViewFoodCartProtocol{
    
    func onRetrieveFoodCartItemsResponse(_ foodItems: [FoodItem]) {
        foodCartItemsRelay.accept(self.toSummary(foodItems))
        
        foodCartTotalLbl.text = "\(foodCartTotal) sgd"
        
        foodCartPaymentButton.isHidden = isFoodCartEmpty
        //foodCartItemsView.tableFooterView?.isHidden = isFoodCartEmpty
    }
    
    var isFoodCartEmpty: Bool {
        foodCartItemsRelay.value.count == 0
    }
    
    var foodCartTotal: Float {
        return foodCartItemsRelay.value.map( {$0.totalCost} ).reduce(0, +)
    }
    
    func toSummary(_ foodItems: [FoodItem]) -> [FoodItemSummary] {
        guard foodItems.count > 0 else {
            return [FoodItemSummary]()
        }
      
        // set of food items...
        let foodItemsSet = Set<FoodItem>(foodItems)
      
        // count of each food item..
        let foodItemsSummary:[FoodItemSummary] = foodItemsSet.map { foodItem in
            let count: Int = foodItems.reduce(0) {
                cummTotal, reduceFoodItem in

                if foodItem == reduceFoodItem {
                    return cummTotal + 1
                }

                return cummTotal
            }

            var fiSummary: FoodItemSummary = FoodItemSummary()
            fiSummary.foodItem = foodItem
            fiSummary.foodItemCount = count
            fiSummary.totalCost = Float(count) * (foodItem.price ?? 0.0)

            return fiSummary
        }

        return foodItemsSummary
    }
}

extension FoodCartViewController {
    @IBAction func onBackAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func initFoodManagerItemsView() {
        foodManagerItems
            .bind(to: foodManagerItemsView
                .rx
                .items(cellIdentifier: FoodManagerItemCell.Identifier,
                       cellType: FoodManagerItemCell.self)) {
                        item, managerItem, cell in
                        cell.setValue(managerItem)
                        cell.updateAsSelectedUI()
            }
            .disposed(by: disposeBag)
        
        foodManagerItemsView
            .rx
            .itemSelected
            .subscribe(onNext:{ [unowned self] indexPath in
                let cell = self.foodManagerItemsView.cellForItem(at: indexPath) as? FoodManagerItemCell
                cell?.updateAsSelectedUI()
                self.foodManagerItemsView.scrollToItem(at: IndexPath(item: indexPath.item, section: 0), at: .centeredHorizontally, animated: true)
            })
            .disposed(by: disposeBag)
        
        foodManagerItemsView
            .rx
            .itemDeselected
            .subscribe(onNext:{ [unowned self] indexpath in
                let cell = self.foodManagerItemsView.cellForItem(at: indexpath) as? FoodManagerItemCell
                cell?.updateAsSelectedUI()
            })
            .disposed(by: disposeBag)
        
        foodManagerItemsView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    func initFoodCartItemsView() {
        foodCartItemsView.separatorColor = .clear
        
        foodCartTotalLbl.text = "\(foodCartTotal) sgd"
        
        foodCartItemsRelay
            .bind(to: foodCartItemsView
                .rx
                .items(cellIdentifier: FoodCartItemsCell.Identifier,
                       cellType: FoodCartItemsCell.self)) {
                        row, foodItemSummary, cell in
                        cell.setValues(foodItemSummary)
            }
            .disposed(by: disposeBag)
    }
}

class FoodManagerItemCell : UICollectionViewCell {
    static let Identifier = "FoodManagerItemCell"
    
    @IBOutlet private var titleLbl: UILabel!
    
    func setValue(_ item: String) {
        titleLbl.text = item
    }
    
    func updateAsSelectedUI() {
        titleLbl.textColor = isSelected ? .black : .lightGray
    }
}

class FoodCartItemsCell : UITableViewCell {
    static let Identifier = "FoodCartItemsCell"
    
    @IBOutlet private var foodImgView: UIImageView!
    @IBOutlet private var foodNameLbl: UILabel!
    @IBOutlet private var foodTotalPriceLbl: UILabel!
    @IBOutlet private var foodPriceLbl: UILabel!
    @IBOutlet private var foodQtyLbl: UILabel!
    @IBOutlet var foodRemoveButton: UIButton!
    
    func setValues(_ foodItemSummary: FoodItemSummary) {
        foodImgView.image = UIImage(named: foodItemSummary.foodItem?.imageName ?? "")
        foodImgView.layer.borderWidth = 2
        foodImgView.layer.borderColor = UIColor.lightGray.cgColor
        
        foodNameLbl.text = foodItemSummary.foodItem?.name
        
        foodPriceLbl.text = "\(foodItemSummary.foodItem?.price ?? 0.0) sgd"
        
        foodTotalPriceLbl.text = "\(foodItemSummary.totalCost) sgd"
        
        foodQtyLbl.text = "qty: \(foodItemSummary.foodItemCount)"
    }
}
