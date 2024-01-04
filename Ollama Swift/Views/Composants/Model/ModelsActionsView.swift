//
//  ModelsActionsView.swift
//  Ollama Swift
//
//  Created by Otourou Da Costa on 04/01/2024.
//

import Foundation
import SwiftUI

struct ModelActionsView: View {
    @EnvironmentObject var viewModel: ManageModelsViewModel

    var body: some View {
        VStack {
            DuplicateModelView()
            AddModelView()
        }
    }
}

struct DuplicateModelView: View {
    @EnvironmentObject var viewModel: ManageModelsViewModel

    var body: some View {
        HStack {
            Text("Duplicate Model:").font(.headline)
            Picker("Duplicate Model:", selection: $viewModel.toDuplicate) {
                ForEach(viewModel.tags?.models ?? [], id: \.self) { model in
                    Text(model.name).tag(model.name)
                }
            }
            TextField("New Name", text: $viewModel.newName)
                .textFieldStyle(.roundedBorder)
            Button {
                viewModel.duplicateModel(source: viewModel.toDuplicate, destination: viewModel.newName)
            } label: {
                Image(systemName: "doc.on.doc")
                    .frame(width: 20, height: 20, alignment: .center)
            }
        }
    }
}

struct AddModelView: View {
    @EnvironmentObject var viewModel: ManageModelsViewModel

    var body: some View {
        HStack {
            Text("Add Model:")
            TextField("Add model:", text: $viewModel.modelName)
                .textFieldStyle(.roundedBorder)
            Button {
                viewModel.downloadModel(name: viewModel.modelName)
            } label: {
                Image(systemName: "arrowshape.down.fill")
                    .frame(width: 20, height: 20, alignment: .center)
            }
        }
    }
}
