//
//  CityViewController.swift
//  TokopediAlone
//
//  Created by Bondan Eko Prasetyo on 16/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

internal class CityViewController: UIViewController {
    private let selectCitySubject = PublishSubject<City?>()
    internal var selectedCityDriver: Driver<City?> {
        return selectCitySubject
            .asDriverOnErrorJustComplete()
            .do(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()

        let barButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(batal)
        )
        
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc private func batal() {
        selectCitySubject.onNext(nil)
    }
    
    @IBAction private func selectBekasi(_ sender: Any) {
        let city = City(id: "1", name: "Bekasi")
        
        selectCitySubject.onNext(city)
    }
    
    @IBAction private func selectJakarta(_ sender: Any) {
        let city = City(id: "2", name: "Jakarta")
        
        selectCitySubject.onNext(city)
    }
    
    @IBAction private func selectSemarang(_ sender: Any) {
        let city = City(id: "3", name: "Semarang")
        
        selectCitySubject.onNext(city)
    }
}
