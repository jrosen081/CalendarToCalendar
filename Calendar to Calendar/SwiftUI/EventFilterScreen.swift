//
//  EventFilterScreen.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 1/8/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

struct EventFilterScreen: View {
    let calendars: [Calendar]
    let filterByName: Bool
    @State private var nameFilter: String = ""
    @State private var selectedCalendarIndex = 0
    @State private var startDate: Date = Date()
    @State private var endDate = Date()
    var body: some View {
        Form {
            Picker("Calendar", selection: $selectedCalendarIndex) {
                ForEach(0..<calendars.count) { calendarIdx in
                    Text(calendars[calendarIdx].name)
                }
            }
            if filterByName {
                HStack {
                    Text("Event Name").padding(.trailing).padding(.trailing)
                    TextField("", text: $nameFilter)
                        .textFieldStyle(.roundedBorder)
                }
            }
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
            Button(action: {
                print("Thing")
            }) {
                Text("Search")
            }
        }.navigationBarTitle(Text("Event Filter"))
    }
}

struct EventFilterScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventFilterScreen(calendars: [Calendar(name: "Real", identifier: "id")], filterByName: true)
        }
    }
}
