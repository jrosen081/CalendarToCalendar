//
//  CustomError.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 6/28/18.
//  Copyright © 2018 Jack Rosen. All rights reserved.
//

import Foundation

struct CustomError{
    var localizedDescription: String
    init(_ description: String){
        self.localizedDescription = description
    }
}
