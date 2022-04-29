//
//  dataForBLEDeviceVC.swift
//  OptixMeter
//
//  Created by gesdevios2 on 01/10/21.
//

import UIKit
import CommonCrypto
import CoreBluetooth

struct Command: Codable {
    var cmd: String
    var vls: [String]
}

struct QCCError: Error {
    var code: CCCryptorStatus
}

class dataForBLEDeviceVC: UIViewController {
    
    let RBL_SERVICE_UUID = "713D0000-503E-4C75-BA94-3148F18D941E"
    let RBL_CHAR_TX_UUID = "713D0002-503E-4C75-BA94-3148F18D941E"
    let RBL_CHAR_RX_UUID = "713D0003-503E-4C75-BA94-3148F18D941E"
    
    //MARK: Map the Outlets
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblBLECommand: UILabel!
    @IBOutlet weak var lblBLEData: UILabel!
    
    //MARK: Declare the local variable
    var var_DeviceName: String = ""
    var var_DeviceStatus: String = ""
    var passingCommands: String = ""
    var connectionState: String = ""
    var btnEnableFlag: Bool = false
    
    //MARK: Initialize the BLE variables
    var manager:CBCentralManager? = nil
    var mainPeripheral:CBPeripheral?
    var mainCharacteristic:CBCharacteristic? = nil
    var otherCharacteristic: [CBCharacteristic] = []
    
    //MARK: KEY AND IV FOR USING AES ALGORITHM
    //let keyData  = "abcdefghqasdfght"
    //let ivData  = Array("ui09ji884uh88984".utf8)
    
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //MARK: View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        lblDeviceName.text = var_DeviceName
        lblStatus.text = var_DeviceStatus
        lblAddress.text = "NaN"
    }
    
    //MARK: Back Button
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Bind the Values
    func bindCmdandData() {
        lblBLECommand.text = ""
        lblBLEData.text = ""
    }
    
    //MARK: Button Events
    @IBAction func receiveDataBasedOnCommand(_ sender: UIButton) {
        
        let key128 = "1234567890123456"  // 16bytes of AES128
        let key256 = "12345678901234561234567890123456" // 32 bytes of AES256
        let iv = "abcdefghijklmnop" // 16 bytes of AES128
        
        let aes128 = AES(key: key128, iv: iv)
        let aes256 = AES(key: key256, iv: iv)
        
        
            if sender.tag == 1 {
              passingCommands = "ivm"
              lblBLECommand.text = sender.titleLabel?.text
              let encryptData = aes128?.encrypt(string: passingCommands) ?? Data()
              print(encryptData)
                mainPeripheral?.writeValue(passingCommands.data(using: .utf8) ?? Data(), for: mainCharacteristic!, type: CBCharacteristicWriteType.withResponse)
//              let endCommand = ""
//              let endCrypt = aes128?.encrypt(string: endCommand) ?? Data()
              mainPeripheral?.writeValue("".data(using: .utf8) ?? Data(), for: mainCharacteristic!, type: CBCharacteristicWriteType.withResponse)
              let seconds = 1.0
              DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.mainPeripheral?.readValue(for: self.mainCharacteristic!)
              }
//                self.mainPeripheral?.readValue(for: self.mainCharacteristic!)
              // Need to read value again to get blank response from board
//              DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//                self.mainPeripheral?.readValue(for: self.mainCharacteristic!)
//              }
              btnEnableFlag = true
            
        } else if sender.tag == 2 {
            
            if btnEnableFlag == true {
                    sender.isUserInteractionEnabled = true
                    //passingCommands = “GN1”
                    //dataProcess(passCmd: passingCommands)
//                omainPeripheral?.writeValue("\n".data(using: .utf8) ?? Data(), for: mainCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                    let cmd = Command(cmd: "gn1", vls: [])
                    let jsonEncoder = JSONEncoder()
                    //let jsonObject = jsonEncoder.encode()
                    //let jsonObjectString: String?
                    do {
                      let jsonObject = try jsonEncoder.encode(cmd)
                      let jsonObjectString = String(data: jsonObject, encoding: .utf8)
                        
//                        let output = String(decoding: mainCharacteristic?.value ?? Data(), as: UTF8.self)
                        print(otherCharacteristic[0], ":done")
                        if let char = UserDefaults.standard.value(forKey: "char") as? CBCharacteristic{
                            mainCharacteristic = char
                        }
                        
                        
                      mainPeripheral?.writeValue("\(jsonObjectString ?? "")".data(using: .utf8) ?? Data(), for: otherCharacteristic[0], type: CBCharacteristicWriteType.withResponse)
                      mainPeripheral?.writeValue("".data(using: .utf8) ?? Data(), for: otherCharacteristic[0], type: CBCharacteristicWriteType.withResponse)
                    } catch {
                      print(error.localizedDescription)
                    }
                    let seconds = 1.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                      self.mainPeripheral?.readValue(for: self.mainCharacteristic!)
                    }
                    // Need to read value again to get blank response from board
//                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//                      self.mainPeripheral?.readValue(for: self.mainCharacteristic!)
//                    }
                    lblBLECommand.text = sender.titleLabel?.text
                  }
            
        } else if sender.tag == 3 {
            if btnEnableFlag == true {
                sender.isUserInteractionEnabled = true
                passingCommands = "GN2"
                //dataProcess(passCmd: passingCommands)
                lblBLECommand.text = sender.titleLabel?.text
            }
            
        }
    }
    
//    func writeBLECommand(Command: String) {
//        var bytesArray = [UInt8]()
//        do {
//            bytesArray = try QCCAESPadCBCEncrypt(key: keyData, iv: ivData, plaintext: [UInt8](Command.utf8))
//
//            var byteArrayList = [UInt8]()
//            byteArrayList = divideArray(source: bytesArray, chunkSize: 20)
//
//            for i in 0..<byteArrayList.count {
//                let bytesToSend = byteArrayList[i]
//                let dataToSend = Data(bytesToSend.description.utf8)
//                print(dataToSend)
//                mainPeripheral?.writeValue(dataToSend, for: mainCharacteristic!, type: CBCharacteristicWriteType.withResponse)
//            }
//
//            let emptyArray = [UInt8]()
//            let dataToSend = Data(emptyArray.description.utf8)
//            mainPeripheral?.writeValue(dataToSend, for: mainCharacteristic!, type: CBCharacteristicWriteType.withResponse)
////            mainPeripheral?.readValue(for: mainCharacteristic!)
//
//        } catch {
//            print("Write Exception")
//        }
//    }
    
    func divideArray(source: [UInt8] , chunkSize: Int) -> [UInt8] {
        var result = [UInt8]()
        var start = 0
        while (start < source.count) {
            let end = min(source.count, start + chunkSize)
            let finalValue = (copyOfRange(arr: source, from: start, to: end))
            result += (finalValue ?? [] )
            start += chunkSize
        }
        
        return result
    }
    
    func copyOfRange<T>(arr: [T], from: Int, to: Int) -> [T]? where T: ExpressibleByIntegerLiteral {
        guard from >= 0 && from <= arr.count && from <= to else { return nil }

        var to = to
        var padding = 0

        if to > arr.count {
            padding = to - arr.count
            to = arr.count
        }

        return Array(arr[from..<to]) + [T](repeating: 0, count: padding)
    }
    
    func readBLECommand(Command: String) {
        mainPeripheral?.readValue(for: mainCharacteristic!)
    }
    
//    func QCCAESPadCBCEncrypt(key: [UInt8], iv: [UInt8], plaintext: [UInt8]) throws -> [UInt8] {
//
//        guard
//            [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256].contains(key.count),
//                iv.count == kCCBlockSizeAES128
//        else {
//            throw QCCError(code: CCCryptorStatus(kCCParamError))
//        }
//
//        // Padding can expand the data, so we have to allocate space for that.  The
//           // rule for block cyphers, like AES, is that the padding only adds space on
//           // encryption (on decryption it can reduce space, obviously, but we don't
//           // need to account for that) and it will only add at most one block size
//           // worth of space.
//
//           var cyphertext = [UInt8](repeating: 0, count: plaintext.count + kCCBlockSizeAES128)
//           var cyphertextCount = 0
//           let err = CCCrypt(
//               CCOperation(kCCEncrypt),
//               CCAlgorithm(kCCAlgorithmAES),
//               CCOptions(kCCOptionPKCS7Padding),
//               key, key.count,
//               iv,
//               plaintext, plaintext.count,
//               &cyphertext, cyphertext.count,
//               &cyphertextCount
//           )
//           guard err == kCCSuccess else {
//               throw QCCError(code: err)
//            }
//
//           // The cyphertext can expand by up to one block but it doesn’t always use the full block,
//           // so trim off any unused bytes.
//
//           assert(cyphertextCount <= cyphertext.count)
//           cyphertext.removeLast(cyphertext.count - cyphertextCount)
//           assert(cyphertext.count.isMultiple(of: kCCBlockSizeAES128))
//
//           return cyphertext
//    }
    
//    func QCCAESPadCBCDecrypt(key: [UInt8], iv: [UInt8], cyphertext: [UInt8]) throws -> [UInt8] {
//
//        // The key size must be 128, 192, or 256.
//        //
//        // The IV size must match the block size.
//        //
//        // The ciphertext must be a multiple of the block size.
//
//        guard
//            [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256].contains(key.count),
//            iv.count == kCCBlockSizeAES128,
//            cyphertext.count.isMultiple(of: kCCBlockSizeAES128)
//        else {
//            throw QCCError(code: CCCryptorStatus(kCCParamError))
//        }
//
//        // Padding can expand the data on encryption, but on decryption the data can
//        // only shrink so we use the cyphertext size as our plaintext size.
//
//        var plaintext = [UInt8](repeating: 0, count: cyphertext.count)
//        var plaintextCount = 0
//        let err = CCCrypt(
//            CCOperation(kCCDecrypt),
//            CCAlgorithm(kCCAlgorithmAES),
//            CCOptions(kCCOptionPKCS7Padding),
//            key, key.count,
//            iv,
//            cyphertext, cyphertext.count,
//            &plaintext, plaintext.count,
//            &plaintextCount
//        )
//        guard err == kCCSuccess else {
//            throw QCCError(code: err)
//        }
//
//        // Trim any unused bytes off the plaintext.
//
//        assert(plaintextCount <= plaintext.count)
//        plaintext.removeLast(plaintext.count - plaintextCount)
//
//        return plaintext
//    }

    
    
    
//    func aesCrypt(data: [UInt8], keyData:[UInt8], ivData:[UInt8], operation:Int) -> [UInt8]? {
//        let cryptLength  = size_t(data.count + kCCBlockSizeAES128)
//        var cryptData = [UInt8](repeating: 0, count:cryptLength)
//
//        let keyLength             = size_t(kCCKeySizeAES128)
//        let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
//        let options:  CCOptions   = UInt32(kCCOptionPKCS7Padding)
//
//        var numBytesEncrypted :size_t = 0
//
//        let cryptStatus = CCCrypt(CCOperation(operation),
//                                  algoritm,
//                                  options,
//                                  keyData,
//                                  keyLength,
//                                  ivData,
//                                  data,
//                                  data.count,
//                                  &cryptData,
//                                  cryptLength,
//                                  &numBytesEncrypted)
//
//        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
//            // cryptData.remove
//            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
//
//        } else {
//            print("Error: \(cryptStatus)")
//        }
//
//        return cryptData;
//    }
    
//    func dataProcess(passCmd:  String) {
//
//        //guard let data = passCmd.data(using: .utf8) else { return }
//
//        //Convert the passing command into a bytes
//        //let bytesOfData = passCmd.data(using:String.Encoding.utf8)!
//
//        let bytesOfData: [UInt8] = Array(passCmd.utf8)
//
//
//        //Convert the bytesOfData into an encrypted text using AES
//        let encryptedData = aesCrypt(data:bytesOfData,   keyData:keyData, ivData:ivData, operation:kCCEncrypt)
//
//        print(encryptedData!)
//
//        let decryptedData = aesCrypt(data: encryptedData!, keyData: keyData, ivData: ivData, operation: kCCDecrypt)
//
//        print(decryptedData!)
//
//        //Working here to be
//
//        //getValueFromMeterBasedOnGivenCommands(cmd: encryptedData)
//
//    }
    
    //MARK: Getting Value from Meter based on the given Commands
    func getValueFromMeterBasedOnGivenCommands(cmd: String) {
        let dataToSend = Data(cmd.utf8)
        mainPeripheral?.writeValue(dataToSend, for: mainCharacteristic!, type: CBCharacteristicWriteType.withResponse)
        mainPeripheral?.readValue(for: mainCharacteristic!)
    }
    
}

//MARK: Delegate Method for CBPeripheral and CBCentralManager
extension dataForBLEDeviceVC: CBPeripheralDelegate, CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
        var msg = ""
        switch central.state {
        case .poweredOff:
            msg = "Bluetooth is Off"
        case .poweredOn:
            msg = "Bluetooth is On"
            
        case .unsupported:
            msg = "Not Supported"
        default:
            msg = "😔"
        }
        print(msg)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if peripheral.services != nil{
            for service in peripheral.services! {
                print("Service found with UUID: " + service.uuid.uuidString)
                //"00035B03-58E6-07DD-021A-08123A000300"
                //MARK: Get Service UUID
                if (service.uuid.uuidString == "CD7F80D7-9823-4500-8640-E1BE77A24669") {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (service.uuid.uuidString == "CD7F80D7-9823-4500-8640-E1BE77A24669") {
            for characteristic in service.characteristics! {
                print(characteristic.uuid.uuidString)
                //"00035B03-58E6-07DD-021A-08123A000301"
                if (characteristic.uuid.uuidString == "011C09B3-A49B-4CF3-B2FB-66AA01199F9C") {
//                    peripheral.readValue(for: characteristic)
                    mainCharacteristic = characteristic
                    otherCharacteristic.append(characteristic)
                    //                    UserDefaults.standard.set(characteristic, forKey: "char")
//                    do {
//                        let data = try NSKeyedArchiver.archivedData(withRootObject: characteristic, requiringSecureCoding: false)
//                        UserDefaults.standard.set(data, forKey: "char")
//                            print("successfully saved.")
//                        } catch {
//                            print("Fail to save.")
//                        }
                    
                    print("Found Device Name Characteristic")
                    if characteristic.properties.contains(.read) {
                        print("\(characteristic.uuid): properties contains .read")
                        print(characteristic)
                      //  peripheral.readValue(for: characteristic)
                    }
                    
                }
            }
            self.mainPeripheral?.setNotifyValue(true, for: self.mainCharacteristic!)
        }
    }
    
    //MARK: Getting Response
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        // MTU = 65
//        print("Max write value: \(peripheral.maximumWriteValueLength(for: .withResponse))")
//        print("Max write value: \(peripheral.maximumWriteValueLength(for: .withoutResponse))")
        
        if let value = characteristic.value {
            print("Data Received...")
            //value = ""
            print(value)
            let output = String(decoding: value, as: UTF8.self)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {

           print("didUpdateNotificationStateFor")

           print("characteristic description:", characteristic.description)

       }

    
    //MARK: Disconnect Peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.navigationController?.popViewController(animated: true)
        print("Disconnected " + peripheral.name!)
    }
}

