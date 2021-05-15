//
//  TodoView.swift
//  ToDoComposableArchitecture
//
//  Created by Jakub Gawecki on 10/05/2021.
//

import SwiftUI
import ComposableArchitecture

struct Todo: Equatable, Identifiable {
   let id: UUID
   var description = ""
   var isComplete  = false
}

enum TodoAction {
   case checkboxTapped
   case textFieldChanged(String)
}

struct TodoEnvironment { }

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
   switch action {
   case .checkboxTapped:
      state.isComplete.toggle()
      return .none
   case .textFieldChanged(let text):
      state.description = text
      return .none
   }
}

struct AppState: Equatable {
   var todos: [Todo] = []
}

enum AppAction {
   case todo(index: Int, action: TodoAction)
}


struct AppEnvironemnt {
}

//let appReducer = Reducer<AppState, AppAction, AppEnvironemnt> { state, action, environment in
//    switch action {
//    case .todo(index: let index, action: let action):
//        //
//    }
//}
//.debug()

let appReducer: Reducer<AppState, AppAction, AppEnvironemnt> = todoReducer.forEach(
   state: \AppState.todos,
   action: /AppAction.todo(index:action:),
   environment: { _ in TodoEnvironment() }
)
.debug()

struct TodoView: View {
   let store: Store<AppState, AppAction>
   var body: some View {
      NavigationView {
         WithViewStore(self.store) { _ in
            List {
               ForEachStore(
                  self.store.scope(
                     state: \.todos,
                     action: AppAction.todo(index:action:)
                  ),
                  content: TodoSmallView.init(store:)
               )
            }
            .navigationBarTitle("Todos")
         }
      }
   }
}

//
//struct TodoSubView: View {
//    var body: some View {
//
//    }
//}



struct TodoView_Previews: PreviewProvider {
   static var previews: some View {
      TodoView(store: Store<AppState, AppAction>(
                initialState: AppState(
                  todos: [
                     Todo(id: UUID(), description: "Something", isComplete: false),
                     Todo(id: UUID(), description: "Something", isComplete: false),
                     Todo(id: UUID(), description: "Something", isComplete: false),
                     Todo(id: UUID(), description: "Something", isComplete: false),
                     Todo(id: UUID(), description: "Something", isComplete: false)
                  ]
                ),
                reducer: appReducer,
                environment: AppEnvironemnt()))
   }
}

struct TodoSmallView: View {
   let store: Store<Todo, TodoAction>
   
   var body: some View {
      WithViewStore(self.store) { todoViewStore in
         HStack {
            Button(action: { todoViewStore.send(.checkboxTapped) })
            {
               Image(systemName: todoViewStore.isComplete ? "checkmark.square" : "square")
            }
            .buttonStyle(PlainButtonStyle())
            
            TextField(
               "Untitiled Todo",
               text: todoViewStore.binding(
                  get: \.description,
                  send: TodoAction.textFieldChanged
               )
            )
         }
         .foregroundColor(todoViewStore.isComplete ? .gray : nil)
      }
   }
}
