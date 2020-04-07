//
//  PostalCodeViewController.swift
//  TokopediAlone
//
//  Created by Bondan Eko Prasetyo on 16/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class PostalCodeViewController: UIViewController {
    private let postalCodeSubject = PublishSubject<String?>()
    internal var postalCodeSelected: Driver<String?> {
        return postalCodeSubject.asDriverOnErrorJustComplete().do(onNext:{ [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
    }
    private let city: City?
    
    init(city: City?){
        self.city = city
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bar = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(batal))
        navigationItem.rightBarButtonItem = bar
    }
    
    @IBAction func postalCode(_ sender: UIButton) {
        if let city = city, let title = sender.currentTitle {
            let zipCode = "\(city.name)-\(title)"
            postalCodeSubject.onNext(zipCode)
        }
    }
    
    @objc private func  batal() {
        postalCodeSubject.onNext(nil)
    }
}
