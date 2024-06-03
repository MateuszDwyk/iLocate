//
//  ContentViewViewModel.swift
//  iLocateApp
//
//  Created by Mateusz Dworaczyk on 29/11/2023.
//

import Foundation
import FirebaseFirestore

class DataStore: ObservableObject {
    @Published var selectedBuilding = 0
    @Published var selectedFloor = 0
    @Published var selectedRoom = 0
    @Published var beacons = [Beacon]()
    @Published var rooms = [Room]()
    @Published var floors = [Floor]()
    @Published var buildings = [Building]()
    @Published var rangingResults: [Float] = [0, 0, 0]
    
    func setRangingResults(results: [Float]) {
        DispatchQueue.main.async {
            self.rangingResults = results
        }
    }
    
    func retrieveBuildings(completion: @escaping ([Building]) -> Void) {
      let db = Firestore.firestore()
      let buildingsRef = db.collection("Buildings")
      var buildings = [Building]()

      buildingsRef.getDocuments { (querySnapshot, error) in
          if let error = error {
              print("Error getting documents: \(error)")
              completion([])
          } else {
              for document in querySnapshot!.documents {
                  let buildingId = document.documentID
                  let buildingName = document.data()["name"] as? String ?? ""
                  let building = Building(id: buildingId, name: buildingName)
                  buildings.append(building)
              }
              completion(buildings)
          }
      }
    }
    
    func printBuildings(){
        retrieveBuildings { buildings in
            let firstBuilding = buildings[0]
            print("ID: \(firstBuilding.id), Name: \(firstBuilding.name)")
        }
    }

    func retrieveFloors(for building: Building, completion: @escaping ([Floor]) -> Void) {
     let db = Firestore.firestore()
     let buildingRef = db.collection("Buildings").document(building.id)
     let floorsRef = db.collection("Floors").whereField("building", isEqualTo: buildingRef)
     var floors = [Floor]()

     floorsRef.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("Error getting documents: \(error)")
            completion([])
        } else {
            for document in querySnapshot!.documents {
                let floorId = document.documentID
                let floorName = document.data()["name"] as? String ?? ""
                let floor = Floor(id: floorId, name: floorName, buildingId: building.id)
                floors.append(floor)
            }
            completion(floors)
        }
     }
    }

    func printFloors(){
       let selectedBuilding = Building(id: "4ukir9DTHOuKddb9Q95j", name: "Home")
       retrieveFloors(for: selectedBuilding) { floors in
           if !floors.isEmpty {
               let firstFloor = floors[0]
               print("ID: \(firstFloor.id), Name: \(firstFloor.name)")
           } else {
               print("No floors found for the selected building")
           }
       }
    }

    func retrieveRooms(for floor: Floor, completion: @escaping ([Room]) -> Void) {
        let db = Firestore.firestore()
        let floorRef = db.collection("Floors").document(floor.id)
        let roomsRef = db.collection("Rooms").whereField("floor", isEqualTo: floorRef)
        var rooms = [Room]()

        roomsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let roomId = document.documentID
                    let roomName = document.data()["name"] as? String ?? ""
                    let sizeMap = document.data()["size"] as? [String: Any] ?? [:]
                    let x = sizeMap["x"] as? Double ?? 0.0
                    let y = sizeMap["y"] as? Double ?? 0.0
                    let room = Room(id: roomId, name: roomName, floor: floor.id, x: x, y: y)
                    rooms.append(room)
                    print("Room ID: \(roomId), Name: \(roomName), X: \(room.x), y: \(room.y)")
                }
                completion(rooms)
            }
        }
    }

    func printRooms() {
        let selectedFloor = Floor(id: "KMzBA9JAH9uoMHhiCsqp", name: "ThirdFloor", buildingId: "4ukir9DTHOuKddb9Q95j")
        retrieveRooms(for: selectedFloor) { rooms in
            if !rooms.isEmpty {
                for room in rooms {
                    print("ID: \(room.id), Name: \(room.name), X: \(room.x), y: \(room.y)")
                }
            } else {
                print("No rooms found for the selected floor")
            }
        }
    }

    func retrieveBeacons(for room: Room, completion: @escaping ([Beacon]) -> Void) {
     let db = Firestore.firestore()
     let roomRef = db.collection("Rooms").document(room.id)
        let beaconsRef = db.collection("Beacons").whereField("room", isEqualTo: roomRef)
            var beacons = [Beacon]()

            beaconsRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion([])
                } else {
                    for document in querySnapshot!.documents {
                        let beaconId = document.documentID
                        let beaconUuid = document.data()["uuid"] as? String ?? ""
                        let beaconPosition = document.data()["position"] as? [String: Double] ?? [:]
                        let beaconName = document.data()["name"] as? String ?? ""
                        let beaconDescription = document.data()["description"] as? String ?? ""
                        let beacon = Beacon(id: beaconId, roomId: room.id, uuid: beaconUuid, position: beaconPosition, name: beaconName, description: beaconDescription)
                        beacons.append(beacon)
                    }
                    completion(beacons)
                }
            }
        }

    func printBeacons() {
        let selectedRoom = Room(id: "JWkKiPFgrqFzlyFNIJsA", name: "1", floor: "KMzBA9JAH9uoMHhiCsqp", x: 0, y: 0)
        retrieveBeacons(for: selectedRoom) { beacons in
                if !beacons.isEmpty {
                    for beacon in beacons {
                        print("Beacon ID: \(beacon.id)")
                        print("Room ID: \(beacon.roomId)")
                        print("UUID: \(beacon.uuid)")
                        
                        // Accessing values from the map-type "position" field
                        if let x = beacon.position["x"], let y = beacon.position["y"], let z = beacon.position["z"] {
                            print("Position: \(x), \(y), \(z)")
                        } else {
                            print("Invalid position data")
                        }
                        
                        print("Name: \(beacon.name)")
                        print("------------")
                    }
                } else {
                    print("No beacons found for the selected room")
                }
            }
    }    
}





