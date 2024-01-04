//
//  DownloadProgressView.swift
//  Ollama Swift
//
//  Created by Otourou Da Costa on 04/01/2024.
//

import Foundation
import SwiftUI

struct DownloadProgressView: View {
    @EnvironmentObject var viewModel: ManageModelsViewModel

    var body: some View {
        HStack {
            Text("Downloading \(viewModel.modelName)")
            ProgressView(value: viewModel.completedSoFar, total: viewModel.totalSize)
            Text("\(Int(viewModel.completedSoFar / 1024 / 1024 ))/ \(Int(viewModel.totalSize / 1024 / 1024)) MB")
        }
    }
}
