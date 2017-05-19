//
//  MainViewController.swift
//  AnalytiCeM
//
//  Created by Gaël on 16/04/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import CoreBluetooth
import UIKit

import LocationManagerSwift
import RealmSwift
import Sparrow
import SwiftSpinner

class MainViewController: UIViewController, IXNMuseListener, IXNMuseConnectionListener, IXNMuseDataListener, SPRequestPermissionEventsDelegate, ActivityParameterDelegate {
    
    private enum MuseButtonStatus: Int {
        case connecting, connected, disconnected
    }
    
    // MARK: - Properties
    
    var locationTimer: Timer?
    var weatherTimer: Timer?
    var currentWeather: Weather?
    var owmManager: OWMManager!
    
    var bluetoothAvailable: Bool? {
        
        willSet(newBluetoothStatus) {
            
            // if we loose Bluetooth, disconnect Muse
            if (bluetoothAvailable == true && newBluetoothStatus == false) {
                disconnect()
            }
            
            // if we gain Bluetooth
            if (bluetoothAvailable == false && newBluetoothStatus == true) {
                if let leftButton = self.navigationItem.leftBarButtonItem {
                    leftButton.isEnabled = true
                }
            }
            
            
        }
        
        didSet {
    
            if let leftButton = self.navigationItem.leftBarButtonItem {
                leftButton.isEnabled = leftButton.isEnabled && bluetoothAvailable!
            }
            
        }
    }
    
    var internetAvailable: Bool = false {
        didSet {
        }
    }
    
    // Muse
    var museManager: IXNMuseManagerIos?
    weak var muse: IXNMuse?
    var currentMuse: Results<Muse>?
    var currentUser: Results<User>?
    
    let idleMaxPoints: Int = 60
    var emptyHistory: Array<EEGSnapshot> = Array<EEGSnapshot>()
    
    // the history of the last minute, 60 values, one per second
    var museHistory: [EEGType: Array<EEGSnapshot>] = [EEGType: Array<EEGSnapshot>]()
    
    // values retrieved in the last second
    var currentValues: [EEGType: Array<EEGSnapshot>] = [EEGType: Array<EEGSnapshot>]()
    var currentHistoryTimer: Timer?
    
    let realm = try! Realm()
    var notificationUser: NotificationToken? = nil
    
    // Session
    var currentSession: Session?
    var sessionTimer: Timer?
    // will always be positive
    var currentTime: UInt = 0
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var topLabel: HeyUILabel!
    @IBOutlet weak var sessionAction: StartStopSessionUIButton!

    @IBOutlet weak var waveView: WaveView!
    
    @IBOutlet weak var weatherView: WeatherView!
    @IBOutlet weak var gpsView: GPSView!
    
    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bluetoothAvailable = (BluetoothStatusManager.shared.currentStatus == .poweredOn)
        
        setupManagers()
        
        setupRealm()
        
        setupUI()
        
        initHistory()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        // subscribe
        registerBluetoothStatusChange(handler: handleBluetoothChange)
        registerInternetStatusChange(handler: handleInternetChange)
        // set the view as delegate
        museManager?.museListener = self
        updateHey()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // unsubscribe
        unregisterBluetoothStatusChange()
        unregisterInternetStatusChange()
        // unset the view as delegate
        museManager?.museListener = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*if let lastMuse = loadSavedMuse() {
            print(lastMuse)
        }*/
        setupLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        
        // button logout on the right
        let logoutButtonItem = UIBarButtonItem(image: UIImage(named: "main-logout"),
                                               style: .plain,
                                               target: self,
                                               action: #selector(MainViewController.logoutAction(_:))
                                )
        self.navigationItem.rightBarButtonItem = logoutButtonItem
        
        // title
        self.navigationItem.title = "AnalytiCeM"
        
        // set button to disconnected
        changeMuseButton(to: .disconnected)
        
        // session start/stop button
        self.sessionAction.update(to: .start, controller: self)
        
    }
    
    private func updateHey() {
        
        // observe results notifications
        notificationUser = self.currentUser?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
        
            switch changes {
            case .initial(let users):
                self?.topLabel.display(name: users.first?.firstName ?? "")
                break
            case .update(let users, _, _, _):
                self?.topLabel.display(name: users.first?.firstName ?? "")
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }
        }
    }
    
    deinit {
        notificationUser?.stop()
    }
    
    private func setupManagers() {
    
        // manager of OpenWeatherMap
        owmManager = OWMManager(apiKey: APIKey.openWeatherMap.getKey()!)
        
        // get the manager of Muse (singleton)
        museManager = IXNMuseManagerIos.sharedManager()
        
    }
    
    // MARK: - Location
    
    private func setupLocation() {
        
        // check permission
        guard SPRequestPermission.isAllowPermission(.locationWithBackground) else {
            
            // requestion permission to use location
            SPRequestPermission.dialog.interactive.present(
                on: self,
                with: [.locationWithBackground],
                delegate: self
            )
            return
        }
        
        // we can init
        initLocationRefresher()
        initWeatherRefresher()
        
    }
    
    @objc private func updateLocation() {
        self.gpsView.activityIndicator.startAnimating()
        LocationManagerSwift.shared.updateLocation(completionHandler: { (latitude, longitude, status, error) in
            
            guard status == .OK else {
                
                // then error
                var errorMessage: String?
                
                if !self.internetAvailable {
                    errorMessage = "Internet is not available"
                }
                
                if let error = error, errorMessage == nil {
                    errorMessage = error.localizedDescription
                }
                
                self.gpsView.display(error: errorMessage ?? "Unknown error")
                self.gpsView.activityIndicator.stopAnimating()
                return
                
            }
            
            // update map
            self.gpsView.changeZoomToCoordinate(latitude: latitude, longitude: longitude)
            
            // retrieve locality
            LocationManagerSwift.shared.reverseGeocodeLocation(type: .APPLE, completionHandler: { (country, state, city, reverseGecodeInfo, placemark, error) in
                
                // city, country and marker
                guard let city = city, let country = country, let placemark = placemark else {
                    
                    // then error
                    var errorMessage: String?
                    
                    if !self.internetAvailable {
                        errorMessage = "Internet is not available"
                    }
                    
                    if let error = error, errorMessage == nil {
                        errorMessage = error.localizedDescription
                    }
                    
                    self.gpsView.display(error: errorMessage ?? "Unknown error")
                    self.gpsView.activityIndicator.stopAnimating()
                    return
                    
                }
                
                self.gpsView.addMarker(placemark: placemark)
                self.gpsView.display(city: city, country: country)
                self.gpsView.activityIndicator.stopAnimating()
                
            })
            
            
        })
    }
    
    private func initLocationRefresher() {
        
        // in case of
        locationTimer?.invalidate()
        
        // init timer, every minute, until it's stopped
        locationTimer = Timer.scheduledTimer(
            timeInterval: 60,
            target: self,
            selector: #selector(updateLocation),
            userInfo: nil,
            repeats: true
        )
        
        // launch it now
        locationTimer?.fire()
    }
    
    private func stopLocationRefresher() {
        locationTimer?.invalidate()
    }
    
    // MARK: - Weather
    
    @objc private func updateWeather() {
        self.weatherView.activityIndicator.startAnimating()
        
        LocationManagerSwift.shared.updateLocation(completionHandler: { (latitude, longitude, status, error) in
            
            guard status == .OK else {
                
                // then error
                var errorMessage: String?
                
                if !self.internetAvailable {
                    errorMessage = "Internet is not available"
                }
                
                if let error = error, errorMessage == nil {
                    errorMessage = error.localizedDescription
                }
                
                self.weatherView.display(error: errorMessage ?? "Unknown error")
                self.weatherView.activityIndicator.stopAnimating()
                return
                
            }
            
            // get the weather
            self.owmManager.currentWeatherByCoordinatesAsJson(
                latitude: latitude,
                longitude: longitude,
                data: { result in
                    
                    switch result {
                        case .Success(let json):
                            let weather = Weather(json: json)
                            self.currentWeather = weather
                            self.weatherView.display(weather: weather)
                            break
                        case .Error(let errorMessage):
                            self.weatherView.display(error: errorMessage)
                            self.currentWeather = nil
                            break
                    }
                    
                    self.weatherView.activityIndicator.stopAnimating()
            
                }
            )
            
        })
        
    }
    
    private func initWeatherRefresher() {
        
        // in case of
        weatherTimer?.invalidate()
        
        // init timer, every 30 minutes, until it's stopped
        weatherTimer = Timer.scheduledTimer(
            timeInterval: 60*30,
            target: self,
            selector: #selector(updateWeather),
            userInfo: nil,
            repeats: true
        )
        
        // launch it now
        weatherTimer?.fire()
    }
    
    private func stopWeatherRefresher() {
        weatherTimer?.invalidate()
    }
    
    // MARK: - Realm
    
    private func setupRealm() {
        
        // get the current Muse
        currentMuse = realm.objects(Muse.self).filter("isCurrent == true")
        
        // get the current User
        currentUser = realm.objects(User.self).filter("isCurrent == true")
        
    }
    
    // MARK: - History
    
    private func initHistory() {
        
        // empty history
        emptyHistory = Array<EEGSnapshot>(repeating: EEGSnapshot.allZeros, count: idleMaxPoints)
        
        // create the differents history
        museHistory[.eeg] = emptyHistory
        museHistory[.alphaRelative] = emptyHistory
        museHistory[.betaRelative] = emptyHistory
        museHistory[.deltaRelative] = emptyHistory
        museHistory[.thetaRelative] = emptyHistory
        museHistory[.gammaRelative] = emptyHistory
        
        // create current values
        currentValues[.eeg] = Array<EEGSnapshot>()
        // todo: for each type
        
        // todo: init values of jaw and blink
        // int ?
        
    }
    
    private func initHistoryRefresher() {
        
        // in case of
        currentHistoryTimer?.invalidate()
        
        // init timer, every second, until it's stopped
        currentHistoryTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true,
            block: { (timer) in
                
                func calc(type: EEGType) {
                    
                    var sumLeftEar = self.currentValues[type]!
                        .map({ return $0.leftEar ?? 0 })
                        .reduce(0, +)
                    
                    if sumLeftEar != 0 {
                        sumLeftEar = sumLeftEar/Double(self.currentValues[type]!.count)
                    }
                    
                    var sumRightEar = self.currentValues[type]!
                        .map({ return $0.rightEar ?? 0 })
                        .reduce(0, +)
                    
                    if sumRightEar != 0 {
                        sumRightEar = sumRightEar/Double(self.currentValues[type]!.count)
                    }
                    
                    var sumLeftFront = self.currentValues[type]!
                        .map({ return $0.leftFront ?? 0 })
                        .reduce(0, +)
                    
                    if sumLeftFront != 0 {
                        sumLeftFront = sumLeftFront/Double(self.currentValues[type]!.count)
                    }
                    
                    var sumRightFront = self.currentValues[type]!
                        .map({ return $0.rightFront ?? 0 })
                        .reduce(0, +)
                    
                    if sumRightFront != 0 {
                        sumRightFront = sumRightFront/Double(self.currentValues[type]!.count)
                    }
                    
                    var snapshot = EEGSnapshot()
                    snapshot.leftEar = sumLeftEar
                    snapshot.rightEar = sumRightEar
                    snapshot.leftFront = sumLeftFront
                    snapshot.rightFront = sumRightFront
                    
                    // add the snapshot to the history
                    self.museHistory[type]!.append(snapshot)
                    
                    // forget surplus points
                    self.museHistory[type]!.removeSubrange(0 ..< max(0, self.museHistory[type]!.count - self.idleMaxPoints))
                }
                
                calc(type: .eeg)
                // todo:
                // calc the other types
                // removeAll currentvalues
                
                // then refresh the wave view
                self.refreshWaveView()
                
            }
        )
        
        // launch it now
        currentHistoryTimer?.fire()
    }
    
    private func stopHistoryRefresher() {
        currentHistoryTimer?.invalidate()
        // todo: reset to zero?
    }
    
    // MARK: - Muse Status Button
    
    private func changeMuseButton(to status: MuseButtonStatus) {
        
        // the attributes of the button to be set
        var button: (image: String, action: Selector?, enabled: Bool)
        
        switch status {
            case .connecting:
                button.image = "muse-connecting"
                button.enabled = false
                button.action = nil
                break
            case .connected:
                button.image = "muse-connected"
                button.enabled = true
                button.action = #selector(muse?.disconnect)
                break
            case .disconnected:
                button.image = "muse-disconnected"
                button.enabled = true
                // only if bluetooth is available
                if let bluetoothAvailable = bluetoothAvailable {
                    button.enabled = button.enabled && bluetoothAvailable
                }
                button.action = #selector(startResearchMuses)
                break
        }
        
        // button Muse status on the left
        let museStatusButtonItem = UIBarButtonItem(image: UIImage(named: button.image),
                                                   style: .plain,
                                                   target: self,
                                                   action: button.action
        )
        self.navigationItem.leftBarButtonItem = museStatusButtonItem
        self.navigationItem.leftBarButtonItem?.isEnabled = button.enabled
        
    }
    
    // MARK: - Muse
    
    @objc private func startResearchMuses() {
        
        self.muse = nil
        
        // only if we have bluetooth
        if let bluetoothAvailable = bluetoothAvailable, bluetoothAvailable {
            
            // start
            museManager?.startListening()
            // update to connecting status
            changeMuseButton(to: .connecting)
            
            // already Muses found, try to check
            if museManager?.getMuses().count != 0 {
               museListChanged()
            }
            
            // start a timer to stop after 5 seconds, if nothing found
            // prevent infinity search if no Muse, then list does not changed
            
            Timer.scheduledTimer(
                withTimeInterval: 10,
                repeats: false,
                block: { timer in
                    
                    if (self.muse == nil) {
                        self.disconnect()
                    }
                    
                }
            )

        }
    }
    
    func connect(to muse: IXNMuse) {
        
        // disconnect first (in case of)
        if let lMuse = self.muse, lMuse != muse {
            disconnect()
        }
        
        // save
        self.muse = muse
        
        // connection listener
        muse.register(self)
        // eeg data packet listener
        muse.register(self, type: .eeg)
        
        // todo: register all relatives and artifacts
        //muse?.register(self, type: .betaRelative)
        
        // launch
        muse.runAsynchronously()
    }
    
    func disconnect() {
        // stop listening to Muses
        museManager?.stopListening()
        // remove all listeners
        muse?.unregisterAllListeners()
        // disconnect
        muse?.disconnect()
        // change status
        changeMuseButton(to: .disconnected)
        // set
        self.muse = nil
    }
    
    // MARK: - IBAction & UIButton
    
    func logoutAction(_ sender: UIButton) {
        
        // create confirmation alert
        let alertController = UIAlertController(
            title: "Confirmation",
            message: "Are your sure you want to logout?",
            preferredStyle: .alert
        )
        
        // yes handler -> remove
        let yesAction = UIAlertAction(
            title: "Yes",
            style: .destructive,
            handler: { action in
                
                SwiftSpinner.show("Logout..")
                
                // logout
                let realm = try! Realm()
                let currentUser = realm.objects(User.self).filter("isCurrent == true").first
                
                // remove current user
                try! realm.write {
                    currentUser?.isCurrent = false
                }
                
                // after a second hide spinner
                // and display the login controller
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    SwiftSpinner.hide({
                        self.displayLogin()
                    })
                })
                
            }
        )
        alertController.addAction(yesAction)
        
        // no handler -> dismiss view only
        let noAction = UIAlertAction(
            title: "No",
            style: .cancel,
            handler: nil
        )
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func launchSession() {
        
        // the view to display
        let lPopupVC = NewSessionViewController(nibName: "NewSessionViewController", bundle: nil)
        
        // no background
        lPopupVC.view.backgroundColor = UIColor.clear
        
        // on top of the parent view
        lPopupVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        lPopupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        // delegate
        lPopupVC.delegate = self
        
        // display
        self.present(lPopupVC, animated: true, completion: nil)
        
    }
    
    func stopSession() {
        
        // stop & change label back
        self.stopSessionTimer()
        self.currentSession = nil
        
        //todo: add endtime to current session
        // stop timers (which ones ?)
        // logout to on
        
        // can start a new session
        self.sessionAction.update(to: .start, controller: self)
    }
    
    // MARK: - ActivityParameterDelegate
    
    func didChoose(parameters activity: Activity) {
        //dump(activity)
        
        var message: String?
        
        // weather
        if self.currentWeather == nil {
            message = "No weather"
        }
        
        // internet
        if !internetAvailable {
            message = "No internet"
        }
        
        // bluetooth
        if bluetoothAvailable == nil || !bluetoothAvailable! {
            message = "No Bluetooth"
        }
        
        // user
        if self.currentUser?.first == nil {
            message = "No user"
        }
        
        guard message != nil else {
            
            SwiftSpinner.show(message!, animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                SwiftSpinner.hide()
            }
            return
            
        }
        
        // display view with messages
        SwiftSpinner.show("Session is about\nto begin", animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            SwiftSpinner.show("Please keep the Muse\non your head",
                              animated: true
            )
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            SwiftSpinner.hide()
        }
        
        // button to stop mode
        self.sessionAction.update(to: .stop, controller: self)
        
        // create the session object
        let session = Session(start: NSDate(),
                              user: currentUser!.first!,
                              weather: currentWeather!,
                              activity: activity
        )
        
        // store it to realm
        try! realm.write {
            realm.add(session, update: true)
        }
        
        // keep a reference
        self.currentSession = session
        
        
        //todo:
        self.runSessionTimer()
        // init timers to generate data and add it to session each 10 sec
        // -> function
        // function to updateLocation every 10 sec
        // logout off
        
    }
    
    // MARK: - SPRequestPermissionEventsDelegate
    
    func didHide() {}
    
    func didAllowPermission(permission: SPRequestPermissionType) {
        // we can init
        initLocationRefresher()
        initWeatherRefresher()
    }
    
    func didDeniedPermission(permission: SPRequestPermissionType) {
        print("permission is denied")
    }
    
    func didSelectedPermission(permission: SPRequestPermissionType) {}
    
    // MARK: - BluetoothStatus
    
    func handleBluetoothChange(notification : Notification) {
        let status = notification.object as! CBManagerState
        
        self.bluetoothAvailable = (status == .poweredOn)
    }
    
    // MARK: - InternetStatus
    
    func handleInternetChange(notification : Notification) {
        let status = notification.object as! Bool
        
        self.internetAvailable = status
    }
    
    // MARK: - MuseListener
    
    func museListChanged() {
        
        // get the muses found
        let listMuses = museManager!.getMuses()
        
        // current Muse
        guard let currentMuse = currentMuse?.first else {
            
            // disconnect
            disconnect()
            return
        }
        
        // name of the current Muse
        let lMuseName = currentMuse.getName()
        // check if Muse is in the list
        let museFound = listMuses.filter({ $0.getName() == lMuseName }).first
        
        // yep found
        if let museFound = museFound {
            
            // connect to it
            connect(to: museFound)
            
        // not found :(
        } else {
            
            // disconnect
            disconnect()
            
        }
        
    }
    
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        
        switch packet.currentConnectionState {
            case .disconnected:
                // case of, clean
                disconnect()
            case .connected:
                changeMuseButton(to: .connected)
                initHistoryRefresher()
            case .connecting:
                changeMuseButton(to: .connecting)
            default:
                break
        }
    }
    
    func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {
        
        // check validity
        guard let packet = packet else { return }
        
        // test to retrieve timestamp
        let date = NSDate.init(timeIntervalSince1970: TimeInterval(packet.timestamp()/1_000_000))
        print(packet.timestamp()/1_000_000)
        print(date.description)
        print(date.description(with: NSLocale.autoupdatingCurrent))
        
        packet.timestamp()
        
        if packet.packetType() == .eeg {
            
            //print(String(format: "%5.2f %5.2f %5.2f %5.2f", CDouble((packet.values()[IXNEeg.EEG1.rawValue])), CDouble((packet.values()[IXNEeg.EEG2.rawValue])), CDouble((packet.values()[IXNEeg.EEG3.rawValue])), CDouble((packet.values()[IXNEeg.EEG4.rawValue]))))
            
            let eegSnapshot = EEGSnapshot(data: packet)
            
            // can fail
            guard let eegSnap = eegSnapshot, self.currentValues[.eeg] != nil else { return }
            
            // add the snapshot to the history
            self.currentValues[.eeg]!.append(eegSnap)
            
        }
        
        // todo: use switch case to dispact
        // packetType in array, then retrieve
        // switch to put in good case of currentValues
        
    }
    
    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {
        // todo: check if in session to store
        if packet.blink {
            print("blink detected")
            
        }
        
        if packet.jawClench {
            print("jaw clench detected")
        }
    }
    
    // MARK: - WaveView
    
    func refreshWaveView() {
        
        // display only the EEG
        // recover only the property we want for each snapshot of the history
        waveView.points = museHistory[.eeg]!.map({
            return $0.value
        })
        
    }
    
    // MARK: - Session
    
    func runSessionTimer() {
        
        // reset
        self.currentTime = 0
        
        // set timer to fire event every second
        self.sessionTimer = Timer.scheduledTimer(timeInterval: 1,
                                                 target: self,
                                                 selector: (#selector(MainViewController.updateSessionTimer)),
                                                 userInfo: nil,
                                                 repeats: true
        )
    }
    
    func updateSessionTimer() {
        // increment
        self.currentTime += 1
        // update label
        self.topLabel.display(time: self.currentTime)
    }
    
    func stopSessionTimer() {
        
        // stop timer
        self.sessionTimer?.invalidate()
        
        // display name
        self.topLabel.display(name: currentUser?.first?.firstName ?? "")
    }
}
