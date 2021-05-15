//
//  ToDoComposableArchitectureApp.swift
//  ToDoComposableArchitecture
//
//  Created by Jakub Gawecki on 08/05/2021.
//

import SwiftUI
import ComposableArchitecture


@main
struct ToDoComposableArchitectureApp: App {
    var body: some Scene {
        WindowGroup {
            TodoView(store: Store<AppState, AppAction>(
                        initialState: AppState(),
                        reducer: appReducer,
                        environment: AppEnvironemnt()))
        }
    }
}
