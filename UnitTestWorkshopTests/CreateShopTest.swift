//
//  CreateShopTest.swift
//  TokopediAloneTests
//
//  Created by Bondan Eko Prasetyo on 15/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import Quick
import XCTest
import RxCocoa

@testable import UnitTestWorkshop

private class CreateShopTest: CreateShopViewModelBaseTest {
    override func spec() {
        let useCase = CreateShopUsecase()
        beforeEach {
            self.setupBinding(viewModel: CreateShopViewModel(useCase: useCase))
        }
        
        describe("Opening shop") {
            context("typing shop name") {
                it("valid shopname, will show domain name suggestion") {
                    useCase.getDomainName = { name in
                        return Driver.just("\(name)-4")
                    }
                    
                    useCase.checkShopNameAvailability = { _ in
                        return .just(true)
                    }
                    
                    useCase.checkDomainNameAvailability = { _ in
                        return .just(nil)
                    }
                    
                    self.shopNameSubject.onNext("kuda")
                    self.domainNameValue.assertValue("kuda-4")
                    self.shopNameError.assertDidNotEmitValue()
                }
                
                it("invalid shopname, still show a valid domain name"){
                    useCase.getDomainName = { name in
                        return Driver.just("\(name)-4")
                    }
                    
                    useCase.checkShopNameAvailability = { _ in
                        return Driver.just(false)
                    }
                    
                    self.shopNameSubject.onNext("tokopedia")
                    self.domainNameValue.assertValue("tokopedia-4")
                    self.shopNameError.assertValue("Shop name not available")
                }
                
                it("shows error when shop name has less than 3 characters") {
                    self.shopNameSubject.onNext("aa")
                    self.shopNameError.assertValue(ShopError.minCharacter.message)
                }
                
                it("shows error when shop name start or end with spacing") {
                    self.shopNameSubject.onNext(" test")
                    self.shopNameError.assertValue(ShopError.startOrEndWithWhitespace.message)
                }
                
                it("shows error when contain emoji") {
                    self.shopNameSubject.onNext("hai 🍑")
                    self.shopNameError.assertValue(ShopError.containEmoji.message)
                }
                
                it("domain name valid"){
                    useCase.checkDomainNameAvailability = { _ in
                        return .just(nil)
                    }
                    
                    self.domainNameSubject.onNext("Toko Foo Bar")
                    self.domainNameError.assertValue(nil)
                }
                
                it("domain name not valid") {
                    useCase.checkDomainNameAvailability = { _ in
                        return .just("is not valid")
                    }
                    
                    self.domainNameSubject.onNext("tokopedia")
                    self.domainNameError.assertValue("is not valid")
                }
                
                it("show error when domain name has less than 3 characters") {
                    self.domainNameSubject.onNext("aa")
                    self.domainNameError.assertValue(ShopError.minCharacter.message)
                }
                
                it("after selected valid domain name, it should not be change from suggestion") {
                    useCase.checkDomainNameAvailability = { _ in
                        return .just(nil)
                    }
                    
                    self.domainNameSubject.onNext("tokofoo")
                    self.domainNameValue.assertLastValue("tokofoo")
                    
                    useCase.checkShopNameAvailability = { _ in
                        return .just(true)
                    }
                    
                    useCase.getDomainName = { name in
                        return .just("\(name)-4")
                    }
                    
                    self.shopNameSubject.onNext("foobar")
                    self.domainNameValue.assertLastValue("tokofoo")
                }
                
                it("change domain name when invalid") {
                    useCase.getDomainName = { name in
                        return Driver.just("\(name)-4")
                    }
                    
                    useCase.checkShopNameAvailability = { _ in
                        return .just(true)
                    }
                    
                    useCase.checkDomainNameAvailability = { _ in
                        return .just(nil)
                    }
                    
                    self.domainNameSubject.onNext("tokofoo")
                    self.domainNameValue.assertLastValue("tokofoo")
                    self.domainNameError.assertLastValue(nil)
                    
                    useCase.checkDomainNameAvailability = { _ in
                        return .just(ShopError.minCharacter.message)
                    }
                    
                    self.domainNameSubject.onNext("a")
                    self.domainNameError.assertLastValue(ShopError.minCharacter.message)
                    
                    self.shopNameSubject.onNext("tokokuda")
                    self.domainNameValue.assertLastValue("tokokuda-4")
                }
            }
            
            context("Select City") {
                it("shows selected city") {
                    let city = City(id: "1", name: "Jakarta")
                    
                    self.inputCitySubject.onNext(city)
                    self.city.assertValue(city)
                }
                
                it("shows error when city is not selected") {
                    self.inputCitySubject.onNext(nil)
                    self.cityError.assertValue(ShopError.textEmpty.message)
                }
                
                it("does not show error when city is already selected") {
                    let city = City(id: "1", name: "Jakarta")
                    
                    self.inputCitySubject.onNext(city)
                    self.inputCitySubject.onNext(nil)
                    
                    self.city.assertLastValue(city)
                }
            }
            
            context("Select postal code") {
                it("show error city is required, when click postal code without select the city first") {
                    self.postalCodeSubject.onNext(())
                    self.cityError.assertValue(ShopError.textEmpty.message)
                }
                
                it("select city and select postal code") {
                    let city = City(id: "1", name: "Jakarta")
                    self.inputCitySubject.onNext(city)
                    self.postalCodeValueSubject.onNext("17114")
                    
                    self.postalCodeSubject.onNext(())
                    self.postalCode.assertValue("17114")
                }
                
                it("should reset postal code after select a new city"){
                    // Current City
                    let city = City(id: "1", name: "Jakarta")
                    self.inputCitySubject.onNext(city)
                    self.postalCodeValueSubject.onNext("12345")
                    
                    self.postalCodeSubject.onNext(())
                    self.postalCode.assertValue("12345")
                    
                    let newCity = City(id: "2", name: "Bandung")
                    self.inputCitySubject.onNext(newCity)
                    
                    self.postalCode.assertLastValue("Postal Code")
                }
            }
        }
    }
}

