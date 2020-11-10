//
//  Utils.swift
//  FoodDelivery
//
//  Created by Dinesh Babu on 1/11/20.
//  Copyright © 2020 DinDinn. All rights reserved.
//

import Foundation

func printLog(_ msg: String) -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MMM-yy HH:mm:ss.SSSS"
    return (formatter.string(from: date) + " => "  + msg)
}
