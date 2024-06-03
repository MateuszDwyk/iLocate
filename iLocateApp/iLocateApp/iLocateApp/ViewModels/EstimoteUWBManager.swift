//
//  EstimoteUWBManager.swift
//  iLocateApp
//
//  Created by Mateusz Dworaczyk on 29/11/2023.
//

import Foundation
import EstimoteUWB
import SwiftUI

class EstimoteUWBManagerExample: NSObject, ObservableObject{
    @Published var positionX : Float = 0
    @Published var positionY : Float = 0
    @Published var rangingResults: [Float] = [0, 0, 0]
    @Published var rangingResultsForView: [Float] = [0, 0, 0]
    private var uwbManager: EstimoteUWBManager?
    private var distanceToSelectedBeacon: Float!
    var realPositionX: Float!
    var realPositionY: Float!
    var deviceList: [UWBIdentifiable] = []
    var isConnected: Bool = false
    var beaconIDs: [String] = [
        "7cf2c758dbf1b386989f4da92846e11f", //Caramel
        "b219eb401b56b93020efe8da76437f1e", //Coconut
        "071b3929211b974be7b75e7b2dce522d", //Lemon
    ]
// Just for checking on const values
//    var roomSideX: Float! = 2.73
//    var roomSideY: Float! = 4.66
//    var beaconPositions: [BeaconPosition] = [
//        BeaconPosition(_x: 0.3, _y: 0.98, _z: 0.3),
//        BeaconPosition(_x: 2.73, _y: 0.9, _z: 1.9),
//        BeaconPosition(_x: 0.6, _y: 0.66, _z: 4.66),
//    ]

    private func setupUWB(){
        uwbManager = EstimoteUWBManager(delegate: self, options: EstimoteUWBOptions(shouldHandleConnectivity: true,
                                        isCameraAssisted: false)
        )
        print("start UWB ranging")
        uwbManager?.startScanning()
    }
    public func startScanning() {
        self.setupUWB()
    }
    public func stopScanning(){
        uwbManager?.stopScanning()
    }
}

extension EstimoteUWBManagerExample: EstimoteUWBManagerDelegate{
    
    func didUpdatePosition(for device: EstimoteUWBDevice) {
        print("position updated for device: \(device.publicIdentifier), distance: \(device.distance)")
        saveResult(deviceId: device.publicIdentifier, range: device.distance)
    }
    
    func didDiscover(device: UWBIdentifiable, with rssi: NSNumber, from manager: EstimoteUWBManager) {
        if let uwbDevice = device as? EstimoteUWBDevice {
            DispatchQueue.main.async {
                print("device: \(uwbDevice.publicIdentifier), distance: \(uwbDevice.distance)")
            }
        }
    }
    
    func didRange(for beacon: EstimoteBLEDevice) {
        print("Ble: beacon did range: \(beacon)")
    }
    
    func saveResult(deviceId: String, range: Float) {
        let index = beaconIDs.firstIndex(of: deviceId)
        if(index != nil){
            rangingResults[index!] = range
            if(isRangingComplete()){
//                calculateDevicePosition()
//                calculateAngle()
                rangingResultsForView = printRangingResults()
                clearRangingResults()
            }
        }
    }
    
    func getDistanceToBeacon(selectedBeacon: Int) -> Float{
        return distanceToSelectedBeacon
    }
    
    func calculateAngleWithParameters(data: DataStore, selectedBeacon: Int) -> Float{
        let beaconPositionsForFunction: [BeaconPosition] = [
            BeaconPosition(_x: Float(data.beacons[0].position["x"] ?? 0), _y: Float(data.beacons[0].position["y"] ?? 0), _z: Float(data.beacons[0].position["z"] ?? 0)),
            BeaconPosition(_x: Float(data.beacons[1].position["x"] ?? 0), _y: Float(data.beacons[1].position["y"] ?? 0), _z: Float(data.beacons[1].position["z"] ?? 0)),
            BeaconPosition(_x: Float(data.beacons[2].position["x"] ?? 0), _y: Float(data.beacons[2].position["y"] ?? 0), _z: Float(data.beacons[2].position["z"] ?? 0)),

        ]
        var choosingVariableForChangedBeaconsInPicker: Int!
//        print("\(beaconPositionsForFunction[selectedBeacon].x)")
//        print("\(beaconPositionsForFunction[selectedBeacon].y)")
//        print("\(beaconPositionsForFunction[selectedBeacon].z)")
        let devicePosition = getDeviceCoordswithParameters(d1: rangingResultsForView[0], d2: rangingResultsForView[1], d3: rangingResultsForView[2], sideY: Float(data.rooms[data.selectedRoom].y), sideX: Float(data.rooms[data.selectedRoom].x), beaconPositions: beaconPositionsForFunction)
//        print(" \(rangingResultsForView)")
//        print(" \(devicePosition.x)")
//        print(" \(devicePosition.y)")
        let angle1 = getBearingBetweenTwoPoints(point1: devicePosition, point2: beaconPositionsForFunction[selectedBeacon])
//        print("Angle to the selected beacon: \(angle1)")
        //Changed places in picker
        if(selectedBeacon==1){
            choosingVariableForChangedBeaconsInPicker=2}
        else if(selectedBeacon==2){
            choosingVariableForChangedBeaconsInPicker=1
        }
        else{
            choosingVariableForChangedBeaconsInPicker=0
        }
        distanceToSelectedBeacon = rangingResultsForView[choosingVariableForChangedBeaconsInPicker]
        clearRangingResultsForView()
        return angle1
    }
    
    func isRangingComplete() -> Bool{
        let nextIndex = rangingResults.firstIndex(of: 0)
        return (nextIndex == nil || nextIndex! > 3)
    }
    
    func clearRangingResults(){
        rangingResults = [0, 0, 0]
    }
    
    func clearRangingResultsForView(){
        rangingResultsForView = [0, 0, 0]
    }
    
    func printRangingResults() -> [Float]{
        for i in 0...2{
            print("\(i) : \(rangingResults[i])")
        }
        return rangingResults
    }
    
    //Just for checking on const values
    //    func calculateDevicePosition(){
    //        let devicePosition = getDeviceCoords(d1: rangingResults[0], d2: rangingResults[1], d3: rangingResults[2], sideY: self.roomSideY, sideX: self.roomSideX, beaconPositions: beaconPositions)
    //        self.positionX = devicePosition.x
    //        self.positionY = devicePosition.y
    //        print("device position x: \(positionX), y: \(positionY)")
    //    }
    //    func calculateBeaconPosition(){
    //        let beaconPosition = getBeaconCoordinates(d1: rangingResults[0], d2: rangingResults[1], d3: rangingResults[2], sideY: self.roomSideY, sideX: self.roomSideX)
    //        print("beacon1 position x: \(beaconPosition[0].x), y: \(beaconPosition[0].y)")
    //        print("beacon2 position x: \(beaconPosition[1].x), y: \(beaconPosition[1].y)")
    //        print("beacon3 position x: \(beaconPosition[2].x), y: \(beaconPosition[2].y)")
    //    }
    //    func calculateAngle(){
    //        let devicePosition = getDeviceCoords(d1: rangingResults[0], d2: rangingResults[1], d3: rangingResults[2], sideY: self.roomSideY, sideX: self.roomSideX, beaconPositions: beaconPositions)
    //        print(" \(rangingResults)")
    //        print("\(devicePosition.x)")
    //        print("\(devicePosition.y)")
    //        let angle1 = getBearingBetweenTwoPoints(point1: devicePosition, point2: beaconPositions[0])
    //        let angle2 = getBearingBetweenTwoPoints(point1: devicePosition, point2: beaconPositions[1])
    //        let angle3 = getBearingBetweenTwoPoints(point1: devicePosition, point2: beaconPositions[2])
    //        print("Angle to the caramel beacon: \(angle1)")
    //        print("Angle to the coconut beacon: \(angle2)")
    //        print("Angle to the lemon beacon: \(angle3)")
    //    }
}
