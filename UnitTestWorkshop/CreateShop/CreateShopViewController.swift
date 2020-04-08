//
//  CreateShopViewController.swift
//  TokopediAlone
//
//  Created by Bondan Eko Prasetyo on 12/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

internal class CreateShopViewController: UIViewController {
    @IBOutlet var shopNameTextField: UITextField!
    @IBOutlet var shopNameError: UILabel!
    @IBOutlet var domainNameTextField: UITextField!
    @IBOutlet var domainNameError: UILabel!
    @IBOutlet var selectCityButton: UIButton!
    @IBOutlet var cityError: UILabel!
    @IBOutlet var postalCodeError: UILabel!
    @IBOutlet var postalCodeButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var switchTNC: UISwitch!
    
    private let selectedCitySubject = PublishSubject<City?>()
    private let selectedPostalCodeSubject = PublishSubject<String?>()
    
    private let viewModel: CreateShopViewModel
    
    @IBAction private func selectCity(_ sender: Any) {
        resignResponder()
        presentSelectCityView()
    }
    
    internal init(useCase: CreateShopUsecase) {
        self.viewModel = CreateShopViewModel(useCase: useCase)
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        let postalCodeTrigger = postalCodeButton.rx.tap.asDriver()
            .do(onNext: { [weak self] _ in
                self?.resignResponder()
            })
        
        let domainNameTrigger = domainNameTextField.rx.controlEvent(.editingChanged)
            .withLatestFrom(domainNameTextField.rx.value)
            .filterNil()
            .asDriverOnErrorJustComplete()
        
        let shopNameTrigger = shopNameTextField.rx.controlEvent(.editingChanged)
            .withLatestFrom(shopNameTextField.rx.value)
            .filterNil()
            .asDriverOnErrorJustComplete()
        
        let switchTNCTrigger = switchTNC.rx.controlEvent(.valueChanged)
            .withLatestFrom(switchTNC.rx.value)
            .asDriverOnErrorJustComplete()
        
        let input = CreateShopViewModel.Input(
            didLoadTrigger: .just(()),
            domainNameTrigger: domainNameTrigger,
            inputCityTrigger: selectedCitySubject.asDriverOnErrorJustComplete(),
            shopNameTrigger: shopNameTrigger,
            postalCodeTrigger: postalCodeTrigger,
            switchTNCTrigger: switchTNCTrigger,
            postalCodeValueTrigger: selectedPostalCodeSubject.asDriverOnErrorJustComplete()
        )
        
        let output = self.viewModel.transform(input: input)
        
        output.shopNameValue
            .drive()
            .disposed(by: rx_disposeBag)
        
        output.domainNameValue
            .drive(onNext:{ [weak self] value in
                self?.domainNameTextField.text = value
            })
            .disposed(by: rx_disposeBag)
        
        output.shopNameError
            .drive(onNext:{ [weak self] value in
                self?.shopNameError.text = value
            })
            .disposed(by: rx_disposeBag)
        
        output.shopNameErrorIsHidden
            .drive(onNext: { [weak self] isHidden in
                self?.shopNameError.isHidden = isHidden
            })
            .disposed(by: rx_disposeBag)
        
        output.domainNameError
            .drive(onNext:{ [weak self] value in
                if let value = value {
                    self?.domainNameError.text = value
                }
            }).disposed(by: rx_disposeBag)
        
        output.domainErrorIsHidden
            .drive(onNext: { [weak self] isHidden in
                self?.domainNameError.isHidden = isHidden
            })
            .disposed(by: rx_disposeBag)
        
        output.city.map { $0.name }
            .drive(selectCityButton.rx.title())
            .disposed(by: rx_disposeBag)
        
        output.cityError
            .drive(onNext:{ [weak self] value in
                self?.cityError.text = value
            })
            .disposed(by: rx_disposeBag)
        
        output.postalCode
            .drive(self.postalCodeButton.rx.title())
            .disposed(by: rx_disposeBag)
        
        output.postalCodeError
            .drive(onNext:{ [weak self] value in
                self?.postalCodeError.text = value
            })
            .disposed(by: rx_disposeBag)
        
        output.submitButtonEnabled
            .drive(self.submitButton.rx.isEnabled)
            .disposed(by: rx_disposeBag)
        
        output.presentPostalCodeView
            .flatMapLatest { city -> Driver<String?> in
                let vc = PostalCodeViewController(city: city)
                let nav = UINavigationController(rootViewController: vc)
                UIApplication.topViewController()?.present(nav, animated: true, completion: nil)
                
                return vc.postalCodeSelected
            }
            .drive(selectedPostalCodeSubject)
            .disposed(by: rx_disposeBag)
        
        
        output.postalErrorIsHidden
            .drive(onNext: { [weak self] isHidden in
                self?.postalCodeError.isHidden = isHidden
            })
            .disposed(by: rx_disposeBag)
        
        output.cityErrorIsHidden
            .drive(onNext: { [weak self] isHidden in
                self?.cityError.isHidden = isHidden
            })
            .disposed(by: rx_disposeBag)
    }
    
    private func presentSelectCityView() {
        let vc = CityViewController()
        
        vc.selectedCityDriver
            .drive(selectedCitySubject)
            .disposed(by: rx_disposeBag)
        
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    private func resignResponder() {
        shopNameTextField.resignFirstResponder()
        domainNameTextField.resignFirstResponder()
    }

}
