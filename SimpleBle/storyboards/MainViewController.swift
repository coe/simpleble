//
//  MainViewController.swift
//  SimpleBle
//
//  Created by COFFEE on 2018/04/30.
//  Copyright © 2018年 tsuyoshi hyuga. All rights reserved.
//

import UIKit
import CoreBluetooth

/// メインコントローラ
/// 全てのBleはここでもつ

class MainViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralManagerDelegate,CBPeripheralDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var scanDataSource:ScanDataSource!
    var centralManager:CBCentralManager!
    var peripheralManager:CBPeripheralManager!
    
//    let SERVICE_UUID = "D096F3C2-5148-410A-BA6A-20FEAD00D7CA"
//    let BIGDATA_WRITE_CHARACTERISTIC_UUID = "42184378-A26D-474B-82CA-43C03AA7A701"
//    let BIGDATA_LENGTH_CHARACTERISTIC_UUID = "62A9572E-3C99-4149-AFED-ED4C5CFD0242"
    
    let longDataServiceUuid = CBUUID(string: "D096F3C2-5148-410A-BA6A-20FEAD00D7CA")
    let longDataWriteCharacteristicUuid = CBUUID(string: "D096F3C2-5148-410A-BA6A-20FEAD00D7CA")

    @IBOutlet weak var scanButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    private var _connectedPeripheral:CBPeripheral?
    private var connectedPeripheral:CBPeripheral? {
        get {
            return _connectedPeripheral
        }
        set {
            _connectedPeripheral = newValue
            if newValue != nil {
                scanButton.title = _connectedPeripheral!.name
            } else {
                scanButton.title = "Scan"
            }
        }
    }
    
    private var connectedPeripheralWriteCharacteristic:CBCharacteristic?
    
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: [longDataServiceUuid], options: nil)
            break
            
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        scanDataSource.append(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([longDataServiceUuid])
    }
    
    // MARK: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        peripheral.services?.forEach({ (service) in
            service.characteristics?.forEach({ (characteristic) in
                if characteristic.uuid == longDataWriteCharacteristicUuid {
                    connectedPeripheralWriteCharacteristic = characteristic
                }
            })
        })
    }
    
    
    // MARK: - CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            //サービス、キャラクタリスティック追加はpoweredOnの後
            let service:CBMutableService = CBMutableService(type: longDataServiceUuid, primary: true)
            var characteristicsArray:[CBCharacteristic] = []
            let characteristic = CBMutableCharacteristic(type: longDataWriteCharacteristicUuid, properties: .write, value: nil, permissions: .writeable)
            
            characteristicsArray.append(characteristic)
            service.characteristics = characteristicsArray
            peripheralManager.add(service)
            break
        default:
            break
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        scanDataSource = ScanDataSource()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToTop(segue: UIStoryboardSegue,sender:Any?) {
        let scanTableViewController:ScanTableViewController = segue.source as! ScanTableViewController
        if let peripheral = scanTableViewController.selectedScannedPeripheral {
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    @IBAction func onClickButton(_ sender: Any) {
        if connectedPeripheral != nil {
            //切断
            
        } else {
            performSegue(withIdentifier: "showScan", sender: nil)
        }
    }
    
    @IBAction func onClickSend(_ sender: Any) {
        guard let peripheral = self.connectedPeripheral else {
            return
        }
        let data = UIImagePNGRepresentation(imageView.image!)
        sendBytes(data: data!, peripheral: connectedPeripheral!, writeCharacteristic: connectedPeripheralWriteCharacteristic!)
    }
    
    private var datas:ArraySlice<Data> = ArraySlice()
    private func sendBytes(data:Data,peripheral:CBPeripheral,writeCharacteristic:CBCharacteristic){
        //データを分割して配列に突っ込む
        var mMtu = 512
        var maxsize = data.count
        var offset = 0
        while (maxsize > mMtu) {
            var subdata = data.subdata(in: offset..<offset+mMtu)
//            val arr = it.sliceArray(offset..offset+mMtu-1)
            datas.append(subdata)
//            sendingBytesList.add(arr)
            offset += mMtu
            maxsize -= mMtu
        }
        var subdata = data.subdata(in: offset..<data.count)
        datas.append(subdata)

        //書き込む
        peripheral.writeValue(datas.popFirst()!, for: writeCharacteristic, type: CBCharacteristicWriteType.withoutResponse)

    }
    
    @IBAction func onClickCamera(_ sender: Any) {
        let pickerViewController = UIImagePickerController()
        pickerViewController.allowsEditing = false
        pickerViewController.delegate = self
        
        let alert = UIAlertController(title: "Image", message: "Select type", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let action = UIAlertAction(title: "camera", style: UIAlertActionStyle.default) { (action) in
                pickerViewController.sourceType = .camera
                self.present(pickerViewController, animated: true, completion: nil)
            }
            alert.addAction(action)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let action = UIAlertAction(title: "photoLibrary", style: UIAlertActionStyle.default) { (action) in
                pickerViewController.sourceType = .photoLibrary
                self.present(pickerViewController, animated: true, completion: nil)
            }
            alert.addAction(action)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let action = UIAlertAction(title: "savedPhotosAlbum", style: UIAlertActionStyle.default) { (action) in
                pickerViewController.sourceType = .photoLibrary
                self.present(pickerViewController, animated: true, completion: nil)
            }
            alert.addAction(action)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "showScan":
                let viewController:ScanTableViewController = segue.destination as! ScanTableViewController
                viewController.scanDataSource = scanDataSource
                viewController.longDataServiceUuid = longDataServiceUuid
                break
            default:
                break
            }
        }
    }

}
