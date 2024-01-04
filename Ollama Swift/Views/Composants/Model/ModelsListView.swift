//
//  ModelsListView.swift
//  Ollama Swift
//
//  Created by Otourou Da Costa on 04/01/2024.
//

import Foundation
import SwiftUI

struct ModelsListView: View {
    @EnvironmentObject var viewModel: ManageModelsViewModel

    var body: some View {
        List(viewModel.tags?.models ?? [], id: \.self) { model in
            ModelRow(model: model, removeModelAction: { viewModel.removeModel(name: model.name) })
        }
    }
}

struct ModelRow: View {
    var model: TagsModel
    var removeModelAction: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.name)
                Text("\(model.size / 1024 / 1024 / 1024, specifier: "%.3f") GB")
            }
            Spacer()
            Button(action: removeModelAction) {
                Image(systemName: "trash")
                    .frame(width: 20, height: 20, alignment: .center)
            }
        }
    }
}
