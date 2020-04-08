//
//  PlaygroundTest.swift
//  UnitTestWorkshopTests
//
//  Created by Bondan Eko Prasetyo on 11/09/19.
//  Copyright © 2019 Tokopedia. All rights reserved.
//

import Foundation
import Quick
import RxSwift
import RxCocoa


class PlaygroundTest: QuickSpec {
    var valueOne: TestObserver<[Int]>!
    var valueTuple: TestObserver<(Int, String)>!
    
    let testOne = PublishSubject<[Int]>()
    let testTupple = PublishSubject<(Int, String)>()
    
    var disposeBag = DisposeBag()
    
    var arrOfDisposable = [Disposable]()
    
    enum TestError: Error {
        case aneh
    }
    
    private func setupObservable() {
        disposeBag = DisposeBag()
        self.valueOne  = TestObserver<[Int]>()
        self.valueTuple = TestObserver<(Int, String)>()
        
        arrOfDisposable = [
            testOne
                .asObservable()
                .map{ val in
                    if val.isEmpty {
                        throw TestError.aneh
                    }
                    
                    return val
                }
                .subscribe(valueOne.observer),
            testTupple.asDriverOnErrorJustComplete().drive(valueTuple.observer)
        ]
        
        arrOfDisposable.forEach{
            $0.disposed(by: disposeBag)
        }
    }
    
    override func spec() {
        beforeEach {
            self.setupObservable()
        }
        
        xit("Check All Value") {
            self.testOne.onNext([1,2,3])
            self.valueOne.assertValue([1,2,3])
        }
        
        it("Check Last Value") {
            self.testOne.onNext([1])
            self.testOne.onNext([2])
            self.testOne.onNext([3])
            
            self.valueOne.assertLastValue([3])
        }
        
        it("Did Fail"){
            self.testOne.onNext([])
            self.valueOne.assertDidFail()
        }
        
        xit("Did emit value") {
            self.testOne.onNext([])
            self.valueOne.assertDidEmitValue("Yah kok ga emit apa-apa sih...")
        }
        
        it("Check emit count should two times") {
            self.testOne.onNext([1])
            self.testOne.onNext([69])
            
            self.valueOne.assertValueCount(2)
        }
        
        it("Check tupple")  {
            self.testTupple.onNext((8, "Lucky"))
            if let getTuple = self.valueTuple.lastValue {
                let (number, word) = getTuple
                XCTAssertEqual(number, 8)
                XCTAssertNotEqual(word, "unlucky")
            }
        }
    }
}
