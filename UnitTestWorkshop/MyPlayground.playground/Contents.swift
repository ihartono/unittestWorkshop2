//: What is Unit Tests
//: =
Just a function that invokes some of our code
and then asserts that the right thing happen

//: What kind of unit tests should i write
//: =
* a case that match you expectation (valid case)
* invalid case (something that should raise an error / exception)
* edge case (limitations like upper bounds of an integer)
* dangerous case (special inputs that might break your code)
* monkey tests (test with completely random values)

//: How to write tests
//: =
it("Check Last Value") {
    self.testOne.onNext([1])
    self.testOne.onNext([2])
    self.testOne.onNext([3])
    
    self.valueOne.assertLastValue([3])
}

//: How TestObserver work
//: =
class CreateShopViewModelBaseTest: QuickSpec {
    var disposeBag = DisposeBag()
    
    /** View model input */
    let shopNameSubject = PublishSubject<String>()
    
    /** View model output */
    var shopNameValue: TestObserver<String>!
    
    func setupBinding(viewModel: CreateShopViewModel) {
        disposeBag = DisposeBag()
        
        // Set shopNameValue with new observer
        self.shopNameValue = TestObserver<String>()
        
        let input = CreateShopViewModel.Input(
            shopNameTrigger: shopNameSubject.asDriverOnErrorJustComplete(),
        )
        
        let output = viewModel.transform(input: input)
        
        // shopNameValue will become subscriber of viewModel output
        output.shopNameValue
            .drive(self.shopNameValue.observer)
            .disposed(by: disposeBag)
    }
}

class CreateShopViewModelTest: CreateShopViewModelBaseTest {
    override func spec() {
        let useCase = CreateShopUsecase()
        
        beforeEach {
            self.setupBinding(viewModel: CreateShopViewModel(useCase: useCase))
        }
        
        // Describe: Exactly describes what component you are testing
        describe("Create Shop") {
            
            // Context: Describes the purpose of the test or the current state of an object
            context("User input shop name") {
                beforeEach {
                    useCase.checkShopNameAvailability = { _ in
                        return .just(true)
                    }
                    
                    self.shopNameSubject.onNext("supergadgettt")
                }
                
                // It: Describes the expected result of the test.
                it("Should display shop name") {
                    self.shopNameValue.assertValue("supergadgettt")
                }
            }
        }
    }
}

//: Different kind of it
//: =
* it
* fit (focus it)
* xit (exclude it)

//: You can have multiple it
//: =
describe("...") {
    context("...") {
        it("should return search result") {
            self.searchResult.assertLastValue(SearchExpectedValue.normalSearchResult)
        }

        it("should remove placeholder") {
            self.removePlaceholderView.assertDidEmitValue()
        }

        it("should not emit add placeholder") {
            self.addPlaceholderView.assertDidNotEmitValue()
        }

        it("should not emit error") {
            self.error.assertDidNotEmitValue()
        }

        it("should stop loading") {
            self.loadingStatus.assertLastValue(false)
        }

        it("should emit view controller title") {
            self.viewControllerTitle.assertLastValue(SearchExpectedValue.defaultUmrahSearchViewControllerTitle)
        }
    }
}


//: Mock UseCase
//: =
useCase.checkShopNameAvailability = { _ in
    return .just(true)
}

# Example uploadpedia

class UploadpediaUseCase {
    public func uploadFile(file: Data, host: String, fileType: FileType, sourceId: String) -> Observable<UploadHostResponse> {
        return _uploadFile(file, host, fileType, sourceId)
    }

    public lazy var _uploadFile = { [provider] file, host, fileType, sourceId in
        provider
            .request(.uploadFile(host: host, fileType: fileType, sourceId: sourceId, file: file))
            .mapWithNetworkError(UploadHostResponse.self)
    }
}

useCase._uploadFile = { _, _, _, _ -> Observable<UploadHostResponse> in
    .just(UploadHostResponse.success)
}

//: File Naming
//: =

ChatDetailViewModel.swift -> ChatDetailViewModelTest.swift


//: How to run unit test
//: =

cmd + U





Reference:
/**
 https://qiita.com/phanithken/items/651ae5cf38f46da96926
 https://www.swiftbysundell.com/basics/unit-testing/
 https://www.avanderlee.com/swift/unit-tests-best-practices/
 */

