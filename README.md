SwiftGoal
=========

[![Sponsored](https://img.shields.io/badge/chilicorn-sponsored-brightgreen.svg)](http://spiceprogram.org/oss-sponsorship/)

This project showcases the Model-View-ViewModel (MVVM) architecture with [ReactiveCocoa 4][reactive-cocoa], while serving as a digital logbook of [FIFA matches][fifa-wikipedia]. It was inspired on a theoretical level by Justin Spahr-Summers' talk [Enemy of the State][enemy-of-the-state], and on a more practical one by Ash Furrow's [C-41][c-41] app.

[reactive-cocoa]: https://github.com/ReactiveCocoa/ReactiveCocoa
[fifa-wikipedia]: https://en.wikipedia.org/wiki/FIFA_(video_game_series)
[enemy-of-the-state]: https://github.com/jspahrsummers/enemy-of-the-state
[c-41]: https://github.com/ashfurrow/C-41

As the Swift language and the ecosystem around it [matured][reactive-cocoa-releases], porting the original [ObjectiveGoal][objective-goal] project became a natural next step, as Swift's type safety makes it a perfect fit for functional reactive programming.

[reactive-cocoa-releases]: https://github.com/ReactiveCocoa/ReactiveCocoa/releases
[objective-goal]: https://github.com/richeterre/ObjectiveGoal

Requirements
------------

SwiftGoal runs on iOS 9+ and requires Xcode 8 with Swift 2.3 to build.

Setup
-----

No separate backend is required to use the app, as it stores all its data locally in the `Documents` directory by default. Note that things might break in future releases, e.g. if some model fields change! Also, you need to _terminate_ the app to trigger a write to local storage.

For serious use and if you want to share data across multiple devices, I recommend you use [Goalbase][goalbase] as a backend. It's easy to get started:

1. Follow the setup instructions in the [Goalbase documentation][goalbase-docs].
2. Enable the "Use Remote Store" switch under _Settings > SwiftGoal_.
3. Make sure the base URL is set correctly. The default value should be fine if you run `rails server` in your Goalbase directory, but for a remote setup (e.g. on Heroku) you'll need to update this setting.

[goalbase]: https://github.com/richeterre/goalbase
[goalbase-docs]: https://github.com/richeterre/goalbase/blob/master/README.md

Unit Tests
----------

SwiftGoal is thoroughly covered by unit tests, which are written with [Quick][quick] and [Nimble][nimble]. An advantage of such [BDD-style][bdd-wikipedia] frameworks is that they document the behavior of the tested code in plain English. To run the unit tests, simply hit `Cmd + U` in Xcode.

[quick]: https://github.com/Quick/Quick
[nimble]: https://github.com/Quick/Nimble
[bdd-wikipedia]: https://en.wikipedia.org/wiki/Behavior-driven_development

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
* [x] View player rankings
* [ ] Switch between different ranking periods (last month, all time, …)
* [ ] See date and time of each match
* [ ] See matches grouped by date range (e.g. last week, last month, earlier)
* [ ] View more player statistics (e.g. won/drawn/lost count, nemesis player, …)

Code Checklist
--------------

* [x] Validate player name before creating
* [x] Validate match player counts before creating
* [x] Move base URL to Settings for easy customization
* [ ] Cancel network requests when the associated view becomes inactive
* [ ] Retry network requests 1 or 2 times before giving up
* [x] Detect and animate match data changes
* [x] Write tests for models
* [x] Write tests for view models
* [ ] Write tests for helpers and store
* [x] Deduplicate `isActiveSignal` code on view controllers (via a class extension)
* [ ] Create watchOS 2 app for quick match entry

[snapkit]: https://github.com/SnapKit/SnapKit

Benefits of MVVM
----------------

__High testability:__ The basic premise of testing is to verify correct output for a given input. As a consequence, any class that minimizes the amount of dependencies affecting its output becomes a good candidate for testing. MVVM's separation of logic (the view model layer) from presentation (the view layer) means that the view model can be tested with minimal setup. For instance, injecting a mock `Store` that provides a known amount of `Match` instances is enough to verify that the `MatchesViewModel` reports the correct amount of matches. The view layer becomes trivial, as it simply binds to those outputs.

__Better separation of concerns:__ `UIViewController` and its friends have been rightfully [scorned][mvc-tweet] for handling far too many things, from interface rotation to networking to providing table data. MVVM solves this by making a clear cut between UI and business logic. While a view controller would still acts as its table view's data source, it forwards the actual data queries to its own view model. Presentation details, such as animating new rows into the table view, will be handled in the view layer.

__Encapsulation of state:__ As suggested by Gary Bernhardt in his famous talk [“Boundaries”][boundaries-talk], view models offer a stateful shell around the stateless core of the app, the model layer. If need be, the app's state can be persisted and restored simply by storing the view model. While the view may be extremely stateful too, its state is ultimately derived from that of the view model, and thus does not require to be stored.

[mvc-tweet]: https://twitter.com/colin_campbell/status/293167951132098560
[boundaries-talk]: https://www.destroyallsoftware.com/talks/boundaries

Acknowledgements
----------------

This project is kindly sponsored by [Futurice][futurice] as part of their fantastic [open-source program][spice-program]. Kiitos!

The icons within the app are courtesy of [Icons8][icons8] – a resource well worth checking out.

[futurice]: http://futurice.com/
[spice-program]: http://www.spiceprogram.org/
[icons8]: https://icons8.com/
