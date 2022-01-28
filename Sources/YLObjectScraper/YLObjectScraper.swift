import Foundation

open class YLObjectScraper<T: Codable> {
    var endPoint: URL
    var parameters: [String:String]?
    var networkManager: NetworkManager<T>
    var dataManager: DataManager<T>
    
    public init?(endPoint: String,
        networkHeader: [String: String]? = nil,
        parameters: [String: String]? = nil) {
        guard let endPoint = URL(string: endPoint) else {
            return nil
        }
        self.endPoint = endPoint
        self.parameters = parameters
        self.dataManager = DataManager(data: nil, url: URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("output"))
        networkManager = NetworkManager(header: networkHeader ?? [:])
    }
}

extension YLObjectScraper {
    open func get(with parameters: [String: String]? = nil,
             save: Bool = true,
             completion: ((T)->())? = nil,
             errorCompletion: ((NetworkFailureReason)->())? = nil) {

        networkManager.call(url: endPoint, parameters: parameters ?? self.parameters) { value in
            if save {
                self.dataManager.data = value
                self.save()
            }
            if let completion = completion { completion(value) }
        } errorCompletion: { failureReason in
            if let errorCompletion = errorCompletion {
                errorCompletion(failureReason)
            }
        }
    }
    
    func save() {
        dataManager.write()
    }
}

