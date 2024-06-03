//
//  ChoosingView.swift
//  iLocateApp
//
//  Created by Mateusz Dworaczyk on 14/12/2023.
//

import SwiftUI

struct ChoosingView: View {
    @StateObject private var dataStore = DataStore()
    @ObservedObject var uwbManager: EstimoteUWBManagerExample
    @State private var showDetailView = false
    @Environment(\.colorScheme) var colorScheme
    
    init() {
        uwbManager = EstimoteUWBManagerExample()
    }
    
    
    var body: some View {
        
        NavigationStack {
            //HEAD
            VStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(colorScheme == .dark ? Color.blue : Color.pink)
                        .rotationEffect(Angle(degrees: 15))
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(colorScheme == .dark ? Color.blue : Color.pink)
                        .rotationEffect(Angle(degrees: -15))
                    VStack{
                        Text("iLocate")
                            .font(.system(size: 50))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .bold()
                        Text("Get to the right place")
                            .font(.system(size: 20))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .bold()
                    }
                    .padding(.top, 60)
                }
            }
            .frame(width: UIScreen.main.bounds.width*3, height: 300)
            .offset(y:-100)
            //BODY
            VStack {
                Text("Choose the destination!")
                    .font(.system(size: 20))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .bold()
                if dataStore.buildings.isEmpty {
                    Text("This location is unavailable!")
                        .offset(y:20)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    
                } else {
                    Picker("Select a building", selection: $dataStore.selectedBuilding) {
                        ForEach(dataStore.buildings.indices, id: \.self) { index in
                            Text(dataStore.buildings[index].name).tag(index)
                        }
                    }
                    .onChange(of: dataStore.selectedBuilding) { oldValue, newValue in
                        dataStore.retrieveFloors(for: dataStore.buildings[newValue]) { floors in
                            dataStore.floors = floors
                            dataStore.selectedFloor = 0
                        }
                    }
                    .pickerStyle(.wheel)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    if dataStore.floors.isEmpty {
                        Text("This location is unavailable!")
                            .offset(y:20)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    } else {
                        Picker("Select a floor", selection: $dataStore.selectedFloor) {
                            ForEach(dataStore.floors.indices, id: \.self) { index in
                                Text(dataStore.floors[index].name).tag(index)
                            }
                        }
                        .onChange(of: dataStore.selectedFloor) { oldValue, newValue in
                            dataStore.retrieveRooms(for: dataStore.floors[newValue]) { rooms in
                                dataStore.rooms = rooms
                                dataStore.selectedRoom = 0
                            }
                        }
                        .pickerStyle(.wheel)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        if dataStore.rooms.isEmpty {
                            Text("This location is unavailable!")
                                .offset(y:20)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        } else {
                            Picker("Select a room", selection: $dataStore.selectedRoom) {
                                ForEach(dataStore.rooms.indices, id: \.self) { index in
                                    Text(String(dataStore.rooms[index].name)).tag(index)
                                }
                            }
                            .onChange(of: dataStore.selectedRoom) { oldValue, newValue in
                                
                            }
                            .pickerStyle(.wheel)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Button(action: {
                                    print("Building confirmed: \(dataStore.selectedBuilding)")
                                    print("Floor confirmed: \(dataStore.selectedFloor)")
                                    print("Room confirmed: \(dataStore.selectedRoom)")
                                    showDetailView = true
                                }) {
                                    Text("Confirm")
                                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .offset(x:-20, y:-10)
                                                .size(width: 100.0, height: 40)
                                                .foregroundColor(colorScheme == .dark ? Color.blue : Color.pink)
                                        )
                                }
                                .navigationDestination(isPresented: $showDetailView){
                                    ContentView()
                                        .environmentObject(dataStore)
                                        .environmentObject(uwbManager)
                                    Text("")
                                        .hidden()

                                }
  
                            .offset(y:20)
                        }
                    }
                }
            }
            .onAppear {
                dataStore.retrieveBuildings { buildings in
                    dataStore.buildings = buildings
                    if let firstBuilding = buildings.first {
                        dataStore.retrieveFloors(for: firstBuilding) { floors in
                            dataStore.floors = floors
                        }
                    }
                }
            }
            .offset(y:50)
        //FOOTER
            VStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(colorScheme == .dark ? Color.blue : Color.pink)
                        .frame(height: 50)
                    
                    Text("Mateusz Dworaczyk 2023")
                        .font(.system(size: 10))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .bold()
                }
            }
            .frame(width: UIScreen.main.bounds.width*2,height: 200)
            .padding(.bottom)
            .offset(y:125)
        }
    }
}



#Preview {
    ChoosingView()
}
