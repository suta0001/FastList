//
//  LocationSelectViewController.swift
//  FastList
//
//  Created by Abdullah on 2/4/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import MapKit


protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class LocationSelectViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    var locationTitle = ""
    var locationLongitude = 0.0
    var locationLatitude = 0.0
    


    var resultSearchController : UISearchController? = nil
    
    var selectedPin:MKPlacemark? = nil
    var LocationInfoDelegate:LocationInfo!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchNav: UINavigationBar!
    @IBOutlet weak var doneButtonU: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDoneButton()
        //print("Check 1")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateDoneButton() {
        // Disable the Save button if the text field is empty.
        let text = locationTitle
        doneButtonU.isEnabled = !text.isEmpty
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        //print("\(locationTitle)")
        LocationInfoDelegate.sendValue(title: locationTitle,longitude: locationLongitude,latitude: locationLatitude)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
}


extension LocationSelectViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            //print("location:: \(location)")
        }
        
    }
    
}

extension LocationSelectViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        //print("\(annotation.coordinate.latitude) \(annotation.coordinate.longitude) \(annotation.title)")
        if annotation.title != nil {
            locationTitle = annotation.title!
            locationLongitude = annotation.coordinate.longitude
            locationLatitude = annotation.coordinate.latitude
        }
        //print("\(locationLatitude) \(locationLongitude) \(locationTitle)")
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        updateDoneButton()
    }
}
