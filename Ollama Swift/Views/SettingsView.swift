//
//  SettingsView.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 14.10.23.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
            case general, models
        }
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
        }
    }
}

struct GeneralSettingsView: View {
    @AppStorage("host") private var host = "http://127.0.0.1"
    @AppStorage("port") private var port = "11434"
    
    var body: some View {
        Form {
            HStack{
                TextField("Host IP:", text: $host)
                TextField("Port:", text: $port)
                    .onChange(of: port) {
                        let filtered = port.filter { "0123456789".contains($0) }
                        if filtered != port {
                            self.port = filtered
                        }
                    }
            }
        }
        .padding()
        .frame(width: 350, height: 100)
    }
}


#Preview {
    SettingsView()
}
