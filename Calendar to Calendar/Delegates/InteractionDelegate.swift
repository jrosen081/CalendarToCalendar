//
//  InteractionDelegate.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 7/20/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation

protocol InteractionDelegate: class{
    /**
     - parameter error: The server returned an error
     */
    func returnedError(error: CustomError)
    /**
     - parameter data: The data the server returned
    */
    func returnedResults(data: Any)
}
