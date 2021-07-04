//
//  TodoView.swift
//  ToDoComposableArchitecture
//
//  Created by Jakub Gawecki on 10/05/2021.
//

import SwiftUI
import ComposableArchitecture


// MARK: - Todo structure


struct Todo: Equatable, Identifiable {
   let id: UUID
   var description = ""
   var isComplete  = false
}


enum TodoAction: Equatable {
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


// MARK: - App structure


struct AppState: Equatable {
   var todos: [Todo] = []
}


enum AppAction: Equatable {
   case todo(index: Int, action: TodoAction)
   case addButtonTapped
   case todoDelayCompleted
}


struct AppEnvironemnt {
   var mainQueue: AnySchedulerOf<DispatchQueue>
   var uuid: () -> UUID
}


let appReducer = Reducer<AppState, AppAction, AppEnvironemnt>.combine(
   todoReducer.forEach(
      state: \AppState.todos,
      action: /AppAction.todo(index:action:),
      environment: { _ in TodoEnvironment() }
   ),
   Reducer { state, action, environemnt in
      switch action {
      case .todo(index: _, action: .checkboxTapped):
         struct CancelDelayId: Hashable {}
         
         return Effect(value: AppAction.todoDelayCompleted)
            .debounce(id: CancelDelayId(), for: 1, scheduler: environemnt.mainQueue)
         // that line above, replaces 3 lines below
//            .delay(for: 1, scheduler: RunLoop.main)
//            .eraseToEffect()
//            .cancellable(id: CancelDelayId(), cancelInFlight: true)
         
      case .todo(index: let index, action: let action):
         return .none
         
      case .addButtonTapped:
         state.todos.insert(Todo(id: environemnt.uuid()), at: 0)
         return .none
         
      case .todoDelayCompleted:
         state.todos = state.todos
            .enumerated()
            .sorted { lhs, rhs in
               (!lhs.element.isComplete && rhs.element.isComplete)
                  || lhs.offset < rhs.offset
         }
            .map (\.element)
         return .none
      }
   }
)
.debug()


// MARK: - View


struct TodoView: View {
   let store: Store<AppState, AppAction>
   var body: some View {
      NavigationView {
         WithViewStore(self.store) { viewStore in
            List {
               ForEachStore(
                  self.store.scope(
                     state: \.todos,
                     action: AppAction.todo(index:action:)
                  ),
                  content: TodoSmallView.init(store:)
               )
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Todos")
            .navigationBarItems(trailing:
                                    Button(
                                       action: {
                                          viewStore.send(.addButtonTapped)
                                       },
                                       label: { Text("Add Todo") }
                                    )
            )
            .animation(.default)
         }
      }
   }
}


// MARK: - Preview


struct TodoView_Previews: PreviewProvider {
   static var previews: some View {
      TodoView(store: Store<AppState, AppAction>(
         initialState: AppState(
            todos: [
               Todo(id: UUID(), description: "Something", isComplete: false),
               Todo(id: UUID(), description: "Different", isComplete: false),
               Todo(id: UUID(), description: "Than", isComplete: false),
               Todo(id: UUID(), description: "Before", isComplete: false),
               Todo(id: UUID(), description: "Eggs", isComplete: false)
            ]
         ),
         reducer: appReducer,
         environment: AppEnvironemnt(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            uuid: UUID.init
         )
      ))
   }
}


// MARK: - Child View


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
