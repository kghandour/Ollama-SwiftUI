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

func invalidResponseError(error: Error?) -> ErrorModel{
    return ErrorModel(showError: true, errorTitle: "Invalid Response", errorMessage: "Looks like you are receiving a response other than 200! \(String(describing: error?.localizedDescription)))")
}

func unreachableError(error: Error?) -> ErrorModel{
    return ErrorModel(showError: true, errorTitle: "Server is unreachable", errorMessage: "Try to open ollama and press refresh. Update HOST and PORT in settings. \(String(describing: error?.localizedDescription)))")
}

func genericError(error: Error?) -> ErrorModel{
    return ErrorModel(showError: true, errorTitle: "An error has occured", errorMessage: "If restarting ollama does not fix it, please report the bug. \(String(describing: error?.localizedDescription)))")
}
