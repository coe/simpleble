//
//  MainViewController.swift
//  SimpleBle
//
//  Created by COFFEE on 2018/04/30.
//  Copyright © 2018年 tsuyoshi hyuga. All rights reserved.
//

import UIKit
import CoreBluetooth

/**
 * 画面起動時にBLEの準備を行う>OK
 * 画面起動時にPeripheralとしてのアドバタイズを行う > OK
 * スキャン画面に移行する機能をもつ > OK
 * カメラボタンで画像を取得する > OK
 * 送信ボタンを押したら画像を送信する > OK
 * Centralからデータを受信した、画像を表示する > OK
 */
class MainViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralManagerDelegate,CBPeripheralDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    let longDataServiceUuid = CBUUID(string: "D096F3C2-5148-410A-BA6A-20FEAD00D7CA")
    let longDataWriteCharacteristicUuid = CBUUID(string: "E053BD84-1E5B-4A6C-AD49-C672A737880C")
    let longDataWriteLengthCharacteristicUuid = CBUUID(string: "C4BDAB8A-BAC1-477A-925C-E1665553953C")
    
    var scanDataSource:ScanDataSource!
    var centralManager:CBCentralManager!
    var peripheralManager:CBPeripheralManager!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var connectLabel: UILabel!
    
    private var _connectedPeripheral:CBPeripheral?
    private var connectedPeripheral:CBPeripheral? {
        get {
            return _connectedPeripheral
        }
        set {
            _connectedPeripheral = newValue
            if newValue != nil {
                connectLabel.text = newValue!.name
            } else {
                connectLabel.text = "No Connect"
            }
        }
    }
    
    private var connectedPeripheralWriteCharacteristic:CBCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        scanDataSource = ScanDataSource()
        let endian = UInt32(CFByteOrderGetCurrent())
        switch endian {
        case CFByteOrderUnknown.rawValue:
            print("endian:CFByteOrderUnknow")
        case CFByteOrderLittleEndian.rawValue:
            print("endian:CFByteOrderLittleEndian")
        case CFByteOrderBigEndian.rawValue:
            print("endian:CFByteOrderBigEndian")
        default:
            break
        }

    }
    
    deinit {
        peripheralManager.stopAdvertising()
    }
    
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {
        case .poweredOn:
            print(#file,#function,#line,"central.state:poweredOn")
            break
        case .unknown:
            print(#file,#function,#line,"central.state:unknown")
            break
        case .resetting:
            print(#file,#function,#line,"central.state:resetting")
            break
        case .unsupported:
            print(#file,#function,#line,"central.state:unsupported")
            break
        case .unauthorized:
            print(#file,#function,#line,"central.state:unauthorized")
            break
        case .poweredOff:
            print(#file,#function,#line,"\(Date()) central.state:poweredOff")
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        print(#file,#function,#line)

        scanDataSource.append(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        print(#file,#function,#line)
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([longDataServiceUuid])

    }
    
    // MARK: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        print(#file,#function,#line)
        peripheral.services?.forEach({ (service) in
            print(#file,#function,#line,"service.uuid:\(service.uuid)")
            switch service.uuid {
            case longDataServiceUuid:
                peripheral.discoverCharacteristics([longDataWriteCharacteristicUuid,longDataWriteLengthCharacteristicUuid], for: service)
                break
            default:
                break
            }
        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
    {
        print(#file,#function,#line)
        
        if datas.count == 0 {
            print(#file,#function,#line,"終了")
        } else {
            let writeCharacteristic = connectedPeripheral?.services?.first(where: { (service) -> Bool in
                return service.uuid == longDataServiceUuid
            })?.characteristics?.first(where: { (characteristic) -> Bool in
                return characteristic.uuid == longDataWriteCharacteristicUuid
            })
            let popdata = datas.popFirst()!
            print(#file,#function,#line,"popdata:\(popdata.count)")

            peripheral.writeValue(popdata, for: writeCharacteristic!, type: CBCharacteristicWriteType.withResponse)
        }

    }
    
    
    // MARK: - CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            //サービス、キャラクタリスティック追加はpoweredOnの後
            let service:CBMutableService = CBMutableService(type: longDataServiceUuid, primary: true)
            let characteristic = CBMutableCharacteristic(type: longDataWriteCharacteristicUuid, properties: .writeWithoutResponse, value: nil, permissions: .writeable)
            
            //長さ取得用キャラクタリスティック
            let lengthCharacteristic = CBMutableCharacteristic(type: longDataWriteLengthCharacteristicUuid, properties: CBCharacteristicProperties.write, value: nil, permissions: CBAttributePermissions.writeable)
            
            service.characteristics = [characteristic,lengthCharacteristic]
            peripheralManager.add(service)
            
            //アドバタイジング開始
            let option:[String : Any] = [
                CBAdvertisementDataServiceUUIDsKey:[longDataServiceUuid,longDataWriteLengthCharacteristicUuid]
            ]
            peripheralManager.startAdvertising(option)
            break
        default:
            break
        }
    }
    
    private var receiverdData:Data = Data()
    private var tmpLength = 0
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest])
    {
        print(#file,#function,#line)
        requests.forEach { (request) in
            print(#file,#function,#line,"uuid:\(request.characteristic.uuid)")
            switch request.characteristic.uuid {
            case longDataWriteLengthCharacteristicUuid:
                let length:Int = request.value!.withUnsafeBytes { $0.pointee }
                print(#file,#function,#line,"request.value length:\(length)")
                tmpLength = Int(length)
                peripheral.respond(to: request, withResult: CBATTError.Code.success)
                break
            case longDataWriteCharacteristicUuid:
                print(#file,#function,#line,"request.value size:\(request.value?.count)")

                receiverdData.append(request.value!)
                if tmpLength == receiverdData.count {
                    let image = UIImage(data: receiverdData)
                    performSegue(withIdentifier: "showImage", sender: image)
                }
                peripheral.respond(to: request, withResult: CBATTError.Code.success)
                
                break
            default:
                peripheral.respond(to: request, withResult: CBATTError.Code.attributeNotFound)
                break
            }
            
        }
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
        let data = UIImageJPEGRepresentation(imageView.image!, 0.3)!
        //画像を分割
        let mtu = 180//peripheral.maximumWriteValueLength(for: .withResponse)
        
        print(#file,#function,#line,"端末限界mtu:\(mtu)")

        var maxsize = data.count

        var offset = 0
        while (maxsize > mtu) {
            var subdata = data.subdata(in: offset..<offset+mtu)
            //            val arr = it.sliceArray(offset..offset+mMtu-1)
            datas.append(subdata)
            //            sendingBytesList.add(arr)
            offset += mtu
            maxsize -= mtu
        }
        var subdata = data.subdata(in: offset..<data.count)
        datas.append(subdata)
        
        //初回はデータサイズ長を書き込む
        let writeCharacteristic = connectedPeripheral?.services?.first(where: { (service) -> Bool in
            return service.uuid == longDataServiceUuid
        })?.characteristics?.first(where: { (characteristic) -> Bool in
            return characteristic.uuid == longDataWriteLengthCharacteristicUuid
        })
        var dataSize = Int64(data.count)
        let dataSizeByte = Data(bytes: &dataSize, count: MemoryLayout.size(ofValue: dataSize))
        print(#file,#function,#line,"dataSize:\(dataSize)")
        print(#file,#function,#line,"dataSizeByte:\(dataSizeByte)")
        let hexStr = dataSizeByte.map {
            String(format: "%.2hhx", $0)
            }.joined()
        print(#file,#function,#line,"hexStr:\(hexStr)")

        peripheral.writeValue(dataSizeByte, for: writeCharacteristic!, type: CBCharacteristicWriteType.withResponse)
        
    }
    
    private var datas:ArraySlice<Data> = ArraySlice()
    private func sendBytes(data:Data,peripheral:CBPeripheral,writeCharacteristic:CBCharacteristic,mtu:Int){
        //データを分割して配列に突っ込む
        var maxsize = data.count
        var offset = 0
        while (maxsize > mtu) {
            var subdata = data.subdata(in: offset..<offset+mtu)
//            val arr = it.sliceArray(offset..offset+mMtu-1)
            datas.append(subdata)
//            sendingBytesList.add(arr)
            offset += mtu
            maxsize -= mtu
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
                viewController.centralManager = centralManager
                break
            case "showImage":
                let viewcontroller:ReceiveImageViewController = segue.destination as! ReceiveImageViewController
                viewcontroller.image = sender as! UIImage
                break
            default:
                break
            }
        }
    }

}
