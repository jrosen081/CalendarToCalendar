//
//  EventRequestingView.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/11/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

struct CalendarRequest: Identifiable {
    let currentServer: CurrentServer
    let id = UUID()
    var name: String
    var calendar: Calendar?
    var startDate: Date
    var endDate: Date
    var nameRequest: Bool = false
}

struct EventRequestingView: View {
    let calendars: [CurrentServer: [Calendar]]
    @Binding var requests: [CalendarRequest]
    let performRequest: ([CalendarRequest]) -> Void

    private var isDisabled: Bool {
        requests.isEmpty || requests.contains(where: { $0.calendar == nil })
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    CircularButton {
                        performRequest(requests)
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .disabled(isDisabled)
                    .foregroundColor(isDisabled ? .gray.opacity(0.4) : .green)
                    ForEach(Array(calendars.keys)) { server in
                        CircularButton {
                            requests.append(CalendarRequest(currentServer: server, name: "", calendar: nil, startDate: Date(), endDate: Date()))
                        } label: {
                            Label(server.rawValue, systemImage: "plus")
                        }
                    }
                }.padding()
            }
            if requests.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "calendar.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64)
                    Text("Add an event using one of the accounts above")
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack {
                        ForEach($requests) { $request in
                            EventRequestView(selectedCalendar: $request.calendar,
                                             name: $request.name,
                                             shouldShowName: $request.nameRequest,
                                             startDate: $request.startDate,
                                             endDate: $request.endDate,
                                             calendars: calendars[request.currentServer] ?? []) {
                                withAnimation {
                                    self.requests.removeAll(where: { $0.id == request.id })
                                }
                            }
                                             .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
}
