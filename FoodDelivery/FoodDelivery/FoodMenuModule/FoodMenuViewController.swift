//
//  FoodMenuViewController.swift
//  FoodDelivery
//
//  Created by Dinesh Babu on 1/11/20.
//  Copyright © 2020 Dinesh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import ObjectMapper

enum DDAppState {
  case loading
  case loaded
}

class FoodMenuViewController: UIViewController, UICollectionViewDelegate, UITableViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak private var foodPromoItemsView: UICollectionView!
    @IBOutlet weak private var foodPromoItemsViewYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var foodCartButton: BadgeButton!
    
    @IBOutlet weak private var foodPromoItemsPageCtrl: UIPageControl!
    
    @IBOutlet weak private var logoImgView: UIImageView!
    @IBOutlet weak private var loadingImgView: UIImageView!
    @IBOutlet weak private var loadingImgViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak private var loadingImgViewLoadedYConstraint: NSLayoutConstraint!
    @IBOutlet weak private var loadingLbl: UILabel!
    
    @IBOutlet weak private var foodCategoriesView: UICollectionView!
    
    @IBOutlet weak private var foodItemsView: UITableView!
    @IBOutlet weak private var foodItemsViewYConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var foodMenuPresenter: ViewToPresenterFoodMenuProtocol?
    
    private let disposeBag = DisposeBag()
    private var appState: BehaviorRelay<DDAppState> = BehaviorRelay(value: .loading)
    
    private var foodPromoItemsSource: [FoodItem] = [FoodItem]()
    private var displayFoodPromoItemsRelay: BehaviorRelay<[FoodItem]> = BehaviorRelay(value: [])
    
    private var foodCategoriesSource: [String] = ["Diet", "Pizza", "Satay", "Drinks", "Bowls", "Cups"]
    
    private var foodItemsSource: [FoodItem] = [FoodItem]()
    private var displayFoodItemsRelay: BehaviorRelay<[FoodItem]> = BehaviorRelay(value: [])
    
    private var loadingImgViewTimer: Timer? = nil
    private var loadingImageAnimationFlag: Bool = false
    private var previousOffset: CGFloat = 0.0
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAppState()
        startLoading()
        foodMenuPresenter?.startReceivingFoodItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        //.default
        .lightContent
    }
}

extension FoodMenuViewController: PresenterToViewFoodMenuProtocol {
    
    func onReceivingFoodItemsSuccessResponse(_ foodItems: [FoodItem], _ foodPromoItems: [FoodItem]) {
        
        self.foodItemsSource = foodItems
        self.foodPromoItemsSource = foodPromoItems
        
        self.appState.accept(.loaded)
    }
    
    func onReceivingFoodItemsFailureResponse(_ error: Error) {
        // TODO:
        // as of now repsonse is mocked with delay of 5 secs.. so no error will happen !!
        print(error)
    }
}

extension FoodMenuViewController {
    func initFoodMenuView() {
        self.foodPromoItemsView.superview?.isHidden = false
        self.foodItemsView.superview?.isHidden = false
        self.foodCartButton.isHidden = false
        
        self.loadingImgViewLoadedYConstraint.constant = UIScreen.main.bounds.height - self.logoImgView.frame.height - self.loadingImgView.frame.height - 60.0
        
        self.loadingImgViewYConstraint.isActive = false
        self.loadingImgViewLoadedYConstraint.isActive = true
        
        self.view.sendSubviewToBack(self.logoImgView)
        self.view.sendSubviewToBack(self.loadingImgView)
        
        self.view.bringSubviewToFront(self.foodItemsView)
        
        initFoodPromoItemsView()
        initFoodPromoItemsPageCtrl()
        
        initFoodItemsView()
        initFoodCategoriesView()
        
        initFoodCartButton()
    }
    
    @IBAction func onFoodCartAction(_ sender: BadgeButton) {
        let foodCartViewController: FoodCartViewController = FoodCartRouter.createFoodCartModule()
        foodCartViewController.modalPresentationStyle = .fullScreen

        self.present(foodCartViewController, animated: true, completion: nil)
    }
    
    private func moveToNextPromo(_ nextPage: Int) {
        var cellToSwipe: Int = nextPage
        
        if (cellToSwipe >= self.foodPromoItemsSource.count) {
            cellToSwipe = 0
        }
        
        // print("moveToNextPromo: curr: \(self.foodPromoItemsPageCtrl.currentPage) next: \(cellToSwipe)")
        
        DispatchQueue.main.async {
            self.foodPromoItemsView.scrollToItem(at: IndexPath(item: cellToSwipe, section: 0), at: .centeredHorizontally, animated: true)
        
            // let rect = self.foodPromoItemsView.layoutAttributesForItem(at: IndexPath(row: cellToSwipe, section: 0))?.frame
            // self.foodPromoItemsView.scrollRectToVisible(rect!, animated: true)
        }
        
        self.foodPromoItemsPageCtrl.currentPage = cellToSwipe
        self.foodPromoItemsPageCtrl.updateDots()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset // set acceleration to 0.0

        let pageWidth: CGFloat = self.foodPromoItemsView.bounds.size.width;
        let minSpace: CGFloat = 0

        // cell width + min spacing for lines
        let cellToSwipe: Int = Int((self.foodPromoItemsView.contentOffset.x)/(pageWidth + minSpace) + 0.5)

        moveToNextPromo(cellToSwipe)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView == foodItemsView {
            let delta: CGFloat = (scrollView.contentOffset.y - previousOffset)
            //print("previousOffset: \(previousOffset)   delta:\(delta)")
            
            let newY: CGFloat = self.foodPromoItemsViewYConstraint.constant - delta
            
            if newY > 0.0 {
                self.foodPromoItemsViewYConstraint.constant = 0
                self.foodItemsViewYConstraint.constant = 271
                return
            }
            
            if abs(newY) <= UIScreen.main.bounds.height {
                self.foodPromoItemsViewYConstraint.constant = newY
                
                self.foodItemsViewYConstraint.constant = self.foodItemsViewYConstraint.constant - delta
                
                previousOffset = scrollView.contentOffset.y
            }
            
            // print("new Y: \(newY).. screen Height: \(UIScreen.main.bounds.height)")
        }
    }
}

// Loading Stuffs
extension FoodMenuViewController {
    @objc func animateLoadingImages() {
        loadingImgView.image = UIImage(named: loadingImageAnimationFlag ? "FD_001.png" : "FD_003.png");
        loadingImageAnimationFlag = !loadingImageAnimationFlag

        let transition: CATransition = CATransition()
        transition.duration = 1.0;
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade
        
        loadingImgView.layer.add(transition, forKey: nil)
    }
    
    func startLoading() {
        loadingImgViewTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(animateLoadingImages), userInfo: nil, repeats: true)
    }
    
    func stopLoading() {
        if self.loadingImgViewTimer != nil {
            self.loadingImgViewTimer!.invalidate()
        }
        self.loadingImgView.image = UIImage(named: "FD_001.png")
    }
}

// Rx Stuffs
extension FoodMenuViewController {
    func initAppState() {
        appState.asObservable()
            .subscribe(onNext: {
                [unowned self] app_state in
                
                print("App State: \(app_state)")
            
                if app_state == .loaded {
                    self.stopLoading()
                    self.initFoodMenuView()
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func scrollAuto() {
        moveToNextPromo(self.foodPromoItemsPageCtrl.currentPage + 1)
    }
    
    func initFoodPromoItemsView() {
        foodPromoItemsView.delegate = self
        foodPromoItemsView.isPagingEnabled = true

        displayFoodPromoItemsRelay.accept(self.foodPromoItemsSource)
        
        displayFoodPromoItemsRelay
            .bind(to: foodPromoItemsView
                .rx
                .items(cellIdentifier: FoodPromoItemsCell.Identifier,
                       cellType: FoodPromoItemsCell.self)) {
                        row, foodItem, cell in
                        cell.setValues(foodItem)
            }
            .disposed(by: disposeBag)
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(scrollAuto), userInfo: nil, repeats: true)
    }
    
    func initFoodPromoItemsPageCtrl() {
        foodPromoItemsPageCtrl.layer.cornerRadius = 10
        foodPromoItemsPageCtrl.layer.masksToBounds = true
        foodPromoItemsPageCtrl.updateDots()
        
        foodPromoItemsPageCtrl.currentPageIndicatorTintColor = .systemYellow
        foodPromoItemsPageCtrl.pageIndicatorTintColor = .white

        Observable.just(foodPromoItemsSource.count)
            .bind(to: foodPromoItemsPageCtrl.rx.numberOfPages)
            .disposed(by: disposeBag)
        
        foodPromoItemsPageCtrl.rx.controlEvent(.valueChanged)
            // commented, until touch event handled..
//            .subscribe(onNext: { [unowned self] in
//                self.moveToNextPromo(self.foodPromoItemsPageCtrl.currentPage + 1)
//            })
            .subscribe(onNext: { _ in
                print("valueChanged: \(self.foodPromoItemsPageCtrl.currentPage) (only log.. action to be handled..)")
            })
            .disposed(by: disposeBag)
    }
    
    func initFoodCategoriesView() {
        foodCategoriesView.allowsMultipleSelection = false
        
        Observable.just(self.foodCategoriesSource)
            .bind(to: foodCategoriesView
                .rx
                .items(cellIdentifier: FoodCategoriesCell.Identifier,
                       cellType: FoodCategoriesCell.self)) {
                        item, category, cell in
                        cell.setValue(category)
                        cell.updateAsSelectedUI()
            }
            .disposed(by: disposeBag)
        
        foodCategoriesView
            .rx
            .itemSelected
            .subscribe(onNext:{ [unowned self] indexPath in
                //let selectedCategoryItem = self.foodCategoriesView.indexPathsForSelectedItems?.first?.item ?? 0
                
                let cell = self.foodCategoriesView.cellForItem(at: indexPath) as? FoodCategoriesCell
                cell?.updateAsSelectedUI()
                self.foodCategoriesView.scrollToItem(at: IndexPath(item: indexPath.item, section: 0), at: .centeredHorizontally, animated: true)
                
                // need to check, is already same category in display !! :)
                self.updateDisplayFoodItems(indexPath.item)
            })
            .disposed(by: disposeBag)
        
        foodCategoriesView
            .rx
            .itemDeselected
            .subscribe(onNext:{ [unowned self] indexpath in
                let cell = self.foodCategoriesView.cellForItem(at: indexpath) as? FoodCategoriesCell
                cell?.updateAsSelectedUI()
            })
            .disposed(by: disposeBag)
        
        foodCategoriesView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        updateDisplayFoodItems(0)
    }
    
    private func updateDisplayFoodItems(_ category: Int) {
        var animate: Bool = false
        
        switch category {
            case 0:
                print("Diet")
                displayFoodItemsRelay.accept(self.foodItemsSource)
                animate = true
            case 1:
                print("Pizza")
                displayFoodItemsRelay.accept(self.foodItemsSource.filter { items in
                    return (items.ingredients?.contains("wheat") ?? false) })
                animate = true
            default:
                print("popup")
                // assumed category index within the range :)
                self.toast("\(foodCategoriesSource[category]) Coming Soon..")
        }
        
        if animate {
            if let viewToAnimate = self.foodItemsView.superview {
                // L -> R
                var l2rFrame: CGRect = viewToAnimate.frame
                l2rFrame.origin.x = viewToAnimate.frame.size.width;
                
                UIView.animate(withDuration:1.5, delay:0.0, options: .curveEaseIn,
                               animations: {
                                viewToAnimate.frame = l2rFrame
                            }, completion: {
                                (finished: Bool) -> Void in
//                                self.foodItemsView.reloadData()
                                
//                                if self.displayFoodItemsRelay.value.count > 0 {
//                                    self.foodItemsView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//                                }
                            });
                
                // R <- L
                var r2lFrame: CGRect = viewToAnimate.frame;
                r2lFrame.origin.x = 0;
                
                UIView.animate(withDuration:0.5, delay:0.0, options: .curveEaseOut,
                   animations: {
                    viewToAnimate.frame = r2lFrame
                }, completion: {
                    (finished: Bool) -> Void in
                });
            }
        }
    }
    
    private func moveToNextFoodCategory(_ direction: UISwipeGestureRecognizer.Direction) {
        let totalItem = self.foodCategoriesView.numberOfItems(inSection: 0)
        
        let selectedCategoryItem = self.foodCategoriesView.indexPathsForSelectedItems?.first?.item ?? 0
        
        var nextCategoryItem = selectedCategoryItem
        
        if direction == .right {
            nextCategoryItem -= 1
            
            if nextCategoryItem <= 0 {
                nextCategoryItem = 0
            }
        }
        else if direction == .left {
            nextCategoryItem += 1
            
            if nextCategoryItem >= totalItem {
                nextCategoryItem = selectedCategoryItem
            }
        }
        
        //print("Selected: \(selectedCategoryItem), Next: \(nextCategoryItem), Direction: \(direction)")
        
        if nextCategoryItem != selectedCategoryItem {
            // deselect current
            let currIndexPath = IndexPath(item: selectedCategoryItem, section: 0)
            
            let currCell = self.foodCategoriesView.cellForItem(at: currIndexPath) as? FoodCategoriesCell
            currCell?.isSelected = false
            currCell?.updateAsSelectedUI()
            
            self.foodCategoriesView.deselectItem(at: currIndexPath, animated: true)
            
            // select next
            let nextIndexPath = IndexPath(item: nextCategoryItem, section: 0)
            
            let nextCell = self.foodCategoriesView.cellForItem(at: nextIndexPath) as? FoodCategoriesCell
            nextCell?.isSelected = true
            nextCell?.updateAsSelectedUI()
            
            self.foodCategoriesView.selectItem(at: nextIndexPath, animated: true, scrollPosition: .centeredHorizontally)
            
            self.updateDisplayFoodItems(nextCategoryItem)
        }
    }
    
    func initFoodItemsView() {
        foodItemsView.delegate = self
        foodItemsView.separatorColor = .clear
        
        let roundCornerView = foodItemsView.superview!
        
        roundCornerView.layer.cornerRadius = 40
        roundCornerView.layer.masksToBounds = true
        roundCornerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // hortizontal (left, right) swipe guestures..
        let rightSwipeGesture = UISwipeGestureRecognizer()
        rightSwipeGesture.direction = .right
        foodItemsView.addGestureRecognizer(rightSwipeGesture)
        
        rightSwipeGesture.rx.event.bind(onNext: { recognizer in
            if recognizer.state != .ended {
                return
            }
            self.moveToNextFoodCategory(recognizer.direction)
            
        }).disposed(by: disposeBag)
        

        let leftSwipeGesture = UISwipeGestureRecognizer()
        leftSwipeGesture.direction = .left
        foodItemsView.addGestureRecognizer(leftSwipeGesture)
        
        leftSwipeGesture.rx.event.bind(onNext: { recognizer in
            if recognizer.state != .ended {
                return
            }
            self.moveToNextFoodCategory(recognizer.direction)
            
        }).disposed(by: disposeBag)
        
        // data & add butotn tap..
        displayFoodItemsRelay
            .bind(to: foodItemsView
                .rx
                .items(cellIdentifier: FoodItemsCell.Identifier,
                       cellType: FoodItemsCell.self)) {
                        row, foodItem, cell in
                        cell.setValues(foodItem)
                        
                        cell.foodAddButton
                        .rx.tap
                        .subscribe(onNext: {
                            print("\(foodItem.name ?? "Food Item") \(foodItem.price ?? 0.0)")
                            
                            // Fade out
                            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                            // UIView.animate(withDuration: 1.0, delay: 0.0, animations: {
                                    FoodCart.sharedCart.add(foodItem)
                                
                                    cell.foodAddButton.backgroundColor = .systemGreen
                                    cell.foodAddButton.setTitle("added +1", for: .normal)
                                }, completion: {
                                    (finished: Bool) -> Void in
                                    
                                    // Fade in
                                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                                    // UIView.animate(withDuration: 0.1, delay: 0.0, animations: {
                                        }, completion: {
                                            (finished: Bool) -> Void in
                                            cell.foodAddButton.backgroundColor = .black
                                            cell.foodAddButton.setTitle("\(foodItem.price ?? 0.0) sgd", for: .normal)
                                })
                            })
                        }
                        ).disposed(by: cell.disposeBagOfCell)
                    }
                    .disposed(by: disposeBag)
    }
    
    func initFoodCartButton() {
        FoodCart.sharedCart.foodItems
            .asObservable()
            .subscribe(onNext: {
              [unowned self] food_items in
                // self.foodCartButton.badge = "\(food_items.count)"
                self.foodCartButton.animate("\(food_items.count)")
            })
            .disposed(by: disposeBag)
    }
}

class FoodPromoItemsCell : UICollectionViewCell {
    static let Identifier = "FoodPromoItemsCell"
    
    @IBOutlet private var foodPromoImgView: UIImageView!
    @IBOutlet private var foodPromoNameLbl: UILabel!
    
    func setValues(_ foodItem: FoodItem) {
        //foodPromoNameLbl.text = foodItem.name
        foodPromoImgView.image = UIImage(named: foodItem.imageName ?? "")
    }
}

class FoodCategoriesCell : UICollectionViewCell {
    static let Identifier = "FoodCategoriesCell"
    
    @IBOutlet private var foodCategoryLbl: UILabel!
    
    func setValue(_ category: String) {
        foodCategoryLbl.text = category
    }
    
    func updateAsSelectedUI() {
        foodCategoryLbl.textColor = isSelected ? .black : .lightGray
    }
}

class FoodItemsCell : UITableViewCell {
    static let Identifier = "FoodItemsCell"
    
    @IBOutlet private var foodImgView: UIImageView!
    @IBOutlet private var foodNameLbl: UILabel!
    @IBOutlet private var foodIngredientsLbl: UILabel!
    @IBOutlet private var foodDimensionsLbl: UILabel!
    @IBOutlet var foodAddButton: UIButton!
    
    var disposeBagOfCell = DisposeBag()
    
    // Make disposbag empty for reusing cell.
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBagOfCell = DisposeBag()
    }
    
    func setValues(_ foodItem: FoodItem) {
        foodImgView.image = UIImage(named: foodItem.imageName ?? "")
        
        let roundCornerView = foodImgView.superview!
        roundCornerView.layer.cornerRadius = 20
        roundCornerView.layer.masksToBounds = true
        
        roundCornerView.layer.borderWidth = 0.1
        roundCornerView.layer.borderColor = UIColor.lightGray.cgColor
        
        foodNameLbl.text = foodItem.name
        foodIngredientsLbl.text = foodItem.ingredients
        foodDimensionsLbl.text = "\(foodItem.weight ?? "0") grams, \(foodItem.size ?? "0") cm"
        
        foodAddButton.setTitle("\(foodItem.price ?? 0.0) usd", for: .normal)
        foodAddButton.layer.cornerRadius = foodAddButton.frame.size.height/2
        foodAddButton.layer.masksToBounds = true
    }
}
