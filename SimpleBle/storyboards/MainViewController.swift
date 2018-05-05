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
        

    }
    
    deinit {
        peripheralManager.stopAdvertising()
    }
    
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(#file,#function,#line)

        switch central.state {
        case .poweredOn:
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
            print(#file,#function,#line,"characteristics:\(service.characteristics?.count)")

            service.characteristics?.forEach({ (characteristic) in
                print(#file,#function,#line,"characteristic.uuid:\(characteristic.uuid)")
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
    
    
    /*!
     *  @method peripheralManager:willRestoreState:
     *
     *  @param peripheral    The peripheral manager providing this information.
     *  @param dict            A dictionary containing information about <i>peripheral</i> that was preserved by the system at the time the app was terminated.
     *
     *  @discussion            For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into
     *                        the background to complete some Bluetooth-related task. Use this method to synchronize your app's state with the state of the
     *                        Bluetooth system.
     *
     *  @seealso            CBPeripheralManagerRestoredStateServicesKey;
     *  @seealso            CBPeripheralManagerRestoredStateAdvertisementDataKey;
     *
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]){
        print(#file,#function,#line)

    }
    
    
    /*!
     *  @method peripheralManagerDidStartAdvertising:error:
     *
     *  @param peripheral   The peripheral manager providing this information.
     *  @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion         This method returns the result of a @link startAdvertising: @/link call. If advertisement could
     *                      not be started, the cause will be detailed in the <i>error</i> parameter.
     *
     */
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?){
        print(#file,#function,#line)
    }
    
    
    /*!
     *  @method peripheralManager:didAddService:error:
     *
     *  @param peripheral   The peripheral manager providing this information.
     *  @param service      The service that was added to the local database.
     *  @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion         This method returns the result of an @link addService: @/link call. If the service could
     *                      not be published to the local database, the cause will be detailed in the <i>error</i> parameter.
     *
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?){
        print(#file,#function,#line,"\(error)")
    }
    
    
    /*!
     *  @method peripheralManager:central:didSubscribeToCharacteristic:
     *
     *  @param peripheral       The peripheral manager providing this update.
     *  @param central          The central that issued the command.
     *  @param characteristic   The characteristic on which notifications or indications were enabled.
     *
     *  @discussion             This method is invoked when a central configures <i>characteristic</i> to notify or indicate.
     *                          It should be used as a cue to start sending updates as the characteristic value changes.
     *
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic){
        print(#file,#function,#line)
    }
    
    
    /*!
     *  @method peripheralManager:central:didUnsubscribeFromCharacteristic:
     *
     *  @param peripheral       The peripheral manager providing this update.
     *  @param central          The central that issued the command.
     *  @param characteristic   The characteristic on which notifications or indications were disabled.
     *
     *  @discussion             This method is invoked when a central removes notifications/indications from <i>characteristic</i>.
     *
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic){
        print(#file,#function,#line)

    }
    
    
    /*!
     *  @method peripheralManager:didReceiveReadRequest:
     *
     *  @param peripheral   The peripheral manager requesting this information.
     *  @param request      A <code>CBATTRequest</code> object.
     *
     *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request for a characteristic with a dynamic value.
     *                      For every invocation of this method, @link respondToRequest:withResult: @/link must be called.
     *
     *  @see                CBATTRequest
     *
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest){
        print(#file,#function,#line)

    }
    
    
    /*!
     *  @method peripheralManagerIsReadyToUpdateSubscribers:
     *
     *  @param peripheral   The peripheral manager providing this update.
     *
     *  @discussion         This method is invoked after a failed call to @link updateValue:forCharacteristic:onSubscribedCentrals: @/link, when <i>peripheral</i> is again
     *                      ready to send characteristic value updates.
     *
     */
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager){
        print(#file,#function,#line)
    }
    
    
    /*!
     *  @method peripheralManager:didPublishL2CAPChannel:error:
     *
     *  @param peripheral   The peripheral manager requesting this information.
     *  @param PSM            The PSM of the channel that was published.
     *  @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion         This method is the response to a  @link publishL2CAPChannel: @/link call.  The PSM will contain the PSM that was assigned for the published
     *                        channel
     *
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?){
        print(#file,#function,#line)
    }
    
    
    /*!
     *  @method peripheralManager:didUnublishL2CAPChannel:error:
     *
     *  @param peripheral   The peripheral manager requesting this information.
     *  @param PSM            The PSM of the channel that was published.
     *  @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion         This method is the response to a  @link unpublishL2CAPChannel: @/link call.
     *
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?){
        print(#file,#function,#line)
    }
    
    
    /*!
     *  @method peripheralManager:didOpenL2CAPChannel:error:
     *
     *  @param peripheral   The peripheral manager requesting this information.
     *  @param requests     A list of one or more <code>CBATTRequest</code> objects.
     *
     *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request or command for one or more characteristics with a dynamic value.
     *                      For every invocation of this method, @link respondToRequest:withResult: @/link should be called exactly once. If <i>requests</i> contains
     *                      multiple requests, they must be treated as an atomic unit. If the execution of one of the requests would cause a failure, the request
     *                      and error reason should be provided to <code>respondToRequest:withResult:</code> and none of the requests should be executed.
     *
     *  @see                CBATTRequest
     *
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?){
        print(#file,#function,#line)
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
                tmpLength = length
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
        let data = UIImagePNGRepresentation(imageView.image!)!
        sendBytes(data: data, peripheral: peripheral, writeCharacteristic: connectedPeripheralWriteCharacteristic!,mtu:peripheral.maximumWriteValueLength(for: .withoutResponse))
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
