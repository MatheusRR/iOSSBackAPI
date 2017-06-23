//
//  SentinelStore.swift
//  Pods
//
//  Created by Matheus on 08/06/17.
//  FIVE'S DEVELOPMENT LTDA
//

import Foundation
import MapKit
import UserNotifications
import Alamofire

public class SentinelStore : NSObject {
    
    public var delegate:iOSSBackAPIDelegate?
    
    var location:CLLocationCoordinate2D!
    var circularRegion:CLCircularRegion!
    
    var store_id:String! = ""
    var action_radius:Int! = 5
    var maxPermanence:Int = 120
    var link:String!
    var timer:Timer!
    var granted:Bool = false
    var name:String! = ""
    
    var token:String = ""
    
    var alert:UIAlertController?
    
    public init(dataStore:[String:Any], accessToken:String, loaderLink:String!, del:iOSSBackAPIDelegate?) {
        super.init()
        
        self.delegate = del
        
        let latitude:Double = (dataStore["location"] as! NSArray).object(at: 1) as! Double
        let longitude:Double = (dataStore["location"] as! NSArray).object(at: 0) as! Double
        location = CLLocationCoordinate2D(latitude:latitude, longitude: longitude)
        
        name = dataStore["name"] as! String
        store_id = dataStore["store_id"] as! String
        action_radius = dataStore["range_radius"] as! Int
        maxPermanence = dataStore["time_in_range"] as! Int
        token = accessToken
        link = loaderLink
        
        circularRegion = self.region()
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == UNAuthorizationStatus.authorized {
                self.granted = true
            }
        }
    }
    
    public func region() -> CLCircularRegion {
        let region = CLCircularRegion(center: location, radius: CLLocationDistance(action_radius), identifier: store_id)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    public func loadNotification(){
        timer.invalidate()
        timer = nil
        
        let parameters:Parameters = [
            "store_id" : store_id
        ]
        
        let header:HTTPHeaders = [
            "Authorization" : token
        ]
        
        Alamofire.request(link, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            
            guard response.result.isSuccess else {
                print("Error while fetching tags: \(String(describing: response.result.error))")
                return
            }
            
            guard let json = response.result.value as? [String:Any] else {
                print("Incompatible file loaded.")
                return
            }
            
            guard let data = json["data"] as? [String:Any] else {
                print("Incompatible file loaded.")
                return
            }
            self.sendNotification(json: data)
        }
    }
    
    public func sendNotification(json:[String:Any]?) {
        if UIApplication.shared.applicationState == .active {
            if ((delegate?.notificateWhenAPPIsActive?(store_id: json!["store_id"] as! String, title: json!["title"] as! String, message: json!["message"] as! String)) == nil) {
                alert = UIAlertController(title: json!["title"] as? String, message: json!["message"] as? String, preferredStyle: .alert)
                delegate?.window?.rootViewController?.present(alert!, animated: true, completion: {
//                    Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (alTimer) in
//                        alert.dismiss(animated: true, completion: nil)
//                    })
                    self.alert!.view.superview!.isUserInteractionEnabled = true
                    self.alert!.view.superview!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SentinelStore.alertClose)))
                })
            }
        }
        else if(granted == true){
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: json!["title"] as! String, arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: json!["message"] as! String, arguments: nil)
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "iOSSBack"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
            let request = UNNotificationRequest.init(identifier: self.store_id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    public func alertClose(){
        if(self.alert != nil){
            self.alert!.dismiss(animated: true, completion: nil)
        }
    }
    
    public func activeTimer(){
        if(timer == nil){
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(maxPermanence), target: self, selector: #selector(SentinelStore.loadNotification), userInfo: nil, repeats: false)
        }
    }
    
    public func disableTimer(){
        if(timer != nil){
            timer.invalidate()
            timer = nil
        }
    }
    
}
