//
//  AESEncryption.swift
//  BLEConnect
//
//  Created by Sivakumar on 20/04/22.
//

import CommonCrypto
import Foundation

struct AES {
    private let key: Data
    private let iv: Data
    
    init?(key: String, iv: String) {
        guard key.count == kCCKeySizeAES128
                || key.count == kCCKeySizeAES256,
              let keyData = key.data(using: .utf8) else {
            debugPrint("Error: Failed to set a key.")
            return nil
        }
        
        guard iv.count == kCCBlockSizeAES128,
              let ivData = iv.data(using: .utf8) else {
            debugPrint("Error: Failed to set and initial vector.")
            return nil
        }
        self.key = keyData
        self.iv = ivData
    }
    
    //MARK: - Function
    //MARK: - Public
    func encrypt(string: String) -> Data? {
        return crypt(data: string.data(using: .utf8), option: CCOperation(kCCEncrypt))
    }
    
    func decrypt(data: Data?) -> String? {
        guard let decryptData = crypt(data: data, option: CCOperation(kCCDecrypt)) else { return nil }
        return String(bytes: decryptData, encoding: .utf8)
    }
    
    func crypt(data: Data?, option: CCOperation) -> Data? {
        guard let data = data else { return nil }
        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData = Data(count: cryptLength)
        let keyLength = key.count
        let options = CCOptions(kCCOptionPKCS7Padding)
        var bytesLength = Int(0)
        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(option, CCAlgorithm(kCCAlgorithmAES), options, keyBytes.baseAddress, keyLength, ivBytes.baseAddress, dataBytes.baseAddress, data.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
                    }
                }
            }
        }
        guard UInt32(status) == UInt32(kCCSuccess) else {
            debugPrint("Error: Failed to crypt data. Status \(status)")
            return nil
        }
        
        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
}

extension String {
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) {
            match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        guard data.count > 0 else {return nil}
   
        return data
    }
}

extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0)}.joined()
    }
}
