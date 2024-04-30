//
//  stepView.swift
//  Campus
//
//  Created by Zak Young on 2/22/24.
//

import SwiftUI

struct stepView: View {
    @EnvironmentObject var mapManager: MapManager
    @State private var showSwipe: Bool = true
    var body: some View {
        VStack {
            TabView(selection: $mapManager.currentStepIndex) {
                ForEach(Array(mapManager.routes.first?.steps.enumerated() ?? [].enumerated()), id: \.element) { index, step in
                    Text(step.instructions)
                        .tag(index)
                        .fontWeight(.semibold)
                }
            }
            .tabViewStyle(.page)
            .frame(height: 100)
            HStack {
                Button("End Route") {
                    mapManager.endRoute()
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                .foregroundColor(.white)
                .background(Color.red)
                .font(.system(size: 15))
                .cornerRadius(5)
                Spacer()
            }
        }
        .background(Color(red: 214 / 255, green: 221 / 255, blue: 245 / 255))
        .id(mapManager.currentStepIndex)
    }
}


#Preview {
    stepView()
        .environmentObject(MapManager())
}
