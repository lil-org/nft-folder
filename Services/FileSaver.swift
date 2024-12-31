// ∅ 2025 lil org

import Foundation

struct FileSaver {
    
    static let shared = FileSaver()
    private init() {}
    
    private let fileManager = FileManager.default
    
    func saveForTask(_ task: DownloadFileTask, tmpLocation: URL?, data: Data?, fileExtension: String) -> URL? {
        return save(name: task.fileName, tmpLocation: tmpLocation, data: data, fileExtension: fileExtension, task: task)
    }
    
    private func save(name: String, tmpLocation: URL?, data: Data?, fileExtension: String, task: DownloadFileTask) -> URL? {
        if fileExtension.lowercased() == "json" || fileExtension.lowercased() == "txt" {
            let mbJsonData: Data?
            if let tmpLocation = tmpLocation, let tmpData = try? Data(contentsOf: tmpLocation) {
                mbJsonData = tmpData
            } else if let data = data {
                mbJsonData = data
            } else {
                mbJsonData = nil
            }
            if let mbJsonData = mbJsonData, let dataOrURL = extractValueFromJson(jsonData: mbJsonData) {
                if let tmpLocation = tmpLocation {
                    try? FileManager.default.removeItem(at: tmpLocation)
                }
                
                switch dataOrURL {
                case .data(let data, let fileExtension):
                    return save(name: name, tmpLocation: nil, data: data, fileExtension: fileExtension, task: task)
                case .url(let url):
                    return url
                }
            }
        }
        let pathExtension = "." + fileExtension
        var finalName = name.hasSuffix(pathExtension) ? name : (name.trimmingCharacters(in: .whitespacesAndNewlines) + pathExtension)
        finalName = finalName.replacingOccurrences(of: "/", with: "-")
        let destinationFileURL = task.fileDestinationDirectory.appendingPathComponent(finalName)
        saveAvoidingCollisions(tmpLocation: tmpLocation, data: data, destinationFileURL: destinationFileURL, task: task)
        return nil
    }
    
    private func saveAvoidingCollisions(tmpLocation: URL?, data: Data?, destinationFileURL: URL, task: DownloadFileTask) {
        guard let contentHash = task.currentURL?.fnv1aHash() ?? data?.fnv1aHash(),
              !MetadataStorage.has(contentHash: contentHash, addressDirectoryURL: task.walletRootDirectory) else {
            if let tmpLocation = tmpLocation {
                try? FileManager.default.removeItem(at: tmpLocation)
            }
            return
        }
        
        func uniqueURL(for url: URL, tmpLocation: URL?, data: Data?) -> URL {
            let fileName = url.deletingPathExtension().lastPathComponent
            let fileExtension = url.pathExtension
            let newName = fileName.contains(task.detailedMetadata.tokenId) ? fileName : "\(fileName) #\(task.detailedMetadata.tokenId)"
            var newURL = url.deletingLastPathComponent().appendingPathComponent(newName).appendingPathExtension(fileExtension)
            var count = 1
            while fileManager.fileExists(atPath: newURL.path) && areFilesDifferent(url1: newURL, url2: tmpLocation, data: data) {
                newURL = url.deletingLastPathComponent().appendingPathComponent("\(newName) \(count)").appendingPathExtension(fileExtension)
                count += 1
            }
            return newURL
        }
        
        func areFilesDifferent(url1: URL, url2: URL?, data: Data?) -> Bool {
            guard let fileAttributes = try? fileManager.attributesOfItem(atPath: url1.path),
                  let fileSize = fileAttributes[.size] as? NSNumber else { return true }
            
            if let data = data {
                if fileSize.intValue != data.count { return true }
                guard let fileData = try? Data(contentsOf: url1) else { return true }
                return fileData != data
            } else if let url2 = url2 {
                guard let file2Attributes = try? fileManager.attributesOfItem(atPath: url2.path),
                      let file2Size = file2Attributes[.size] as? NSNumber else { return true }
                if fileSize.int64Value != file2Size.int64Value { return true }
                guard let fileData = try? Data(contentsOf: url1) else { return true }
                guard let file2Data = try? Data(contentsOf: url2) else { return true }
                return fileData != file2Data
            } else {
                return true
            }
        }
        
        if task.hasCustomFolderName, !fileManager.fileExists(atPath: task.fileDestinationDirectory.path) {
            try? fileManager.createDirectory(at: task.fileDestinationDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        
        var finalDestinationURL = destinationFileURL
        do {
            if let tmpLocation = tmpLocation {
                if fileManager.fileExists(atPath: destinationFileURL.path), areFilesDifferent(url1: destinationFileURL, url2: tmpLocation, data: nil) {
                    finalDestinationURL = uniqueURL(for: destinationFileURL, tmpLocation: tmpLocation, data: nil)
                }
                try fileManager.moveItem(at: tmpLocation, to: finalDestinationURL)
            } else if let data = data {
                if fileManager.fileExists(atPath: destinationFileURL.path) && areFilesDifferent(url1: destinationFileURL, url2: nil, data: data) {
                    finalDestinationURL = uniqueURL(for: destinationFileURL, tmpLocation: nil, data: data)
                }
                try data.write(to: finalDestinationURL)
            } else {
                return
            }
        } catch { }
        
        let minimalMetadata = task.detailedMetadata.minimalMetadata(dowloadedFileSourceURL: task.currentURL)
        MetadataStorage.store(minimalMetadata: minimalMetadata, filePath: finalDestinationURL.path)
        MetadataStorage.store(detailedMetadata: task.detailedMetadata, correspondingTo: minimalMetadata, addressDirectoryURL: task.walletRootDirectory)
        MetadataStorage.store(contentHash: contentHash, addressDirectoryURL: task.walletRootDirectory)
        
        if let extraFolders = task.extraCustomFolders, !extraFolders.isEmpty {
            for anotherFolder in extraFolders {
                if let extraDestination = finalDestinationURL.replacingFolder(with: anotherFolder) {
                    let extraDestinationDirectory = extraDestination.deletingLastPathComponent()
                    if !fileManager.fileExists(atPath: extraDestinationDirectory.path) {
                        try? fileManager.createDirectory(at: extraDestinationDirectory, withIntermediateDirectories: false, attributes: nil)
                    }
                    try? fileManager.copyItem(at: finalDestinationURL, to: extraDestination)
                    MetadataStorage.store(minimalMetadata: minimalMetadata, filePath: extraDestination.path)
                }
            }
        }
    }
    
    private func extractValueFromJson(jsonData: Data) -> DataOrUrl? {
        if let inlineContentJSON = try? JSONDecoder().decode(InlineContentJSON.self, from: jsonData),
           let inlineDataString = inlineContentJSON.dataString,
           let dataOrURL = DataOrUrl(urlString: inlineDataString) {
            return dataOrURL
        }
        
        guard let jsonStringRaw = String(data: jsonData, encoding: .utf8), !jsonStringRaw.isEmpty else { return nil }
        
        let jsonString = jsonStringRaw.removingPercentEncoding ?? jsonStringRaw
        for key in ["animation_url", "image", "svg_image_data", "image_data"] {
            if let rangeOfKey = jsonString.range(of: "\"\(key)\"") {
                var start = jsonString.index(rangeOfKey.upperBound, offsetBy: 1)
                while start < jsonString.endIndex, jsonString[start] != "\"" {
                    start = jsonString.index(after: start)
                }
                if start < jsonString.endIndex, jsonString[start] == "\"" {
                    var end = jsonString.index(after: start)
                    while end < jsonString.endIndex, jsonString[end] != "\"" {
                        end = jsonString.index(after: end)
                    }
                    if end < jsonString.endIndex {
                        let valueStart = jsonString.index(after: start)
                        let result = String(jsonString[valueStart..<end])
                        if let dataOrURL = DataOrUrl(urlString: result) {
                            return dataOrURL
                        }
                    }
                }
            }
        }
        return nil
    }
    
}
