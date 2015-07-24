SwiftGoal
=========

This project showcases the Model-View-ViewModel (MVVM) architecture with [ReactiveCocoa 3][reactive-cocoa], while serving as a digital logbook of [FIFA matches][fifa-wikipedia]. It was inspired on a theoretical level by Justin Spahr-Summers' talk [Enemy of the State][enemy-of-the-state], and on a more practical one by Ash Furrow's [C-41][c-41] app.

[reactive-cocoa]: https://github.com/ReactiveCocoa/ReactiveCocoa
[fifa-wikipedia]: https://en.wikipedia.org/wiki/FIFA_(video_game_series)
[enemy-of-the-state]: https://github.com/jspahrsummers/enemy-of-the-state
[c-41]: https://github.com/ashfurrow/C-41

As the Swift language and the ecosystem around it [matured][reactive-cocoa-releases], porting the original [ObjectiveGoal][objective-goal] project became a natural next step, as Swift's type safety makes it a perfect fit for functional reactive programming.

[reactive-cocoa-releases]: https://github.com/ReactiveCocoa/ReactiveCocoa/releases
[objective-goal]: https://github.com/richeterre/ObjectiveGoal

Setup
-----

The application uses [Goalbase][goalbase] as a backend to store, process and retrieve information. It assumes you have a Goalbase instance running at `http://localhost:3000`, which is the default URL of the WEBrick server that ships with Rails. Please check out the [Goalbase documentation][goalbase-docs] for more detailed instructions.

[goalbase]: https://github.com/richeterre/goalbase
[goalbase-docs]: https://github.com/richeterre/goalbase/blob/master/README.md

If you want to provide your own backend, simply change the base URL path in `Store.swift`.

User Features
-------------

* [x] Create players
* [x] Create matches with home/away players and score
* [x] View list of matches
* [x] Edit existing match information
* [x] Delete matches
* [x] Pull-to-refresh any list in the app
* [x] See animated list changes
* [x] Enjoy custom fonts and colors
* [x] Get alerts about network and server errors
* [ ] View player rankings
* [ ] Switch between different ranking periods (last month, all time, …)
* [ ] See date and time of each match
* [ ] See matches grouped by date range (e.g. last week, last month, earlier)
* [ ] View more player statistics (e.g. won/drawn/lost count, nemesis player, …)
* [ ] Delete players alongside their dependent matches

Code Checklist
--------------

* [x] Validate player name before creating
* [x] Validate match player counts before creating
* [ ] Move base URL to Settings for easy customization
* [ ] Cancel network requests when the associated view becomes inactive
* [ ] Retry network requests 1 or 2 times before giving up
* [ ] Improve algorithm that determines list changes
    * [ ] Detect match data changes
    * [ ] Add support for sections
* [ ] Write tests for view models, models, helpers and store
* [ ] Deduplicate `isActiveSignal` code on view controllers (via a protocol extension?)
* [ ] Create watchOS 2 app for quick match entry
* [ ] Drop Auto Layout [library][snapkit] in favor of `UIStackView` and `NSLayoutAnchor`

[snapkit]: https://github.com/SnapKit/SnapKit

Benefits of MVVM
----------------

__High testability:__ The basic premise of testing is to verify correct output for a given input. As a consequence, any class that minimizes the amount of dependencies affecting its output becomes a good candidate for testing. MVVM's separation of logic (the view model layer) from presentation (the view layer) means that the view model can be tested with minimal setup. For instance, injecting a mock `Store` that provides a known amount of `Match` instances is enough to verify that the `MatchesViewModel` reports the correct amount of matches. The view layer becomes trivial, as it simply binds to those outputs.

__Better separation of concerns:__ `UIViewController` and its friends have been rightfully [scorned][mvc-tweet] for handling far too many things, from interface rotation to networking to providing table data. MVVM solves this by making a clear cut between UI and business logic. While a view controller would still acts as its table view's data source, it forwards the actual data queries to its own view model. Presentation details, such as animating new rows into the table view, will be handled in the view layer.

__Encapsulation of state:__ As suggested by Gary Bernhardt in his famous talk [“Boundaries”][boundaries-talk], view models offer a stateful shell around the stateless core of the app, the model layer. If need be, the app's state can be persisted and restored simply by storing the view model. While the view may be extremely stateful too, its state is ultimately derived from that of the view model, and thus does not require to be stored.

[mvc-tweet]: https://twitter.com/colin_campbell/status/293167951132098560
[boundaries-talk]: https://www.destroyallsoftware.com/talks/boundaries

Open Issues
-----------

* What does match identity mean? Is `first.identifier == second.identifier` enough?
    * Pro: Allows detection of match data changes via separate function, e.g. to animate list
    * Con: Breaks the concept of value-type identity, if two match structs differ only in data

Acknowledgements
----------------

This project is kindly sponsored by [Futurice][futurice] as part of its fantastic [open-source program][spice-program]. Kiitos!

The icons within the app are courtesy of [Icons8][icons8] – a resource well worth checking out.

[futurice]: http://futurice.com/
[spice-program]: http://www.spiceprogram.org/
[icons8]: https://icons8.com/
