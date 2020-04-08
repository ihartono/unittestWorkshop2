//
//  CreateShopViewModel.swift
//  TokopediAlone
//
//  Created by Bondan Eko Prasetyo on 15/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxOptional

internal class CreateShopViewModel: ViewModelType {
    private let useCase: CreateShopUsecase
    
    internal init(useCase: CreateShopUsecase) {
        self.useCase = useCase
    }
    
    internal struct Input {
        let didLoadTrigger: Driver<Void>
        let domainNameTrigger: Driver<String>
        let inputCityTrigger: Driver<City?>
        let shopNameTrigger: Driver<String>
        let postalCodeTrigger: Driver<Void>
        let switchTNCTrigger: Driver<Bool>
        let postalCodeValueTrigger: Driver<String?>
    }
    
    internal struct Output {
        let shopNameValue: Driver<String>
        let shopNameError: Driver<String>
        let domainNameValue: Driver<String>
        let domainNameError: Driver<String?>
        let city: Driver<City>
        let cityError: Driver<String>
        let postalCodeError: Driver<String?>
        let postalCode: Driver<String>
        let submitButtonEnabled: Driver<Bool>
        let domainErrorIsHidden: Driver<Bool>
        let shopNameErrorIsHidden: Driver<Bool>
        let postalErrorIsHidden: Driver<Bool>
        let cityErrorIsHidden: Driver<Bool>
        let presentPostalCodeView: Driver<City>
    }
    
    internal func transform(input: Input) -> Output {
        var postalCodeSelected: Bool = false
        var selectedValidDomain: Bool = false
        var isCustomDomain: Bool = false
        
        var alreadySelectCity = false
        let selectedCity = BehaviorRelay<City?>(value: nil)
        let shopNameErrorStatus = BehaviorRelay<ShopError?>(value: nil)
        
        let shopNameAvailability = input.shopNameTrigger
            .flatMapLatest { [useCase] name -> Driver<Bool> in
                guard name.isNotEmpty else {
                    shopNameErrorStatus.accept(.textEmpty)
                    return .empty()
                }
                
                guard !name.containsEmoji else {
                    shopNameErrorStatus.accept(.containEmoji)
                    return .empty()
                }
                
                guard !name.wrappedInWhitespace else {
                    shopNameErrorStatus.accept(.startOrEndWithWhitespace)
                    return .empty()
                }
                
                guard name.count > 3 else {
                    shopNameErrorStatus.accept(.minCharacter)
                    return .empty()
                }
                
                shopNameErrorStatus.accept(nil)
                return useCase.checkShopNameAvailability(name)
            }
            .map { isAvailable -> ShopError? in
                let error: ShopError? = isAvailable ? nil : .notAvailable
                return error
            }
        
        let getDomainName = input.shopNameTrigger
            .flatMapLatest { [useCase] value -> Driver<String> in
                useCase.getDomainName(value).asDriver()
            }
            .map { domainName -> (domainName: String, isCustomDomain: Bool) in
                return (domainName: domainName, isCustomDomain: false)
            }
        
        let domainNameTrigger = Driver.merge(
            getDomainName.filter{ _ in !selectedValidDomain },
            
            /** When user manually input domain, status of isCustomDomain will set as true */
            input.domainNameTrigger.map { (domainName: $0, isCustomDomain: true) }
        )
        .do(onNext: { (_, customDomain) in
            isCustomDomain = customDomain
        })
        
        let domainNameError = Driver.merge(
            /** Domain name character is less than three */
            domainNameTrigger
                .filter { $0.domainName.count < 3 }
                .map { _ in ShopError.minCharacter.message },
            
            /** Backend return error */
            domainNameTrigger
                .filter { $0.domainName.count >= 3 }
                .flatMap { [useCase] (value) -> Driver<String?> in
                    useCase.checkDomainNameAvailability(value.domainName)
                }
        )
        .do(onNext:{ value in
            if isCustomDomain {
                selectedValidDomain = value == nil
            }
        })
        
        let selCity = input.inputCityTrigger
            .do(onNext: { city in
                /** Store city data in subject, will used for choose postal code */
                selectedCity.accept(city)
                
                /** Mark as true when user do inputCityTrigger */
                alreadySelectCity = true
            })
            .filterNil()
        
        let triggerCityError = Driver.merge(
            input.inputCityTrigger.filter { $0 == nil }.mapToVoid(),
            input.postalCodeTrigger.filter { selectedCity.value == nil }
                .do(onNext: { _ in
                    alreadySelectCity = true
                    selectedCity.accept(nil)
                })
        )
        
        let cityError = triggerCityError.map { _ -> String in
            return ShopError.textEmpty.message
        }
        
        let presentPostalCodeView = input.postalCodeTrigger
            .withLatestFrom(selCity)
        
        let newPostalCode = Driver.merge(
            input.postalCodeValueTrigger.filterNil(),
            selCity
                .filter { _ in postalCodeSelected }
                .map{ _ in return .postalCodePlaceholder }
        )
        .do(onNext:{
            // if value == postal code, mean reset
            postalCodeSelected = $0 != .postalCodePlaceholder
        })
        
        let postalCodeError = input.postalCodeValueTrigger.map{ _ in
            return !postalCodeSelected ? ShopError.textEmpty.message : nil
        }
        
        let validButton = Driver.combineLatest(
            shopNameErrorStatus.asDriver().map{ $0 == nil },
            domainNameError.map{ $0 == nil},
            cityError.map { _ -> Bool in return true },
            postalCodeError.map{ $0 == nil },
            input.switchTNCTrigger
        )
        .map{ $0 && $1 && $2 && $3 && $4 }
        
        let domainErrorIsHidden = domainNameError
            .map { name -> Bool in
                name?.isEmpty ?? true
            }
        
        let shopNameErrorMerge = Driver.merge(shopNameAvailability, shopNameErrorStatus.asDriver())
        
        let shopNameErrorIsHidden = shopNameErrorMerge
            .map { error -> Bool in
                return error == nil
            }
        
        let shopNameError = shopNameErrorMerge
            .filterNil()
            .map { error -> String in
                return error.message
            }
        
        let postalErrorIsHidden = postalCodeError
            .map { error -> Bool in
                return error != nil
            }
        
        let cityErrorIsHidden = selectedCity
            .filter { _ in alreadySelectCity }
            .map { city -> Bool in
                return city != nil
            }.asDriverOnErrorJustComplete()
        
        return Output(
            shopNameValue: input.shopNameTrigger,
            shopNameError: shopNameError,
            domainNameValue: domainNameTrigger.map{ $0.0 },
            domainNameError: domainNameError.map { $0 },
            city: selCity,
            cityError: cityError,
            postalCodeError: postalCodeError,
            postalCode: newPostalCode,
            submitButtonEnabled: validButton,
            domainErrorIsHidden: domainErrorIsHidden,
            shopNameErrorIsHidden: shopNameErrorIsHidden,
            postalErrorIsHidden: postalErrorIsHidden,
            cityErrorIsHidden: cityErrorIsHidden,
            presentPostalCodeView: presentPostalCodeView
        )
    }
}
