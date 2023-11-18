// nft-folder-macos 2023 ethistanbul

import Foundation

struct WalletsService {
    
    enum WalletsServiceError: Error {
        case notAnAddress
    }
    
    private init() {}
    static let shared = WalletsService()
    private let urlSession = URLSession.shared
    
    var wallets: [WatchOnlyWallet] {
        return Defaults.watchWallets
    }
    
    private func isEthAddress(_ input: String) -> Bool {
        if input.hasSuffix(".eth") { return true }
        guard input.hasPrefix("0x") && input.count == 42 else { return false }
        let hexSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        let addressSet = CharacterSet(charactersIn: String(input.dropFirst(2)))
        return hexSet.isSuperset(of: addressSet)
    }
    
    func resolveENS(_ input: String, completion: @escaping (Result<ENSResponse, WalletsServiceError>) -> Void) {
        guard isEthAddress(input),
              let path = input.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.ensideas.com/ens/resolve/\(path)") else {
            completion(.failure(.notAnAddress))
            return
        }
        let dataTask = urlSession.dataTask(with: URLRequest(url: url)) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if error == nil, (200...299).contains(statusCode), let data = data, let response = try? JSONDecoder().decode(ENSResponse.self, from: data) {
                DispatchQueue.main.async { completion(.success(response)) }
            } else {
                DispatchQueue.main.async { completion(.failure(.notAnAddress)) }
            }
        }
        dataTask.resume()
    }
    
}
