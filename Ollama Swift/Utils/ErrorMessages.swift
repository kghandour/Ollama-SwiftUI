//
//  ErrorMessages.swift
//  Ollama Swift
//
//  Created by Karim ElGhandour on 14.10.23.
//

import Foundation

func invalidURLError(error: Error?) -> ErrorModel{
    return ErrorModel(showError: true, errorTitle: "Invalid URL given", errorMessage: "Make sure that Ollama is installed an online. Check Help for further info. \(String(describing: error?.localizedDescription)))")
}

func invalidDataError(error: Error?) -> ErrorModel{
    return ErrorModel(showError: true, errorTitle: "Invalid Data received", errorMessage: "Looks like there is a problem retrieving the data. \(String(describing: error?.localizedDescription)))")
}

func invalidTagsDataError(error: Error?) -> ErrorModel{
    return ErrorModel(showError: true, errorTitle: "No models have been detected!", errorMessage: "To download your first model, click on 'Manage Models', and enter a model name in the 'Add Model' field and click download. \(error?.localizedDescription)")
}

func invalidResponseError(error: Error?) -> ErrorModel{
    return ErrorModel(showError: true, errorTitle: "Invalid Response", errorMessage: "Looks like you are receiving a response other than 200! \(String(describing: error?.localizedDescription)))")
}

func unreachableError(error: Error?) -> ErrorModel{
    return ErrorModel(showError: true, errorTitle: "Server is unreachable", errorMessage: "Make sure Ollama ( https://ollama.ai/ ) is installed and running. If a different IP/PORT is used other than the default, change it in the app settings. \(String(describing: error?.localizedDescription)))")
}

func genericError(error: Error?) -> ErrorModel{
    return ErrorModel(showError: true, errorTitle: "An error has occured", errorMessage: "If restarting ollama does not fix it, please report the bug. \(String(describing: error?.localizedDescription)))")
}
