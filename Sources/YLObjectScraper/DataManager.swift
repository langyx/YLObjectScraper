//
//  DataManager.swift
//  
//
//  Created by Yannis Lang on 29/10/2021.
//

import Foundation

struct DataManager<T: Codable> {
    private let encoder = JSONEncoder()
    var data: T?
    var url: URL
}

extension DataManager {
    private func encode() -> String? {
        guard let data = data else {
            return nil
        }
        do {
            let encodedData = try encoder.encode(data)
            return String(data: encodedData, encoding: .utf8)
        }catch{
            return nil
        }
    }
    
    func write() {
        guard let encodedData = encode() else {
            return
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        do {
            try encodedData.write(to: url.appendingPathComponent(String(describing: T.self)).appendingPathExtension("json"), atomically: true, encoding: .utf8)
        }catch {
            print(error.localizedDescription)
        }
    }
}
