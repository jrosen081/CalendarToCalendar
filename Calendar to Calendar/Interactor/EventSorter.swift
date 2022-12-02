//
//  EventSorter.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 12/1/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import Foundation

struct EventSorter {
    /*
     func sort(){
     DispatchQueue.global(qos: .userInitiated).async{
     var sorted = [(Int, Int)]()
     let stringFormatter = DateFormatter()
     stringFormatter.dateFormat = "MM/dd/yyyy"
     for event in self.events{
     sorted.append((self.getDayOfWeek(date: stringFormatter.string(from: event.startDate)).1, Foundation.Calendar.current.component(.hour, from: event.startDate)))
     }
     var added = 0
     var badEvents = [Event]()
     for counter in 1 ... 7{
     let filtered = sorted.filter({$0.0 == counter})
     if (filtered.count > 2)
     {
     let index = self.returnIndices(events: filtered)
     if (!index.isEmpty)
     {
     for counter in 0 ..< index.count{
     if let eventIndex = sorted.firstIndex(where: {$0.0 == index[counter].0 && $0.1 == index[counter].1}){
     badEvents.append(self.events[Int(eventIndex) + added])
     added += 1
     sorted.remove(at: eventIndex)
     }
     }
     }
     }
     }
     if (added > 0)
     {
     self.wrongEvents = badEvents
     if UserDefaults.standard.integer(forKey: "Version") >= 2 {
     self.showIncorrectEvents()
     }
     }
     }
     }
     func returnIndices(events: [(Int, Int)]) -> [(Int, Int)]
     {
     var intArray = [Int]()
     var returnArray = [(Int, Int)]()
     for counter in 0 ..< events.count{
     intArray.append(events.filter({$0.1 == events[counter].1}).count)
     }
     var array = intArray.filter({$0 == 1})
     if (array.count >= 1 && array.count <= events.count / 2)
     {
     while (!array.isEmpty){
     if let index = intArray.firstIndex(of: 1){
     returnArray.append(events[index])
     array.removeFirst()
     }
     
     }
     }
     return returnArray
     }
     */
}
