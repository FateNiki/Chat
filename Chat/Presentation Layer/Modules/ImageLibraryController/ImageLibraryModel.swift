import Foundation

protocol ImageLibraryModelProtocol: class {
    var delegate: ImageLibraryModelDelegate? { get set }
    
    func fetch()
    func getCount() -> Int
    func getImageResult(for index: Int) -> ImageResult
}

protocol ImageLibraryModelDelegate: class {
    func imagesDidLoad()
    func imagesDidNotLoad(with errorMessage: String)
    func updateRow(at index: Int)
}

class ImageLibraryModel: ImageLibraryModelProtocol {
    private let libraryService: OnlineImageLibrary
    weak var delegate: ImageLibraryModelDelegate?
    
    init(libraryService: OnlineImageLibrary) {
        self.libraryService = libraryService
    }
    
    func fetch() {
        libraryService.getImagesList { [weak delegate] (error) in
            DispatchQueue.main.async {
                if let error = error {
                    delegate?.imagesDidNotLoad(with: error.message)
                    return
                }
                delegate?.imagesDidLoad()
            }
        }
    }
    
    func getCount() -> Int { libraryService.count }
    
    func getImageResult(for index: Int) -> ImageResult {
        return libraryService.getImage(for: index) { [weak delegate] (_, indexForReload) in
            DispatchQueue.main.async {
                delegate?.updateRow(at: indexForReload)
            }
        }
    }    
}
