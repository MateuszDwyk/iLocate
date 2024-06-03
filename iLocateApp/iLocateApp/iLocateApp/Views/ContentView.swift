//
//  ContentView.swift
//  iLocateApp
//
//  Created by Mateusz Dworaczyk on 29/11/2023.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var uwbManager: EstimoteUWBManagerExample
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedBeaconIndex = 0
    @State private var angleToBeacon: Double?
    @State private var isRanging: Bool = false
    @State private var isNavigating: Bool = false
    @State var rangingResultsView: [Float]?
    @State private var isPresented: Bool = false
    @State private var angle: Float = 0.0
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State private var distanceToBeacon: Float = 0.0

    var body: some View {
        VStack {
            VStack{
                //Header
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
            .offset(y:-140)
            //BODY
            ZStack{
                VStack{
                    Text("Choose the place!")
                        .font(.system(size: 20))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .bold()
                    Picker("Select Beacon", selection: $selectedBeaconIndex) {
                        ForEach(dataStore.beacons.indices, id: \.self) { index in
                            Text(dataStore.beacons[index].description)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .offset(y:20)
                    
                    Button(action: {
                        angle = uwbManager.calculateAngleWithParameters(data: dataStore, selectedBeacon: selectedBeaconIndex)
                        isPresented.toggle()
                        toggleNavigating()
                        getDistanceToSelectedBeacon()
                    }) {
                        Text(isNavigating ? "Stop Navigating" : "Start Navigating")
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .offset(x:-20, y:-10)
                                    .size(width: 160, height: 40)
                                    .foregroundColor(colorScheme == .dark ? Color.blue : Color.pink)
                            )
                    }
                    .offset(y:50)
                }
                .offset(y:-30)
                VStack{
                    if isPresented && isNavigating {
                        
                        ArrowView(angle: $angle)
                            .environmentObject(dataStore)
                            .environmentObject(uwbManager)
                        if (distanceToBeacon>=0){
                            Text("Estimated distance: \(distanceToBeacon, specifier: "%.2f") m")
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .offset(y: 50)
                            if (distanceToBeacon==0){
                                Text("You are on the right destination!").foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    .offset(y: 50)
                            }
                        }
                        Button(action: {
                            updateAngle()
                            getDistanceToSelectedBeacon()
                        }) {
                            Text("Update Angle")
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .offset(x:-25, y:-10)
                                        .size(width: 160, height: 40)
                                        .foregroundColor(colorScheme == .dark ? Color.blue : Color.pink)
                                )
                        }
                        .offset(y:70)
                    }
                    Text("")
                        .hidden()
                }
                .offset(y:175)
            }
            .offset(y:0)
                ZStack{
                    //FOOTER
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
                .position(x: UIScreen.main.bounds.width/2,y: 325)
        }
        .onAppear {
            toggleRanging()
            retrieveBeaconsForCurrentRoom()
        }
        .onDisappear {
            toggleRanging()
        }
        Spacer()
            .navigationBarBackButtonHidden(true)
            .animation(.default, value: 1)
            .toolbar(
                content: {ToolbarItem(
                    placement: .navigationBarLeading){
                        Button(
                            action: {
                                presentationMode.wrappedValue.dismiss()
                            },
                            label: {
                                Image(systemName: "house")
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Text("Home")
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            })
                    }
                }
            )
    }
    func getDistanceToSelectedBeacon(){
        distanceToBeacon = uwbManager.getDistanceToBeacon(selectedBeacon: selectedBeaconIndex)
    }
    func updateAngle() {
        angle = uwbManager.calculateAngleWithParameters(data: dataStore, selectedBeacon: selectedBeaconIndex)
    }
    func toggleRanging() {
        if isRanging {
            stopUwbRanging()
        } else {
            startUwbRanging()
        }
    }
    func toggleNavigating() {
        if !isNavigating {
            isNavigating = true
        } else {
            isNavigating = false
        }
    }

    func startUwbRanging() {
        isRanging = true
        uwbManager.startScanning()
    }

    func stopUwbRanging() {
        isRanging = false
        uwbManager.stopScanning()
    }

    func retrieveBeaconsForCurrentRoom() {
        dataStore.retrieveBeacons(for: dataStore.rooms[dataStore.selectedRoom]) { beacons in
            dataStore.beacons = beacons
        }
    }
}



//#Preview {
//    ContentView()
//}
