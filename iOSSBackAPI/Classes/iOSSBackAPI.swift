//
//  iOSSBackAPI.swift
//  Pods
//
//  Created by Matheus on 08/06/17.
//  FIVE'S DEVELOPMENT LTDA
//

import Foundation
import Alamofire
import MapKit
import UserNotifications

public class iOSSBackAPI : NSObject, CLLocationManagerDelegate {
    
    public var delegate:iOSSBackAPIDelegate?
    public var pinCheck:Bool = false
    
    static let SERVER_AUTH:String = "https://api.shopback.net/auth/sdk"
    static let SERVER_LOCATIONS:String = "https://api.shopback.net/localpush"
    static var SERVER_LOAD_STORES:String = ""
    
    var API_key:String! = ""
    var email:String?
    var cellphone:String?
    var uid:String?
    
    var server_token:String?
    var client:String!
    var customer:String!
    var reload_timer:Int = 1800
    var rangeInKm:Double?
    var timer:Timer!
    
    var locationManager:CLLocationManager!
    
    var sentinels:[SentinelStore]! = []
    
    public init(key:String, email:String?, cellphone:String?, uid:String?, del:iOSSBackAPIDelegate?, rangeInKm:Double?){
        super.init()
        
        self.delegate = del
        self.API_key = key
        self.email = email
        self.cellphone = cellphone
        self.uid = uid
        self.rangeInKm = rangeInKm
        
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.distanceFilter = 2.5
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if(granted == true){
                if(self.pinCheck){
                    print("iOSSBack: Start")
                }
                self.auth()
            }
            else{
                print("iOSSBack: USER DIDN'T AUTHORIZE THE APP TO SEND NOTIFICATION.")
            }
        }
    }
    
    public func auth() -> Void{
        
        var parameters:Parameters!
        
        if(email != nil){
            parameters = [
                "secret_key": API_key,
                "email": email!
            ]
        }
        else if(cellphone != nil){
            parameters = [
                "secret_key": API_key,
                "cellphone": cellphone!
            ]
        }
        else if(uid != nil){
            parameters = [
                "secret_key": API_key,
                "uid": uid!
            ]
        }
        else{
            print("iOSSBack: Error to autenticated API. You need identify the user.")
            return
        }
        
        Alamofire.request(iOSSBackAPI.SERVER_AUTH, method: .post, parameters: parameters).responseJSON { (response) in
            
            guard response.result.isSuccess else {
                print("iOSSBack: Error while fetching tags: \(String(describing: response.result.error))")
                return
            }
            
            guard let json = response.result.value as? [String:Any] else {
                print("iOSSBack: Incompatible file loaded.")
                print("\(String(describing: response.result.value))")
                return
            }
            
            guard let data = json["data"] as? [String:Any] else {
                guard let error = json["error"] as? [String:Any] else {
                    print("iOSSBack: Unknow Error.")
                    return
                }
                print("iOSSBack: Error Code: \(String(describing: error["code"] as? Int)) - Type: \(String(describing: error["type"] as? String)) - Message: \(String(describing: error["message"] as? String))")
                return
            }
            if(self.pinCheck){
                print("iOSSBack: You're logged in SBack")
            }
            self.setConfigWithDataServer(json: data)
        }
    }
    
    public func setConfigWithDataServer(json:[String:Any]){
        server_token = json["access_token"] as? String
        customer = json["customer"] as? String
        client = json["client"] as? String
        reload_timer = json["stores_interval"] as! Int
        iOSSBackAPI.SERVER_LOAD_STORES = String(format: "%@/%@/customer/%@/store/proximity", iOSSBackAPI.SERVER_LOCATIONS, client, customer)
        loadCoordinates()
    }
    
    public func loadCoordinates() -> Void {
        
        if (CLLocationManager.authorizationStatus() == .authorizedAlways) {
            var parameters:Parameters!
            if(rangeInKm != nil){
                parameters = [
                    "latitude" : Double((locationManager.location?.coordinate.latitude)!),
                    "longitude" : Double((locationManager.location?.coordinate.longitude)!),
                    "rangeInKm" : rangeInKm!
                ]
            }
            else{
                parameters = [
                    "latitude" : Double((locationManager.location?.coordinate.latitude)!),
                    "longitude" : Double((locationManager.location?.coordinate.longitude)!)
                ]
            }
            
            let header:HTTPHeaders = [
                "Authorization" : server_token!
            ]
            
            Alamofire.request(iOSSBackAPI.SERVER_LOAD_STORES, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
                
                if(self.timer == nil){
                    self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.reload_timer), target: self, selector: #selector(self.loadCoordinates), userInfo: nil, repeats: true)
                }
                
                guard response.result.isSuccess else {
                    print("iOSSBack: Link: \(iOSSBackAPI.SERVER_LOAD_STORES) Parameters: \(parameters) Header: \(header)")
                    print("iOSSBack: Error while fetching tags: \(String(describing: response.result.error))")
                    
                    return
                }
                
                guard let json = response.result.value as? [String:Any] else {
                    print("iOSSBack: Link: \(iOSSBackAPI.SERVER_LOAD_STORES) Parameters: \(parameters) Header: \(header)")
                    print("iOSSBack: Incompatible file loaded.")
                    return
                }
                if(self.pinCheck){
                    print("iOSSBack: Stores Loaded")
                }
                self.createSentinels(json: json)
            }
        }
        else{
            print("iOSSBack: USER DIDN'T AUTHORIZE APP TO GET USER LOCATION.")
        }
    }
    
    public func createSentinels(json:[String:Any]) -> Void {
        sentinels = []
        let stores:[[String:Any]] = json["data"] as! [[String:Any]]
        var regions:[CLCircularRegion]! = []
        for store in stores {
            let link:String! = String(format: "%@/%@/customer/%@/store/inside", iOSSBackAPI.SERVER_LOCATIONS, client, customer)
            let sentinel:SentinelStore = SentinelStore(dataStore: store, accessToken: server_token!, loaderLink: link, del:delegate)
            sentinels.append(sentinel)
            regions.append(sentinel.circularRegion)
        }
        delegate?.pointsLoaded?(points: regions)
    }
    
    public func checkRegions(){
        if(pinCheck){
            print("iOSSBack: Check Regions")
        }
        for sentinel in sentinels {
            if (sentinel.circularRegion.contains(locationManager.location!.coordinate)){
                sentinel.activeTimer()
            }
            else{
                sentinel.disableTimer()
            }
        }
    }
    
    //MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.checkRegions()
    }
}

extension iOSSBackAPI: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if(response.notification.request.content.categoryIdentifier == "iOSSBack"){
            delegate?.userClickedInNotificationSBack?()
        }
        completionHandler()
    }
}
