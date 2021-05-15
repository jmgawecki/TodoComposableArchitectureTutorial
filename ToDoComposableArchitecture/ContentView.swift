////
////  ContentView.swift
////  ToDoComposableArchitecture
////
////  Created by Jakub Gawecki on 08/05/2021.
////
//
//import SwiftUI
//import ComposableArchitecture
//
//
//struct Todo: Equatable, Identifiable {
//    let id: UUID
//    var description = ""
//    var isComplete = false
//}
//
//
//enum TodoAction {
//    case checkboxTapped
//    case textFieldChanged(text: String)
//}
//
//
//struct TodoEnvironment {
//
//}
//
//let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, _ in
//  switch action {
//  case .checkboxTapped:
//    state.isComplete.toggle()
//    return .none
//
//  case .textFieldChanged(let text):
//    state.description = text
//    return .none
//  }
//}
//
//
//struct AppState: Equatable {
//    var todos: [Todo]
//    // We use struct for state because it holds bunch of independent pieces of data
//    // Enum could makes sense too
//}
//
//enum AppAction {
//    // Enum represents one of many different type of actions that user can perform on a UI
//    // There may be a time when struct is also a good idea
//    case todo(index: Int, action: TodoAction)
//    case addButtonTapped
//
//}
//
//struct AppEnvironment {
//    // It holds all dependencies that our feature needs to do its job
//    // Its a struct cause all features are held independently from each other
//}
//
//// Thats what glues all of the above
////let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
////    // In this closure we will put all the logic of our application
////    switch action {
////    // we do this by switching over the action
////    // Here we would consider each case that is in app action enum and for each case we will run the business logic related to that action
////    // By BUSINESS LOGIC me mean something very specific
////    // 1. We will make any mutation of the state necessary for the action
////    // 2. After all state mutations, you return X - its a special type that allows you to communicate with the outside world, like executing API request, writing data to disk etc.
////    // This are the only two things that you are allowed to do in the reducer, all the pure logic happens in a state mutation, not a pure logic happens in effects
////    case .todoChecboxTapped(index: let index):
////        state.todos[index].isComplete.toggle()
////        return .none
////    case .todoTextFieldChanged(index: let index, text: let text):
////        state.todos[index].description = text
////        return .none
////    }
////}
////.debug()
//// MARK: - Explained above
//// We did commented it out and creating a new one cause we move all the logic from that app reducer into todoReduced above, therefore we can simplify that appReducer like that
//
//let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
//    todoReducer.forEach(
//        state: \.todos,
//        action: /AppAction.todo(index:action:),
//        environment: { _ in TodoEnvironment() }
//    ),
//    Reducer { state, action, environment in
//        switch action {
//        case .todo(index: let index, action: let action):
//            return .none
//        case .addButtonTapped:
//            state.todos.insert(Todo(id: UUID()), at: 0)
//            return .none
//        }
//    }
//)
//// We need a runtime object that is responsible for powering up our views by accumulating state changes over time as actions come in
//// Object that does that in Composible Architecture is known as Store and each view powered by composable architecture will need to hold onto one of these stores so that can get state updates and have action sent to it
//
//
//struct ContentView: View {
//    // lets add a store to our content view which is the root view for our application
//    // Store is generic for State that we can read from it
//    // Store is also generic for Action that can be sent to it
//    let store: Store<AppState, AppAction>
//
//    //    @ObservableObject var viewStore
//
//
//    var body: some View {
//        NavigationView {
//            WithViewStore(self.store) { viewStore in
//                List {
//                    ForEachStore(
//                        self.store.scope(
//                            state: \.todos,
//                            action: AppAction.todo(index:action:)
//                        ),
//                        content: TodoViewSmall.init(store: )
//                    )
//                }
//                .navigationBarTitle("Todos")
//                .navigationBarItems(trailing: Button("Add") {
//                    viewStore.send(.addButtonTapped)
//                })
//            }
//        }
//    }
//}
//
//
//struct TodoViewSmall: View {
//    let store: Store<Todo, TodoAction>
//    var body: some View {
//        WithViewStore(self.store) { viewStore in
//            HStack {
//                Button(action: { viewStore.send(.checkboxTapped) }) {
//
//                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
//                }
//                .buttonStyle(PlainButtonStyle())
//
//                TextField(
//                  "Untitled Todo",
//                  text: viewStore.binding(
//                    get: \.description,
//                    send: TodoAction.textFieldChanged(text:)
//                  )
//                )
//            }
//            .foregroundColor(viewStore.isComplete ? .gray : nil)
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(store: Store(initialState: AppState(todos: [
//            Todo(id: UUID.init(), description: "Something", isComplete: false),
//            Todo(id: UUID.init(), description: "Something", isComplete: false),
//            Todo(id: UUID.init(), description: "Something", isComplete: true)
//        ]),
//                                 reducer: appReducer,
//                                 environment: AppEnvironment()))
//    }
//}
