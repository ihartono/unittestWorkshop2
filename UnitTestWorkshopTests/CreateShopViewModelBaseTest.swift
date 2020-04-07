//
//  CreateShopViewModelBaseTest.swift
//  TokopediaTests
//
//  Created by Bondan Eko Prasetyo on 17/07/19.
//  Copyright © 2019 Tokopedia. All rights reserved.
//

import Quick
import RxCocoa
import RxSwift
import XCTest

@testable import UnitTestWorkshop

public class CreateShopViewModelBaseTest: QuickSpec {
    
    public let inputCitySubject = PublishSubject<City?>()
    public let didLoadSubject = PublishSubject<Void>()
    public let shopNameSubject = PublishSubject<String>()
    public let domainNameSubject = PublishSubject<String>()
    public let postalCodeSubject = PublishSubject<Void>()
    public let switchTNCSubject = PublishSubject<Bool>()
    
    public var shopNameValue: TestObserver<String>!
    public var shopNameError: TestObserver<String?>!
    public var domainNameValue: TestObserver<String>!
    public var domainNameError: TestObserver<String?>!
    public var city: TestObserver<City>!
    public var cityError: TestObserver<String?>!
    public var postalCodeError: TestObserver<String?>!
    public var postalCode: TestObserver<String>!
    public var submitButtonEnabled: TestObserver<Bool>!
    
    public var disposeBag = DisposeBag()
    
    public func setupBinding(viewModel: CreateShopViewModel) {
        disposeBag = DisposeBag()
        
        self.shopNameValue = TestObserver<String>()
        self.shopNameError = TestObserver<String?>()
        self.domainNameValue = TestObserver<String>()
        self.domainNameError = TestObserver<String?>()
        self.city = TestObserver<City>()
        self.cityError = TestObserver<String?>()
        self.postalCodeError = TestObserver<String?>()
        self.postalCode = TestObserver<String>()
        self.submitButtonEnabled = TestObserver<Bool>()
        
        let input = CreateShopViewModel.Input(
            didLoadTrigger: didLoadSubject.asDriverOnErrorJustComplete(),
            domainNameTrigger: domainNameSubject.asDriverOnErrorJustComplete(),
            inputCityTrigger: inputCitySubject.asDriverOnErrorJustComplete(),
            shopNameTrigger: shopNameSubject.asDriverOnErrorJustComplete(),
            postalCodeTrigger: postalCodeSubject.asDriverOnErrorJustComplete(),
            switchTNCTrigger: switchTNCSubject.asDriverOnErrorJustComplete()
        )
        
        let output = viewModel.transform(input: input)
        
        output.shopNameValue.drive(self.shopNameValue.observer).disposed(by: disposeBag)
        output.shopNameError.drive(self.shopNameError.observer).disposed(by: disposeBag)
        output.domainNameValue.drive(self.domainNameValue.observer).disposed(by: disposeBag)
        output.domainNameError.drive(self.domainNameError.observer).disposed(by: disposeBag)
        output.city.drive(self.city.observer).disposed(by: disposeBag)
        output.cityError.drive(self.cityError.observer).disposed(by: disposeBag)
        output.postalCodeError.drive(self.postalCodeError.observer).disposed(by: disposeBag)
        output.postalCode.drive(self.postalCode.observer).disposed(by: disposeBag)
        output.submitButtonEnabled.drive(self.submitButton.observer).disposed(by: disposeBag)
    }
}
