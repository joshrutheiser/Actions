
# To do

Try subset view first since it is easy to implement.

## Today approach

Options:
1. View of backlog
2. Move back and forth
3. References from each

- Do I need a today list? possible approaches:
    * Show top X items from backlog.
        How to handle child tasks?
        Creating a new task in Today
            Adds only to backlog, and Today "view" just reflects what is in the backlog
        Pros
            Changes in the backlog are immediately reflected in Today and vice versa. So don't have to add things to today and skip from today to get them to match.
        Cons
            Handling adding child tasks is a little complicated. Adding Tasks in general will require managing another variable
    * Move from backlog to today. 
        How to handle child tasks? 
            They would become detached or I'd need to track a reference. Technically, the child task could keep a reference to the parent, and we could make some assumptions about putting it back to the top of the parent's children.
        How would this work?
            First open of the day would check how many items are in Today. If there are too many, then it would move the bottom items over to backlog top. If there are not enough, then it would pull from top of backlog.
            To handle scheduled items, we would move to the top of Today before doing any other changes to the Today list.
            Skipping an item would move it back to the backlog and then pull a different item forward. Maybe we'd pull different item first and then move the skipped item to the backlog to avoid picking it up again.
        Creating new task in Today
            Does nothing to the backlog.
    * Reference backlog tasks in Today. 
        How to handle prioritization changes?
            At the first open of the day, we'd have an algorithm that adjusts items in the backlog to match the Today's prioritization. Likely we would just move all those tasks to the top.
        Creating new task in Today
            Also adds it to the backlog.




- write firebase security rules for userId



# Features

real-time safe cross-device collaboration



# Complete

- Write function headers for controller functions
- Write unit tests for Database Writer and Reader
- Investigate setting root path in database reader (NSPredicate?)
- Enable updating action when isCompleted changes in database through listener
- Fix double action notify in the beginning



# References

For Firestore unit testing and querying inspiration:
    https://github.com/sgr-ksmt/FireSnapshot/tree/master/FireSnapshotTests/Sources
