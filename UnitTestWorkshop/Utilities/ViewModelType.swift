//
//  ViewModelType.swift
//  RevampBankAccountUI
//
//  Created by Jefferson Setiawan on 24/07/18.
//  Copyright © 2018 Jefferson Setiawan. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
