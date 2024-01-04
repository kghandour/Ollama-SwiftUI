//
//  Ollama_SwiftApp.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 07.10.23.
//

import SwiftUI

@main
struct Ollama_SwiftApp: App {
    
    let chatService = ChatService()
    let manageModelService = ManageModelService()

    var manageModelsViewModel: ManageModelsViewModel
    var chatViewModel: ChatViewModel

    init() {
        manageModelsViewModel = ManageModelsViewModel(chatService: chatService, manageModelService: manageModelService)
        chatViewModel = ChatViewModel(chatService: chatService)
    }
        
    var body: some Scene {
        let mainWindow = WindowGroup {
            ContentView()
                .environmentObject(manageModelsViewModel)
                .environmentObject(chatViewModel)
          }
          #if os(macOS)      
          Settings {
            SettingsView()
          }
          mainWindow.commands {
            CommandGroup(after: .newItem) {
              Button(action: {
                if let currentWindow = NSApp.keyWindow,
                  let windowController = currentWindow.windowController {
                  windowController.newWindowForTab(nil)
                  if let newWindow = NSApp.keyWindow,
                    currentWindow != newWindow {
                      currentWindow.addTabbedWindow(newWindow, ordered: .above)
                    }
                }
              }) {
                Text("New Tab")
              }
              .keyboardShortcut("t", modifiers: [.command])
            }
          }
          #else
          mainWindow
          #endif
    }
}
