//
//  EventCriteriaView.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/10/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

struct EventRequestView: View {
    @Binding var selectedCalendar: Calendar?
    @Binding var name: String
    @Binding var shouldShowName: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    let calendars: [Calendar]
    let onDelete: () -> Void

    private var startDateBinding: Binding<Date> {
        Binding(get: { startDate }) { newValue in
            startDate = newValue
            if newValue > endDate {
                endDate = newValue
            }
        }
    }

    private var endDateBinding: Binding<Date> {
        Binding(get: { endDate }) { newValue in
            endDate = newValue
            if newValue < startDate {
                startDate = newValue
            }
        }
    }

    var body: some View {
        ConfigurationView {
            ConfigurationRow("Is there a specific name you are looking for?") {
                Toggle(isOn: $shouldShowName.animation())
            }
            if shouldShowName {
                ConfigurationRow("Event Name") {
                    TextField("", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .padding(.leading)
                }
            }
            ConfigurationRow("Calendar") {
                Picker("", selection: $selectedCalendar) {
                    Text("Choose Calendar")
                        .tag(Optional<Calendar>.none)
                    ForEach(calendars) { calendar in
                        Text(calendar.name)
                            .tag(Optional.some(calendar))
                    }
                }.layoutPriority(1)
            }
            ConfigurationRow("Start Date") {
                DatePicker(selection: startDateBinding)
            }
            ConfigurationRow("End Date") {
                DatePicker(selection: endDateBinding)
            }
            CircularButton {
                onDelete()
            } label: {
                Label("Remove", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }.foregroundColor(.red)
        }
    }
}
