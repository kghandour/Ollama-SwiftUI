//
//  ChatToolbar.swift
//  Ollama Swift
//
//  Created by Otourou Da Costa on 04/01/2024.
//

import Foundation
import SwiftUI

struct ChatToolbar: ToolbarContent {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var showingErrorPopover: Bool = false

    @ToolbarContentBuilder
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic){
            HStack {
                Picker("Model:", selection: self.$viewModel.prompt.model) {
                    ForEach(self.viewModel.tags?.models ?? [], id: \.self) { model in
                        Text(model.name).tag(model.name)
                    }
                }
                NavigationLink {
                    ManageModelsView()
                } label: {
                    Label("Manage Models", systemImage: "gearshape")
                }
            }
            if self.viewModel.errorModel.showError {
                Button {
                    self.showingErrorPopover.toggle()
                } label: {
                    Label("Error", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
                .popover(isPresented: self.$showingErrorPopover) {
                    VStack(alignment: .leading) {
                        Text(self.viewModel.errorModel.errorTitle)
                            .font(.title2)
                            .textSelection(.enabled)
                        Text(self.viewModel.errorModel.errorMessage)
                            .textSelection(.enabled)
                    }
                    .padding()
                }
                
            } else {
                Text("Server:")
                Label("Connected", systemImage: "circle.fill")
                    .foregroundStyle(.green)
            }
            Button {
                self.viewModel.getTags()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 20, height: 20, alignment: .center)
            }
        }
    }
}
