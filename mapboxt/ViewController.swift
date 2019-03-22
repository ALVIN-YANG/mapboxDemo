//
//  ViewController.swift
//  mapboxt
//
//  Created by luqing yang on 2019/3/8.
//  Copyright © 2019 luqing yang. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation
import Tiercel
import SQLite

let imageSource: MGLImageSource = {
    let coordinates = MGLCoordinateQuad(
        topLeft: CLLocation(latitude: 39.923653, longitude: 116.389709).locationEarthFromMars().coordinate,
        bottomLeft: CLLocation(latitude: 39.912067, longitude: 116.389709).locationEarthFromMars().coordinate,
        bottomRight: CLLocation(latitude: 39.912067, longitude: 116.404686).locationEarthFromMars().coordinate,
        topRight: CLLocation(latitude: 39.923653, longitude: 116.404686).locationEarthFromMars().coordinate)
    return MGLImageSource(identifier: "radar", coordinateQuad: coordinates, url: URL(string: "https://music.gowithtommy.com/mjtt_backend_server%2Fprod%2Fdata%2F2bb7904c15b8a9a7e5f86f662a3a1f51848f5898.png")!)
}()

let db_path = "https://music.gowithtommy.com/mjtt_backend_server%2Ftest%2Fdata%2F0470dff961b9d43b03d4f35ce91282946966b308.db"

class CustomAnnotationView: MGLAnnotationView {
    
    var imageView: UIImageView = UIImageView(image: nil)
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard let title = self.annotation?.title else { return }
        if selected {
            imageView.image = title?.toMapPinImage(isSelected: true, isBlue: false)
        } else {
            imageView.image = title?.toMapPinImage(isSelected: false, isBlue: false)
        }
    }
}

class ViewController: UIViewController, MGLMapViewDelegate {
   
    var mapView: NavigationMapView!
    var progressView: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TRManager.default.configuration.allowsCellularAccess = true
        configMap()
        print(NSHomeDirectory())
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        add_button()
        style.addSource(imageSource)
        add_annotation()
        add_line()
    }
    
    func add_line() {
        guard let sources = mapView.style?.sources else {
            return
        }
        var coordinates = [
            CLLocation(latitude: 39.921159, longitude: 116.395128).locationEarthFromMars().coordinate,
            CLLocation(latitude: 39.920219, longitude: 116.39582).locationEarthFromMars().coordinate,
            CLLocation(latitude: 39.917273, longitude: 116.397102).locationEarthFromMars().coordinate,
            CLLocation(latitude: 39.916262, longitude: 116.398404).locationEarthFromMars().coordinate
        ]
        let polyline = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        let source = MGLShapeSource(identifier: "line", shape: polyline, options: nil)
        
        var has_source = false
        for item in sources {
            if item.identifier == "line" {
                has_source = true
            }
        }
        if !has_source {
            mapView.style?.addSource(source)
        }
        
        let layer = MGLLineStyleLayer(identifier: "line", source: source)
        layer.lineWidth = NSExpression(forConstantValue: 5)
        mapView.style?.setImage(UIImage(named: "custtexture")!, forName: "custtexture")
        layer.linePattern = NSExpression(forConstantValue: "custtexture")
        
        guard let layers = mapView.style?.layers else {
            mapView.style?.addLayer(layer)
            return
        }
        
        var has_layer = false
        for item in layers {
            if item.identifier == "line" {
                has_layer = true
            }
        }
        if !has_layer {
            mapView.style?.addLayer(layer)
        }
    }
    
    func add_annotation() {
        let pointA = MGLPointAnnotation()
        pointA.coordinate = CLLocation(latitude: 39.921159, longitude: 116.395128).locationEarthFromMars().coordinate
        pointA.title = "咸福宫"
        
        let pointB = MGLPointAnnotation()
        pointB.coordinate = CLLocation(latitude: 39.920219, longitude: 116.39582).locationEarthFromMars().coordinate
        pointB.title = "永寿宫"
        
        let pointC = MGLPointAnnotation()
        pointC.title = "太和殿"
        pointC.coordinate = CLLocation(latitude: 39.917273, longitude: 116.397102).locationEarthFromMars().coordinate
        
        let pointD = MGLPointAnnotation()
        pointD.title = "体仁阁"
        pointD.coordinate = CLLocation(latitude: 39.916262, longitude: 116.398404).locationEarthFromMars().coordinate
        
        // Fill an array with four point annotations.
        let myPlaces = [pointA, pointB, pointC, pointD]
        
        // Add all annotations to the map all at once, instead of individually.
        mapView.addAnnotations(myPlaces)
    }
    
    deinit {
        // Remove offline pack observers.
        NotificationCenter.default.removeObserver(self)
    }
    
    func configMap() {
        let url = URL(string: "mapbox://styles/qj-alvin/cjt6onka50hkv1fphcy6bp6jr")
        
        mapView = NavigationMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.tintColor = .red
        mapView.delegate = self
        
        mapView.logoView.isHidden = true
        mapView.attributionButton.isEnabled = false
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserHeadingIndicator = true
        mapView.setCenter(CLLocation(latitude: 39.918058, longitude: 116.397026).locationEarthFromMars().coordinate,
                          zoomLevel: 14, animated: false)
        view.addSubview(mapView)
        
        // Setup offline pack notification handlers.
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgressDidChange), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
    }
    
    let tie_tu = UIButton(frame: CGRect(x: 250, y: 100, width: 100, height: 50))
    
    func add_button() {
//        let button = UIButton(frame: CGRect(x: 60, y: 100, width: 150, height: 50))
//        button.setTitle("下载已打包数据包", for: .normal)
//        button.titleLabel?.tintColor = UIColor.black
//        button.backgroundColor = UIColor.lightGray
//        button.addTarget(self, action: #selector(downloadPark), for: .touchUpInside)
//        view.addSubview(button)
        
        let data_btn = UIButton(frame: CGRect(x: 60, y: 200, width: 150, height: 50))
        data_btn.setTitle("下载巴黎地图", for: .normal)
        data_btn.titleLabel?.tintColor = UIColor.black
        data_btn.backgroundColor = UIColor.lightGray
        data_btn.addTarget(self, action: #selector(startOfflinePackDownload), for: .touchUpInside)
        view.addSubview(data_btn)
        
        tie_tu.setTitle("添加贴图", for: .normal)
        tie_tu.titleLabel?.tintColor = UIColor.black
        tie_tu.backgroundColor = UIColor.lightGray
        tie_tu.addTarget(self, action: #selector(tie_tuAction), for: .touchUpInside)
        view.addSubview(tie_tu)
        
        let location_btn = UIButton(frame: CGRect(x: 250, y: 200, width: 120, height: 50))
        location_btn.setTitle("用户定位", for: .normal)
        location_btn.titleLabel?.tintColor = UIColor.black
        location_btn.backgroundColor = UIColor.lightGray
        location_btn.addTarget(self, action: #selector(locationUser), for: .touchUpInside)
        view.addSubview(location_btn)
        
        let direction_btn = UIButton(frame: CGRect(x: 60, y: 100, width: 150, height: 50))
        direction_btn.setTitle("去故宫", for: .normal)
        direction_btn.titleLabel?.tintColor = UIColor.black
        direction_btn.backgroundColor = UIColor.lightGray
        direction_btn.addTarget(self, action: #selector(direction_btnAction), for: .touchUpInside)
        view.addSubview(direction_btn)
        
        let clear_btn = UIButton(frame: CGRect(x: 60, y: 300, width: 120, height: 50))
        clear_btn.setTitle("清空巴黎数据", for: .normal)
        clear_btn.titleLabel?.tintColor = UIColor.black
        clear_btn.backgroundColor = UIColor.lightGray
        clear_btn.addTarget(self, action: #selector(delete_map_data), for: .touchUpInside)
        view.addSubview(clear_btn)
    }
    
    @objc func delete_map_data() {
        mapView.pleaseWait()
        DispatchQueue.global().async {
            let home = NSHomeDirectory()
            let db = try! Connection(home + "/Library/Application Support/com.Tommy.mjtt/.mapbox/cache.db")
            let regions = Table("regions")
            
            let id = Expression<Int64>("id")
            let region_id = Expression<Int64>("region_id")
            let tile_id = Expression<Int64>("tile_id")
            let resource_id = Expression<Int64>("resource_id")
            let region_tiles = Table("region_tiles")
            let region_resources = Table("region_resources")
            let resources = Table("resources")
            let tiles = Table("tiles")
            
            var region_id_list = [Int64]()
            for region in try! db.prepare(regions) {
                let region_id = try! region.get(id)
                region_id_list.append(region_id)
            }
            
            for item_id in region_id_list {
                for alias in try! db.prepare(region_resources.filter(region_id == item_id)) {
                    let resource_item_id = try! alias.get(resource_id)
                    try! db.run(resources.filter(id == resource_item_id).delete())
                    try! db.run(region_resources.filter(resource_id == resource_item_id).delete())
                }
                
                for alias in try! db.prepare(region_tiles.filter(region_id == item_id)) {
                    let tile_item_id = try! alias.get(tile_id)
                    try! db.run(tiles.filter(id == tile_item_id).delete())
                    try! db.run(region_tiles.filter(tile_id == tile_item_id).delete())
                }
            }
            try! db.run("vacuum")
            DispatchQueue.main.async {
                self.mapView.clearAllNotice()
                self.mapView.noticeOnlyText("清除成功")
            }
        }
        
    }
    
    @objc func direction_btnAction() {
        guard let user_location = mapView.userLocation?.location else { return }
        let origin = Waypoint(location: user_location, heading: mapView.userLocation?.heading, name: "当前位置")
        let destination = Waypoint(coordinate: CLLocation(latitude: 39.918058, longitude: 116.397026).locationEarthFromMars().coordinate)
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: MBDirectionsProfileIdentifier.automobile)
        mapView.pleaseWait()
        Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first else { return }
            self.mapView.showRoutes([route])
            self.mapView.showWaypoints(route)
           self.mapView.setOverheadCameraView(from: origin.coordinate, along: [origin.coordinate, destination.coordinate], for: UIEdgeInsets(top: 60, left: 30, bottom: 100, right: 30))
            self.mapView.clearAllNotice()
        }
    }
    
    @objc func locationUser() {
        guard let location = mapView.userLocation?.coordinate else { return }
        mapView.setCenter(location, animated: true)
    }
    
    @objc func tie_tuAction() {
        
        if tie_tu.titleLabel?.text == "添加贴图" {
            add_image()
            add_line()
            tie_tu.setTitle("移除贴图", for: .normal)
        } else {
            remove_image()
            tie_tu.setTitle("添加贴图", for: .normal)
        }
    }
    
    func add_image() {
        guard let style = mapView.style else {
            return
        }
        // Insert the raster layer below the map's symbol layers.
        let radarLayer = MGLRasterStyleLayer(identifier: "image-layer", source: imageSource)
        //        style.addLayer(radarLayer)
        for layer in style.layers.reversed() {
            if !layer.isKind(of: MGLSymbolStyleLayer.self) {
                style.insertLayer(radarLayer, below: layer)
//                style.insertLayer(radarLayer, above: layer)
                break
            }
        }
    }
    
    func remove_image() {
        guard let style = mapView.style else {
            return
        }
        for layer in style.layers.reversed() {
            if layer.identifier == "image-layer" {
                style.removeLayer(layer)
            }
        }
    }
    
    @objc func downloadPark() {
        let task = TRManager.default.download(db_path)
        let path = task!.filePath
        print(task?.filePath ?? "")
        task?.progress({ (task) in
            let progress = task.progress.fractionCompleted
            print("下载中, 进度：\(progress)")
            
            self.mapView.noticeOnlyText("进度：\(Int(progress*100))%")
        }).success({ (task) in
            
            self.mapView.noticeOnlyText("下载完成")
            MGLOfflineStorage.shared.addContents(ofFile: path, withCompletionHandler: { (url, packs, error) in
                
            })
        }).failure({ (task) in
            print("下载失败")
        })
    }
    
    @objc func deletePark() {
        
        guard let url = TRCache.default.fileURL(URLString: db_path) else { return }
        do {
            try FileManager.default.removeItem(at: url)
            TRManager.default.remove(db_path)
            self.mapView.noticeOnlyText("删除成功")
        } catch {
            print("删除失败")
        }
    }
    
    
    @objc func startOfflinePackDownload() {
        // Create a region that includes the current viewport and any tiles needed to view it when zoomed further in.
        // Because tile count grows exponentially with the maximum zoom level, you should be conservative with your `toZoomLevel` setting.
        let sw = CLLocationCoordinate2D(latitude: 48.8, longitude: 2.3)
        let ne = CLLocationCoordinate2D(latitude: 48.9, longitude: 2.4)
        let bounds = MGLCoordinateBounds(sw: sw, ne: ne)
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: bounds, fromZoomLevel: 5, toZoomLevel: 22)
        
        // Store some data for identification purposes alongside the downloaded resources.
        let id = try! NSKeyedArchiver.archivedData(withRootObject: "巴黎", requiringSecureCoding: false)
        
        // Create and register an offline pack with the shared offline storage object.
        
        MGLOfflineStorage.shared.addPack(for: region, withContext: id) { (pack, error) in
            guard error == nil else {
                // The pack couldn’t be created for some reason.
                print("Error: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            // Start downloading.
            pack!.resume()
        }
        
    }
    
    // MARK: - MGLOfflinePack notification handlers
    var pro = 0
    @objc func offlinePackProgressDidChange(notification: NSNotification) {
        // Get the offline pack this notification is regarding,
        // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(pack.context) as? String {
            let progress = pack.progress
            
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage.
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            print("现在：" + String(progressPercentage))
            
            let per = Int(progressPercentage*100)
            if pro < per {
                pro = per
                DispatchQueue.main.async {
                    self.mapView.noticeOnlyText("\(userInfo ?? "")进度：\(per)%")
                }
            }
            // If this pack has finished, print its size and resource count.
            if progressPercentage == 1.0 {
                DispatchQueue.main.async {
                    self.mapView.noticeOnlyText("\(String(describing: userInfo))下载完成")
                }
            }
            if completedResources == expectedResources {
                
            } else {
                
            }
        }
    }
}

// annotation
extension ViewController {
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            return CustomUserLocationAnnotationView()
        }
        
        guard let title = annotation.title else { return nil }
        let image = title?.toMapPinImage(isSelected: false, isBlue: false)
        let imageView = UIImageView(image: image)
        let annotationView = CustomAnnotationView(reuseIdentifier: nil)
        annotationView.imageView = imageView
        annotationView.addSubview(imageView)
        annotationView.bounds = imageView.bounds
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        // 景点
        guard let title = annotationView.annotation?.title else { return }
        DispatchQueue.main.async {
            mapView.noticeOnlyText("模拟播放\(title!)")
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
}

//// line
//extension ViewController {
//    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
//        return .red
//    }
//
//}
