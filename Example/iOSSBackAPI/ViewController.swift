//
//  ViewController.swift
//  iOSSBackAPI
//
//  Created by Matheus Ribeiro on 06/07/2017.
//  Copyright (c) 2017 Matheus Ribeiro. All rights reserved.
//  FIVE'S DEVELOPMENT LTDA

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var map:MKMapView!
    
    var overlays:[MKOverlay]! = []
    var points:[CLCircularRegion]! = []
    var firstUpdate:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        self.addPoint()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addPoint(){
        
        for overlay in overlays {
            map.remove(overlay)
        }
        
        for region in points {
            let circle:MKCircle = MKCircle(center: region.center, radius: region.radius)
            overlays.append(circle)
            map.add(circle)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = .red
        circle.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
        circle.lineWidth = 1
        return circle
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if(firstUpdate == false){
            firstUpdate = true
            var region:MKCoordinateRegion = MKCoordinateRegion()
            region.center = mapView.userLocation.coordinate
            region.span.latitudeDelta = 0.001
            region.span.longitudeDelta = 0.001
            mapView.setRegion(region, animated: true)
        }
    }
}

