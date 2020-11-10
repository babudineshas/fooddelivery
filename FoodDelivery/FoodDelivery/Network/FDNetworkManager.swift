//
//  FDNetworkManager.swift
//  FoodDelivery
//
//  Created by Dinesh Babu on 8/11/20.
//  Copyright © 2020 Dinesh. All rights reserved.
//

import Foundation
import Moya
import Alamofire

class FDMoyaProvider : MoyaProvider<FoodDeliveryAPI> {
    init() {
        // mock successful response with 5 secs delay..
        super.init(stubClosure: MoyaProvider.delayedStub(5), session: FDMoyaProvider.defaultSession())
        
        //super.init(stubClosure: MoyaProvider.immediatelyStub, session: FDMoyaProvider.defaultSession())
    }

    fileprivate static func defaultSession() -> Alamofire.Session {
        let config = URLSessionConfiguration.default;
        config.httpAdditionalHeaders = HTTPHeaders.default.dictionary
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        config.requestCachePolicy = .useProtocolCachePolicy
        
        return Alamofire.Session(configuration: config)
    }
}
