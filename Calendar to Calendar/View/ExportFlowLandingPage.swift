//
//  ExportFlowLandingPage.swift
//  Calendar to Calendar
//
//  Created by Jack Rosen on 11/12/22.
//  Copyright © 2022 Jack Rosen. All rights reserved.
//

import SwiftUI

struct AccountInfo {
    static let anyAccountsSignedIn = CurrentServer.allCases
        .contains(where: \.interactor.isSignedIn)
}

extension NSNotification.Name {
    static let onboardingFinished: Self = .init("Onboarding_Finished")
}

enum EventRequestError: Identifiable, Hashable {
    case noValues
    case error
    
    var id: Self { self }
    
    var alert: Alert {
        switch self {
        case .noValues:
            return Alert(title: Text("Oh no!"),
                         message: Text("There are no events matching your request"))
        case .error:
            return Alert(title: Text("Something Went Wrong!"),
                         message: Text("Please Try Again Later"))
        }
    }
}

struct ExportFlowLandingPage: View {
    @State private var requests: [CalendarRequest] = []
    @Binding var calendars: [CurrentServer: [Calendar]]
    @State private var isLoading = true
    @State private var nextEvents: [Event]? = nil
    @State private var isMakingRequest: Bool = false
    @State private var eventRequestError: EventRequestError? = nil
    @Environment(\.backgroundColor) var backgroundColor
    let goToSettings: () -> Void
    let anyAccountsSignedIn = AccountInfo.anyAccountsSignedIn
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading Calendars")
                    .onAppear(perform: loadCalendars)
            } else if calendars.isEmpty {
                VStack {
                    Image(systemName: "exclamationmark")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.red)
                        .frame(width: 50, height: 50)
                    Text("Something Went Wrong")
                        .font(.title)
                    VStack {
                        CircularButton {
                            goToSettings()
                        } label: {
                            Text("Check Account Status")
                        }
                        if anyAccountsSignedIn {
                            CircularButton {
                                loadCalendars()
                            } label: {
                                Text("Retry")
                            }
                        }
                    }
                }
            } else {
                ZStack {
                    let binding = Binding(get: { return self.nextEvents != nil },
                                          set: { _ in
                        self.nextEvents = nil
                    })
                    EventRequestingView(calendars: calendars, requests: $requests) { requests in
                        performRequest(requests: requests)
                    }
                    
                    NavigationLink(isActive: binding, destination: {
                        let nextEventsBinding = Binding(get: { nextEvents ?? [] }, set: { self.nextEvents = $0 })
                        EventListView(events: nextEventsBinding) {
                            binding.wrappedValue = false
                            requests = []
                        }
                    }, label: { EmptyView() })
                    if isMakingRequest {
                        backgroundColor
                            .ignoresSafeArea()
                        ProgressView()
                    }
                }.alert(item: $eventRequestError) { error in
                    error.alert
                }
            }
        }
        .navigationTitle(Text("Export Events"))
        .onReceive(NotificationCenter.default.publisher(for: .onboardingFinished)) { _ in
            loadCalendars()
        }
    }
    
    private func loadCalendars() {
        self.isLoading = true
        Task {
            for val in 1 ..< 4 where self.calendars.isEmpty {
                if val > 1 {
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
                await withTaskGroup(of: Void.self) { taskGroup in
                    for server in CurrentServer.allCases where server.interactor.isSignedIn  {
                        taskGroup.addTask {
                            do {
                                let calendars = try await server.interactor.getCalendars()
                                await MainActor.run {
                                    self.calendars[server] = calendars
                                }
                            } catch {
                                print(error)
                            }
                            
                        }
                        await taskGroup.waitForAll()
                    }
                }
            }
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func performRequest(requests: [CalendarRequest]) {
        self.isMakingRequest = true
        Task {
            do {
                let events = try await withThrowingTaskGroup(of: [Event].self) { taskGroup in
                    for request in requests {
                        taskGroup.addTask {
                            try await request.currentServer.interactor.fetchEvents(
                                name: request.nameRequest ? request.name : nil,
                                startDate: request.startDate,
                                endDate: request.endDate,
                                calendarID: request.calendar?.id ?? "")
                        }
                    }
                    var events: [Event] = []
                    for try await response in taskGroup {
                        events.append(contentsOf: response)
                    }
                    return events.sorted(by: { $0.startDate < $1.startDate })
                }
                await MainActor.run {
                    if events.isEmpty {
                        self.eventRequestError = .noValues
                    } else {
                        self.nextEvents = events
                    }
                    self.isMakingRequest = false
                }
            } catch {
                await MainActor.run {
                    self.eventRequestError = .error
                    self.isMakingRequest = false
                }
            }
            
        }
    }
}
