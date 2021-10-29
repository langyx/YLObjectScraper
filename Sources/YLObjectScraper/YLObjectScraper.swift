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
    func get(with parameters: [String: String]? = nil,
             save: Bool = true,
             completion: ((T)->())? = nil) {
        networkManager.call(url: endPoint, parameters: parameters ?? self.parameters) { value in
            self.dataManager.data = value
            if save { self.save() }
            if let completion = completion { completion(value) }
        }
    }
    
    func save() {
        dataManager.write()
    }
}

