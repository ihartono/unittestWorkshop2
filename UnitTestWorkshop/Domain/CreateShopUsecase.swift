//
//  DummyUsecase.swift
//  TokopediAlone
//
//  Created by Bondan Eko Prasetyo on 12/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import RxCocoa
import RxSwift
import Foundation

internal class CreateShopUsecase {
    var getDomainName = _getDomainName
    var checkShopNameAvailability = _checkShopNameAvailability
    var checkDomainNameAvailability = _checkDomainNameAvailability
}

internal func _getDomainName(_ name: String) -> Driver<String> {
    return .just("\(name)-4")
}

internal func _checkShopNameAvailability(_ name: String) -> Driver<Bool> {
    let isAvailable = !shopNameTaken.contains(name)
    return .just(isAvailable)
}

internal func _checkDomainNameAvailability(_ name: String) -> Driver<String?> {
    .just(nil)
}
