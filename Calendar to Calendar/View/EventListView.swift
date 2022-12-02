//
//  EventListView.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/9/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import Combine
import SwiftUI

enum EventError: Identifiable {
    case notAllowed
    case error
    
    var id: Self { self }
    
    func alert(retry: @escaping () -> Void) -> Alert {
        switch self {
        case .notAllowed:
            return Alert(title: Text("Please Grant Calendar Access"),
                         message: Text("Access to your calendar is required to add events"),
                         primaryButton: .default(Text("Grant Access")) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }, secondaryButton: .cancel())
        case .error:
            return Alert(title: Text("Something Went Wrong"),
                         primaryButton: .default(Text("Try again"), action: retry),
                         secondaryButton: .cancel())
        }
    }
}

struct EventListView: View {
    @Binding var events: [Event]
    @State private var isShowingTextOverlay: Bool = false
    @State private var isShowingAllAlarms: Bool = false
    @State private var eventListError: EventError? = nil
    @State private var openPublisher = PassthroughSubject<Bool, Never>()
    let dismiss: () -> Void
    
    private func saveEvents() {
        self.eventListError = nil
        Task {
            let error = await EventSaver.save(events: events)
            await MainActor.run {
                if let error {
                    self.eventListError = error
                } else {
                    dismiss()
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    CircularButton {
                        saveEvents()
                    } label: {
                        Label("Save", systemImage: "calendar.badge.plus")
                    }.foregroundColor(.green)
                    CircularButton {
                        withAnimation { isShowingTextOverlay = true }
                    } label: {
                        Label("Edit all names", systemImage: "pencil")
                    }
                    CircularButton {
                        withAnimation { isShowingAllAlarms = true }
                    } label: {
                        Label("Edit all alarms", systemImage: "alarm")
                    }
                    CircularButton {
                        openPublisher.send(true)
                    } label: {
                        Text("Expand All")
                    }
                    CircularButton {
                        openPublisher.send(false)
                    } label: {
                        Text("Collapse All")
                    }
                }.padding()
            }
            ScrollView {
                VStack {
                    ForEach($events) { $event in
                        EventView(event: $event,
                                  openValuePublisher: openPublisher.eraseToAnyPublisher()) {
                            events.removeAll(where: { $0 == event })
                        }
                        Divider()
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 0.2)
        .navigationTitle(Text("Event List"))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: events) {
            if $0.isEmpty { dismiss() }
        }
        .bottomSheet(isOpen: $isShowingTextOverlay) {
            EventNameEditingView { name in
                self.events = self.events.map { event in
                    var newEvent = event
                    newEvent.name = name
                    return newEvent
                }
                isShowingTextOverlay = false
            }
        }
        .bottomSheet(isOpen: $isShowingAllAlarms) {
            AlarmEditingView { alarm in
                self.events = self.events.map { event in
                    var newEvent = event
                    newEvent.alarm = alarm
                    return newEvent
                }
                isShowingAllAlarms = false
            }
        }
        .alert(item: $eventListError) { error in
            error.alert(retry: self.saveEvents)
        }
    }
}

struct EventView: View {
    @State private var isOpened = true
    @Binding var event: Event
    let openValuePublisher: AnyPublisher<Bool, Never>
    let onDelete: () -> Void
    
    private var startDateBinding: Binding<Date> {
        Binding(get: { event.startDate }) { newValue in
            event.startDate = newValue
            if newValue > event.endDate {
                event.endDate = newValue
            }
        }
    }
    
    private var endDateBinding: Binding<Date> {
        Binding(get: { event.endDate }) { newValue in
            event.endDate = newValue
            if newValue < event.startDate {
                event.startDate = newValue
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Group {
                    if isOpened {
                        TextField("Name", text: $event.name)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Text(event.name)
                    }
                }
                .font(.headline)
                Spacer()
                if event.alarm != .none, !isOpened {
                    Image(systemName: "alarm")
                }
                if event.isAllDay && !isOpened {
                    Image(systemName: "calendar")
                }
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                Button {
                    withAnimation { self.isOpened.toggle() }
                } label: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isOpened ? 90 : 0))
                }
            }
            if isOpened {
                ConfigurationView {
                    ConfigurationRow("Start Date") {
                        DatePicker(selection: startDateBinding)
                    }
                    ConfigurationRow("End Date") {
                        DatePicker(selection: endDateBinding)
                    }
                    ConfigurationRow("Alarm") {
                        AlarmPicker(selection: $event.alarm)
                            .pickerStyle(.menu)
                    }
                    ConfigurationRow("All Day?") {
                        Toggle(isOn: $event.isAllDay)
                    }
                }
                
            }
        }
        .labelsHidden()
        .onReceive(openValuePublisher) {
            self.isOpened = $0
        }
    }
}

private func AlarmPicker(selection: Binding<AlarmSetting>) -> some View {
    Picker("", selection: selection) {
        ForEach(AlarmSetting.allCases, id: \.self) { setting in
            Text(Event.alarmPickerDate[setting.rawValue])
        }
    }.layoutPriority(1)
}

struct EventNameEditingView: View {
    @State private var text = ""
    let nameCreator: (String) -> Void
    
    var body: some View {
        VStack {
            Text("What would you like to name the events?")
                .font(.title)
            TextField("Name", text: $text)
                .textFieldStyle(.roundedBorder)
            Spacer()
            CircularButton {
                nameCreator(text)
            } label: {
                HStack {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
            }.foregroundColor(.green)
        }
    }
}

struct AlarmEditingView: View {
    @State private var alarmSetting = AlarmSetting.none
    let onSave: (AlarmSetting) -> Void
    
    var body: some View {
        VStack {
            Text("When would you like all alarms to be set?")
                .font(.title)
            AlarmPicker(selection: $alarmSetting)
                .pickerStyle(.wheel)
                .padding(.bottom, 24)
            CircularButton {
                onSave(alarmSetting)
            } label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
            }.foregroundColor(.green)
        }
    }
}
