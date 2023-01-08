
# Examples

Writing example:

```swift

let model = ModelController(UUID().uuidString, self)
Task {
    do {
        // load data from database and start listening to changes
        try await model.startListening()
        
        // create an action
        let idA = try await model.write.createAction("A")
        
        // create an action with a parent
        let idB = try await model.write.createAction("B", parentId: idA)

        // move child action from parent to backlog
        try await model.write.moveActionTo(idB!, parentId: nil)

        // delete action
        try await model.write.deleteAction(idA!)
        
        // complete action
        try await model.write.completeAction(idB!)
    } catch {
        print(error)
    }
}

```

Reading example:

```swift
let model = ModelController(UUID().uuidString, self)
let actions = model.read.getActions()
let user = model.read.getUser()
```

# To do

- Design Backlog view and implement Today view to identify if the model needs to change.
- write firebase security rules for userId


# Features

real-time safe cross-device collaboration


# References

For Firestore unit testing and querying inspiration:
    https://github.com/sgr-ksmt/FireSnapshot/tree/master/FireSnapshotTests/Sources
