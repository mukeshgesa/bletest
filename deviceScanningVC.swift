//
//  deviceScanningVC.swift
//  OptixMeter
//
//  Created by gesdevios2 on 30/09/21.
//

import UIKit
import CoreBluetooth

//MARK: deviceScanningVC Class
class deviceScanningVC: UIViewController {

    //MARK: Connect the needed controls
    @IBOutlet weak var lblBLEDeviceName: UILabel!
    @IBOutlet weak var lblBLEAddress: UILabel!
    @IBOutlet weak var tblVwScanningDevice: UITableView!
    
    //MARK: Declare Local variable
    var var_CheckStatus: String = ""
    var peripherals:[CBPeripheral] = []
    var manager:CBCentralManager? = nil
    var fromPageVar: String = ""
    
    //MARK: viewDidLoad Function
    override func viewDidLoad() {
        super.viewDidLoad()
        delgate()
    }
    
    //MARK: Connect the delegates
    func delgate() {
        tblVwScanningDevice.delegate = self
        tblVwScanningDevice.dataSource = self
    }
    
    //MARK: View will Appear
    override func viewWillAppear(_ animated: Bool) {
        peripherals.removeAll()
        let dispatchTime3: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime3, execute: {
            self.manager = CBCentralManager(delegate: self, queue: nil)
        })
    }
    
    //MARK: Action for back button
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Action for buttton Refresh
    @IBAction func btnRefresh(_ sender: Any) {
        peripherals.removeAll()
        let dispatchTime3: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime3, execute: {
            self.manager = CBCentralManager(delegate: self, queue: nil)
        })
    }
    
    // MARK: BLE Scanning
    func scanBLEDevices() {
        manager?.scanForPeripherals(withServices: nil, options: nil)
        
        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopScanForBLEDevices()
        }
    }
    
    //MARK:  Its used to stop the BLE Scan
    func stopScanForBLEDevices() {
        manager?.stopScan()
    }
    
}

//MARK: Extension for TableviewDelegate and Datasource
extension deviceScanningVC: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripherals.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ScanningCell
        let peripheral = peripherals[indexPath.row]
        let address = UIDevice.current.identifierForVendor?.uuidString
        if peripheral.name == nil{
            cell.lblBLEDeviceName.text = "Unknown BLE Device"
           // cell.lblBLEAddress.text = address
        } else{
            cell.lblBLEDeviceName.text = peripheral.name
            //cell.lblBLEAddress.text = address
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = peripherals[indexPath.row]
        manager?.connect(peripheral, options: nil)
    }
}

//MARK: Extension for CBPeripheralDelegate and CBCentralManagerDelegate
extension deviceScanningVC:  CBPeripheralDelegate, CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
       // print(central.state)
        var msg = ""
        switch central.state {
            case .poweredOff:
                msg = "Bluetooth is Off"
            case .poweredOn:
                msg = "Bluetooth is On"
                self.scanBLEDevices()
            case .unsupported:
                msg = "Not Supported"
            default:
                msg = "🥰"
        }
    }
    
        // MARK: - CBCentralManagerDelegate Methods
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            if(!peripherals.contains(peripheral)) {
                 peripherals.append(peripheral)
            }
            //print(peripherals)
            self.tblVwScanningDevice.reloadData()
        }
        
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            var_CheckStatus = ""
            
//            if fromPageVar == "WO-VC" {
//                print("Ready to be page...")
//
//            } else {
                let mainview = self.storyboard?.instantiateViewController(withIdentifier: "dataForBLEDeviceVC") as! dataForBLEDeviceVC
                //pass reference to connected peripheral to parent view
                mainview.mainPeripheral = peripheral
                peripheral.delegate = mainview
                peripheral.discoverServices(nil)
            self.present(mainview, animated: true, completion: nil)
                print("Connected to " +  peripheral.name!)
                mainview.var_DeviceName = peripheral.name ?? "Device Name is Empty"
                var_CheckStatus = "Connected"
                mainview.var_DeviceStatus = var_CheckStatus
//            }
            
        }
        
        func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            print(error!)
            var_CheckStatus = "DisConnected"
        }
    
    }


