//
//  ViewController.swift
//  Ofo-Demo
//
//  Created by 云菲 on 2017/7/29.
//  Copyright © 2017年 Freya. All rights reserved.
//

import UIKit
import SWRevealViewController
import FTIndicator

class OfoMapVC: UIViewController, MAMapViewDelegate, AMapSearchDelegate, AMapNaviWalkManagerDelegate {
// MARK: - properties
    var mapView: MAMapView!
    var search: AMapSearchAPI!
    var pin : OfoMyPinAnnotation!
    var pinView : MAPinAnnotationView!
    var nearBySearch = true
    var start,end : CLLocationCoordinate2D!
    var walkManager : AMapNaviWalkManager!
    
// MARK: - life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //显示地图
        mapView = MAMapView(frame: view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
        self.view.sendSubview(toBack: mapView)
        
        //地图缩放级别要在定位之前设置
        mapView.zoomLevel = 17
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow //是否需要持续定位
        
        //搜索
        search = AMapSearchAPI()
        search.delegate = self
        
        //导航
        walkManager = AMapNaviWalkManager()
        walkManager.delegate = self
        
        
        self.navigationItem.titleView = UIImageView(image:#imageLiteral(resourceName: "yellowBikeLogo"))
        self.navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "user_center_icon").withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "rightTopImage").withRenderingMode(.alwaysOriginal)
        
        if let revealVC = revealViewController() {
            revealVC.rearViewRevealWidth = 280
            navigationItem.leftBarButtonItem?.target = revealVC
            navigationItem.leftBarButtonItem?.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
            
        }
    }

// MARK: - events
    @IBAction func locationBtnTap(_ sender: UIButton) {
        searchBikeNearby()
    }
    
// MARK: - custom methods
    //搜索周边的小黄车
    func  searchBikeNearby() {
        nearBySearch = true
        searchCustomeLocation(mapView.userLocation.coordinate)
    }
    
    func searchCustomeLocation(_ center: CLLocationCoordinate2D) {
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(center.latitude), longitude: CGFloat(center.longitude))
        request.keywords = "餐馆"
        request.radius = 500
        request.requireExtension = true
        search.aMapPOIAroundSearch(request)
        
    }
    
    //大头针动画  - 坠落效果
    func pinAnimation() {
        let endFrame = pinView.frame
        pinView.frame = endFrame.offsetBy(dx: 0, dy: -15)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: [], animations: { 
            self.pinView.frame = endFrame
        }, completion: nil)
    }
    
// MARK: - Map Search Delegate
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        guard response.count > 0 else {//保证count 一定要大于0，否则 return
            print("周边没有小黄车")
            return;
        }

        
        var annotations : [MAPointAnnotation] = []
        annotations = response.pois.map{
            let annotation = MAPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees($0.location.latitude), longitude: CLLocationDegrees($0.location.longitude))
            
            if $0.distance < 200 {
                annotation.title = "红包区域内开锁任意小黄车"
                annotation.subtitle = "骑行10分钟可获得现金红包"
            }else {
                annotation.title = "正常可用"
            }
            
            return annotation
        }
        
        for anno in mapView.annotations(in: mapView.visibleMapRect) {
            if anno is OfoMyPinAnnotation || anno is MAUserLocation {
                continue
            }
            
            mapView.removeAnnotation(anno as! MAAnnotation)
        }
        
        mapView.addAnnotations(annotations)
        if nearBySearch {
            mapView.showAnnotations(annotations, animated: true)
            nearBySearch = !nearBySearch
        }
        
    }
    
// MARK: - Map View Delegate
    //地图初始化完成
    func mapInitComplete(_ mapView: MAMapView!) {
        pin = OfoMyPinAnnotation()
        pin.coordinate = mapView.centerCoordinate
        pin.lockedScreenPoint = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        pin.isLockedToScreen = true
        mapView.addAnnotation(pin)
        mapView.showAnnotations([pin], animated: true)
        
        searchBikeNearby()
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        //用户定义的位置，不需要自定义
        if annotation is MAUserLocation {
            return nil
        }
        
        if annotation is OfoMyPinAnnotation {
            let reuseid = "anchor"
            var av = mapView.dequeueReusableAnnotationView(withIdentifier: reuseid)
            if av == nil {
                av = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseid)
            }
            av?.image = #imageLiteral(resourceName: "homePage_wholeAnchor")
            av?.canShowCallout = false
            
            pinView = av as! MAPinAnnotationView
            return av
        }
        
        let reuseID = "myid"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MAPinAnnotationView
        
        if annotationView == nil {
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        }
        
        if annotation.title == "正常可用" {
             annotationView?.image = #imageLiteral(resourceName: "HomePage_nearbyBike")
        } else {
            annotationView?.image = #imageLiteral(resourceName: "HomePage_nearbyBikeRedPacket")
        }
        
        annotationView?.canShowCallout = true
        annotationView?.animatesDrop = false
        return annotationView
    }
    
    
    /// 用户移动地图的交互
    ///
    /// - Parameters:
    ///   - mapView:  mapView
    ///   - wasUserAction: 是否用户操作
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            pin.isLockedToScreen = true
            pinAnimation()
            searchCustomeLocation(mapView.centerCoordinate)
        }
    }
    
    
    /// 添加标注视图后
    ///
    /// - Parameters:
    ///   - mapView:  mapView
    ///   - views:  annotationView 数组
    func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
        let aViews = views as! [MAAnnotationView]
        for aView in aViews {
            guard aView.annotation is MAPointAnnotation else {
                continue
            }
            
            aView.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: { 
                aView.transform = .identity
            }, completion: nil)
        }
    }
    
    
    /// 点击标注
    ///
    /// - Parameters:
    ///   - mapView: mapView
    ///   - view:  标注视图
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        start = pin.coordinate
        end = view.annotation.coordinate
        let startPoint = AMapNaviPoint.location(withLatitude: CGFloat(start.latitude), longitude: CGFloat(start.longitude))!
        let endPoint = AMapNaviPoint.location(withLatitude: CGFloat(end.latitude), longitude: CGFloat(end.longitude))!
        walkManager.calculateWalkRoute(withStart: [startPoint], end: [endPoint])
    }
    
    
    /// 渲染添加层
    ///
    /// - Parameters:
    ///   - mapView:  mapView
    ///   - overlay: overlay
    /// - Returns:
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay is MAPolyline {
            pin.isLockedToScreen = false
            
            //缩放地图
            mapView.visibleMapRect = overlay.boundingMapRect
            
            let renderer = MAPolylineRenderer(overlay: overlay)
            renderer?.lineWidth = 6.0
            renderer?.strokeColor = UIColor.blue
            
            return renderer
        }
        
        return nil
    }
    
    
// MARK: - AMapNaviWalkManagerDelegate
    
    /// 步行路线规划成功
    ///
    /// - Parameter walkManager:
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        //移除之前的路线
        mapView.removeOverlays(mapView.overlays)
        
        //绘制新路线
        var coordinates = walkManager.naviRoute!.routeCoordinates!.map{
            return CLLocationCoordinate2D(latitude: CLLocationDegrees($0.latitude), longitude: CLLocationDegrees($0.longitude))
        }
        
        let polyLine = MAPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        mapView.add(polyLine)
        
        let walkMinute = walkManager.naviRoute!.routeTime / 60
        var timeDesc = "1分钟以内"
        if walkMinute > 0 {
            timeDesc = walkMinute.description + "分钟"
        }
        let hintTitle = "步行" + timeDesc
        let hintSubTitle = "距离" + walkManager.naviRoute!.routeLength.description + "米"
    
        //提示路线距离和步行时间
        FTIndicator.setIndicatorStyle(.dark)
        FTIndicator.showNotification(with: #imageLiteral(resourceName: "clock"), title: hintTitle, message: hintSubTitle)
    }
    
    func walkManager(_ walkManager: AMapNaviWalkManager, onCalculateRouteFailure error: Error) {
        print("路线规划失败: ", error)
    }

    
// MARK: - memory monitor
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

