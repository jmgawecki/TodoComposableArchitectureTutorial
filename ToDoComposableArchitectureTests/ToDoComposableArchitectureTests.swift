//
//  ToDoComposableArchitectureTests.swift
//  ToDoComposableArchitectureTests
//
//  Created by Jakub Gawecki on 08/05/2021.
//

import XCTest
@testable import ToDoComposableArchitecture
import ComposableArchitecture

class ToDoComposableArchitectureTests: XCTestCase {

   func testCompletingTodo() {
      // Arrange
      let store = TestStore(
         initialState: AppState(
            todos: [
               Todo(
                  id:            UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                  description:   "Todo",
                  isComplete:    false
               )
            ]
         ),
         reducer:       appReducer,
         environment:   AppEnvironemnt(
            uuid:       { fatalError("Unimplemented") }
         )
      )
      
      // Act and Assert
      store.assert(
         .send(.todo(index: 0, action: .checkboxTapped)) {
            $0.todos[0].isComplete = true
         }
      )
   }
   
   
   func testAddTodo() {
      // Arrange
      let store = TestStore(
         initialState: AppState(),
         reducer: appReducer,
         environment: AppEnvironemnt(
            uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")! }
         )
      )
      
      
      // Act and Assert
      store.assert(
         .send(.addButtonTapped) {
            $0.todos = [
               Todo(
                  id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!,
                  description: "",
                  isComplete: false
               )
            ]
         }
      )
   }
   
}
