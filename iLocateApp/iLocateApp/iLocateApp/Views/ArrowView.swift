//
//  ArrowView.swift
//  iLocateApp
//
//  Created by Mateusz Dworaczyk on 20/12/2023.
//

import SwiftUI

struct ArrowView: View {
   @Binding var angle: Float
    @EnvironmentObject var uwbManager: EstimoteUWBManagerExample
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.colorScheme) var colorScheme

   var body: some View {
       Image(systemName: "arrow.up.forward")
           .rotationEffect(Angle(degrees: Double(angle)))
           .foregroundColor(colorScheme == .dark ? Color.blue : Color.pink)
           .scaleEffect(5.0)
   }
}



//#Preview {
//    ArrowView()
//}
