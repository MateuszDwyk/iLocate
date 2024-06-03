//
//  Coordinates.swift
//  iLocateApp
//
//  Created by Mateusz Dworaczyk on 29/11/2023.
//

import Foundation

func getDeviceCoords(d1: Float, d2: Float, d3: Float, sideY: Float, sideX: Float, beaconPositions: [BeaconPosition]) -> ReceiverPosition{
    //Variable z because beacons have a different axis system
    //Scaling is not necessary because the beacons are set at the appropriate distance from the walls and have x, y, z coordinates
    let xa = beaconPositions[0].x
    let ya = beaconPositions[0].z
    let xb = beaconPositions[1].x
    let yb = beaconPositions[1].z
    let xc = beaconPositions[2].x
    let yc = beaconPositions[2].z

    // Calculate coefficients for the quadratic equations
    let A1 = 2 * (xb - xa)
    let B1 = 2 * (yb - ya)
    let C1 = d1 * d1 - d2 * d2 - xa * xa + xb * xb - ya * ya + yb * yb

    let A2 = 2 * (xc - xb)
    let B2 = 2 * (yc - yb)
    let C2 = d2 * d2 - d3 * d3 - xb * xb + xc * xc - yb * yb + yc * yc
    
    // Check whether the calculated coordinates are within the room boundaries
    let roomXMin: Float = 0
    let roomXMax: Float = sideX
    let roomYMin: Float = 0
    let roomYMax: Float = sideY
    let measurementAccuracy: Float = 0.01
    // Measurement scales
    let weight1 = 1 / pow(measurementAccuracy, 2)
    let weight2 = 1 / pow(measurementAccuracy, 2)
    
    // Solving the system of equations taking into account the weights
    let denominator = weight1 * A1 * B2 - weight2 * A2 * B1
    guard denominator != 0 else {
          // The emitters are collinear, which makes it impossible to find a clear solution
          return ReceiverPosition(_x: 0, _y: 0)
      }

    let receiverX = (weight1 * C1 * B2 - weight2 * C2 * B1) / denominator
    let receiverY = (weight1 * A1 * C2 - weight2 * A2 * C1) / denominator
    
    if receiverX < roomXMin || receiverX > roomXMax || receiverY < roomYMin || receiverY > roomYMax {
        // The coordinates are outside the boundaries of the room
        return ReceiverPosition(_x: 0, _y: 0)
    }

    return ReceiverPosition(_x: receiverX, _y: receiverY)
}

func getDeviceCoordswithParameters(d1: Float, d2: Float, d3: Float, sideY: Float, sideX: Float, beaconPositions: [BeaconPosition]) -> ReceiverPosition{
    //Variable z because beacons have a different axis system
    //Scaling is not necessary because the beacons are set at the appropriate distance from the walls and have x, y, z coordinates
    let xa = beaconPositions[0].x
    let ya = beaconPositions[0].z
    let xb = beaconPositions[2].x
    let yb = beaconPositions[2].z
    let xc = beaconPositions[1].x
    let yc = beaconPositions[1].z

    // Calculate coefficients for the quadratic equations
    let A1 = 2 * (xb - xa)
    let B1 = 2 * (yb - ya)
    let C1 = d1 * d1 - d2 * d2 - xa * xa + xb * xb - ya * ya + yb * yb

    let A2 = 2 * (xc - xb)
    let B2 = 2 * (yc - yb)
    let C2 = d2 * d2 - d3 * d3 - xb * xb + xc * xc - yb * yb + yc * yc
    
    // Check whether the calculated coordinates are within the room boundaries
    let roomXMin: Float = 0
    let roomXMax: Float = sideX
    let roomYMin: Float = 0
    let roomYMax: Float = sideY
    let measurementAccuracy: Float = 0.01
    // Measurement scales
    let weight1 = 1 / pow(measurementAccuracy, 2)
    let weight2 = 1 / pow(measurementAccuracy, 2)
    
    // Solving the system of equations taking into account the weights
    let denominator = weight1 * A1 * B2 - weight2 * A2 * B1
    guard denominator != 0 else {
        // The emitters are collinear, which makes it impossible to find a clear solution
          return ReceiverPosition(_x: 0, _y: 0)
      }

    let receiverX = (weight1 * C1 * B2 - weight2 * C2 * B1) / denominator
    let receiverY = (weight1 * A1 * C2 - weight2 * A2 * C1) / denominator
    
    if receiverX < roomXMin || receiverX > roomXMax || receiverY < roomYMin || receiverY > roomYMax {
        // The coordinates are outside the boundaries of the room
        return ReceiverPosition(_x: 0, _y: 0)
    }

    return ReceiverPosition(_x: receiverX, _y: receiverY)
}

func degreesToRadians(degrees: Float) -> Float {
    return degrees * .pi / 180.0
}

func radiansToDegrees(radians: Float) -> Float {
    return radians * 180.0 / .pi
}

func getBearingBetweenTwoPoints(point1 : ReceiverPosition, point2 : BeaconPosition) -> Float {
    let lat1 = degreesToRadians(degrees: point1.x)
    let lon1 = degreesToRadians(degrees: point1.y)
    
    let lat2 = degreesToRadians(degrees: point2.x)
    let lon2 = degreesToRadians(degrees: point2.z)
    
    let dLon = lon2 - lon1
    
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radiansBearing = atan2(y, x)
    var bearing = radiansToDegrees(radians: radiansBearing)
    if bearing < 0 {
        bearing += 360
    }
    return bearing
}

//Function for the future
//func getBeaconCoordinates(d1: Float, d2: Float, d3: Float, sideY: Float, sideX: Float) -> [BeaconPosition] {
//   let x = (d1 * d2 * sideX) / (d1 * sideX + d2 * sideX + d3 * sideX)
//   let y = (d1 * d2 * sideY) / (d1 * sideY + d2 * sideY + d3 * sideY)
//
//    let beacon1 = BeaconPosition(_x: x - d1, _y: y, _z: 0)
//   let beacon2 = BeaconPosition(_x: x + d2, _y: y, _z: 0)
//   let beacon3 = BeaconPosition(_x: x, _y: y - d3, _z: 0)
//
//   return [beacon1, beacon2, beacon3]
//}
