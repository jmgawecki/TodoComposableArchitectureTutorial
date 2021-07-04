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
   let scheduler = DispatchQueue.test

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
            mainQueue:     scheduler.eraseToAnyScheduler(),
            uuid:          { fatalError("Unimplemented") }
         )
      )
      
      // Act and Assert
      store.assert(
         .send(.todo(index: 0, action: .checkboxTapped)) {
            $0.todos[0].isComplete = true
         },
         .do {
            self.scheduler.advance(by: 1)
//            _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
         },
         .receive(.todoDelayCompleted)
      )
   }
   
   
   func testAddTodo() {
      // Arrange
      let store = TestStore(
         initialState:  AppState(),
         reducer:       appReducer,
         environment:   AppEnvironemnt(
            mainQueue:     scheduler.eraseToAnyScheduler(),
            uuid:          { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")! }
         )
      )
      
      
      // Act and Assert
      store.assert(
         .send(.addButtonTapped) {
            $0.todos = [
               Todo(
                  id:            UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!,
                  description:   "",
                  isComplete:    false
               )
            ]
         }
      )
   }
   
   
   func testSortingTodos() {
      // Arrange
      let store = TestStore(
         initialState: AppState(
            todos: [
               Todo(id:             UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    description:    "Eggs",
                    isComplete:     false),
               
               Todo(id:             UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    description:    "Milk",
                    isComplete:     false)
            ]
         ),
         reducer:       appReducer,
         environment:   AppEnvironemnt(
            mainQueue:     scheduler.eraseToAnyScheduler(),
            uuid:          { fatalError("Unimplemented") }
         )
      )
      
      // Act & Assert
      store.assert(
         .send(.todo(index: 0, action: .checkboxTapped)) {
//            $0.todos[0].description = "something else"
            $0.todos[0].isComplete.toggle()
            
         },
         .do {
//            _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1.1)
            self.scheduler.advance(by: 1)
         },
         .receive(.todoDelayCompleted) {
            $0.todos = [
               Todo(id:             UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    description:    "Milk",
                    isComplete:     false),
               
               Todo(id:             UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    description:    "Eggs",
                    isComplete:     true)
            ]
         }
      )
   }
   
   
   func testSortingTodos2() {
      // Arrange
      let store = TestStore(
         initialState: AppState(
            todos: [
               Todo(id:             UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    description:    "Eggs",
                    isComplete:     false),
               
               Todo(id:             UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    description:    "Milk",
                    isComplete:     false)
            ]
         ),
         reducer:       appReducer,
         environment:   AppEnvironemnt(
            mainQueue:     scheduler.eraseToAnyScheduler(),
            uuid:          { fatalError("Unimplemented") }
         )
      )
      
      // Act & Assert
      store.assert(
         .send(.todo(index: 0, action: .checkboxTapped)) {
            $0.todos[0].isComplete = true
         },
         .do {
            self.scheduler.advance(by: 1)
//            _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
         },
         .receive(.todoDelayCompleted) {
            $0.todos.swapAt(0, 1)
         }
      )
   }
   
   
   func testSortingTodosCancellation() {
      // Arrange
      let store = TestStore(
         initialState: AppState(
            todos: [
               Todo(id:             UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    description:    "Eggs",
                    isComplete:     false),
               
               Todo(id:             UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    description:    "Milk",
                    isComplete:     false)
            ]
         ),
         reducer:       appReducer,
         environment:   AppEnvironemnt(
            mainQueue:     scheduler.eraseToAnyScheduler(),
            uuid:          { fatalError("Unimplemented") }
         )
      )
      
      // Act & Assert
      store.assert(
         .send(.todo(index: 0, action: .checkboxTapped)) {
            $0.todos[0].isComplete.toggle()
         },
         .do {
            self.scheduler.advance(by: 0.5)
//            _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 0.5)
         },
         .send(.todo(index: 0, action: .checkboxTapped)) {
            $0.todos[0].isComplete.toggle()
         },
         .do {
            self.scheduler.advance(by: 1)
//            _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
         },
         .receive(.todoDelayCompleted) {
            $0.todos = [
               Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    description: "Eggs",
                    isComplete: false),
               
               Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    description: "Milk",
                    isComplete: false)
            ]
         }
      )
   }
}
