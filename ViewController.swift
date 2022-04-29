//
//  ViewController.swift
//  BLEConnect
//
//  Created by Sivakumar on 18/02/22.
//

import UIKit
import CommonCrypto

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        let message     = "ivm"
//        let messageData = message.data(using:String.Encoding.utf8)!
//        let keyData     = "12345678901234567890123456789012".data(using:String.Encoding.utf8)!
//        let ivData      = "abcdefghijklmnop".data(using:String.Encoding.utf8)!
//
//        let encryptedData = testCrypt(data:messageData,   keyData:keyData, ivData:ivData, operation:kCCEncrypt)
//        let decryptedData = testCrypt(data:encryptedData, keyData:keyData, ivData:ivData, operation:kCCDecrypt)
//        var decrypted     = String(bytes:decryptedData, encoding:String.Encoding.utf8)!
//
//        print(encryptedData)
//        print(decryptedData)
//        print(encryptedData)
    }

    func testCrypt(data:Data, keyData:Data, ivData:Data, operation:Int) -> Data {
        let cryptLength  = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count:cryptLength)

        let keyLength             = size_t(kCCKeySizeAES128)
        let options   = CCOptions(kCCOptionPKCS7Padding)


        var numBytesEncrypted :size_t = 0

        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                ivData.withUnsafeBytes {ivBytes in
                    keyData.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(operation),
                                  CCAlgorithm(kCCAlgorithmAES),
                                  options,
                                  keyBytes, keyLength,
                                  ivBytes,
                                  dataBytes, data.count,
                                  cryptBytes, cryptLength,
                                  &numBytesEncrypted)
                    }
                }
            }
        }

        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)

        } else {
            print("Error: \(cryptStatus)")
        }

        return cryptData;
    }
}

