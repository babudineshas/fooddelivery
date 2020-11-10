//
//  Extensions.swift
//  FoodDelivery
//
//  Created by Dinesh Babu on 1/11/20.
//  Copyright © 2020 DinDinn. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    func toast(_ message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: (UIDevice.current.userInterfaceIdiom == .pad) ? .alert : .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("toast ok")
            alert.dismiss(animated: true)
        }))
        
        self.present(alert, animated: true)

        // duration in seconds
        let duration: Double = 2

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
    }
}

extension UIView {
    func zoomInOut() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.6, 1.0]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = 1.5
        animation.repeatCount = 1.0
        
        self.layer.add(animation, forKey: nil)
    }
}

extension UIPageControl {
    func updateDots() {
        for n in 0..<self.subviews.count {
            let dotView = self.subviews[n]
            
            dotView.backgroundColor = (n == self.currentPage) ? self.currentPageIndicatorTintColor : self.pageIndicatorTintColor
            
            if n == self.currentPage {
                dotView.zoomInOut()
            }
        }
    }
}
