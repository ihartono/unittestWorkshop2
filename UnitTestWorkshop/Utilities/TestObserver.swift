//
//  TestObserver.swift
//  TokopediaTests
//
//  Created by Jefferson Setiawan on 16/08/18, custom from Kickstarter OSS.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift

/**
 A `TestObserver` is a wrapper around an `Observer` that saves all events to an internal array so that
 assertions can be made on a signal's behavior. To use, just create an instance of `TestObserver` that
 matches the type of signal/producer you are testing, and observer/start your signal by feeding it the
 wrapped observer. For example,
 
 ```
 let test = TestObserver<Int>()
 mySignal.observer(test.observer)
 
 // ... later ...
 
 test.assertValues([1, 2, 3])
 ```
 */
public final class TestObserver <Value> {
    
    public private(set) var events: [Event<Value>] = []
    public private(set) var observer: PublishSubject<Value>
    public let rx_disposeBag = DisposeBag()
    
    public init() {
        self.observer = PublishSubject<Value>()
        self.observer.subscribe(action).disposed(by: rx_disposeBag)
    }
    
    public func reset() {
        self.events.removeAll()
    }
    
    public func action(_ event: Event<Value>) {
        self.events.append(event)
    }
    
    /// Get all of the next values emitted by the signal.
    public var values: [Value] {
        return self.events
            .map { $0.element }
            .filter { $0 != nil}
            .map { $0! }
    }
    
    /// Get the last value emitted by the signal.
    public var lastValue: Value? {
        return self.values.last
    }
    
    /// `true` if at least one `.Next` value has been emitted.
    public var didEmitValue: Bool {
        return self.values.count > 0
    }
    
    /// The failed error if the signal has failed.
    public var failedError: Error? {
        return self.events.filter { $0.error != nil }.map { $0.error! }.first
    }
    
    /// `true` if a `.Failed` event has been emitted.
    public var didFail: Bool {
        return self.failedError != nil
    }
    
    /// `true` if a `.Completed` event has been emitted.
    public var didComplete: Bool {
        return self.events.filter { $0.isCompleted }.count > 0
    }
    
    public func assertDidComplete(_ message: String = "Should have completed.",
                                    file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.didComplete, message, file: file, line: line)
    }
    
    public func assertDidFail(_ message: String = "Should have failed.",
                                file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.didFail, message, file: file, line: line)
    }
    
    public func assertDidNotFail(_ message: String = "Should not have failed.",
                                   file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(self.didFail, message, file: file, line: line)
    }
    
    public func assertDidEmitValue(_ message: String = "Should have emitted at least one value.",
                                     file: StaticString = #file, line: UInt = #line) {
        XCTAssert(self.values.count > 0, message, file: file, line: line)
    }
    
    public func assertDidNotEmitValue(_ message: String = "Should not have emitted any values.",
                                        file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(0, self.values.count, message, file: file, line: line)
    }
    
    public func assertValueCount(_ count: Int, _ message: String? = nil,
                                   file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(count, self.values.count, message ?? "Should have emitted \(count) values",
            file: file, line: line)
    }
}

extension TestObserver where Value: Equatable {
    public func assertValue(_ value: Value, _ message: String? = nil,
                              file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(1, self.values.count, "A single item should have been emitted.", file: file, line: line)
        XCTAssertEqual(value, self.lastValue, message ?? "A single value of \(value) should have been emitted",
            file: file, line: line)
    }
    
    public func assertLastValue(_ value: Value, _ message: String? = nil,
                                  file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(value, self.lastValue, message ?? "Last emitted value should equal to \(value).",
            file: file, line: line)
    }
    
    public func assertLastValueNot(_ value: Value, _ message: String? = nil,
                                  file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotEqual(value, self.lastValue, message ?? "Last emitted value should not equal to \(value).",
            file: file, line: line)
    }
    
    public func assertValues(_ values: [Value], _ message: String = "",
                               file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(values, self.values, message, file: file, line: line)
    }
}
