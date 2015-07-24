# SwiftGoal

This project was inspired on a theoretical level by Justin Spahr-Summers' talk Enemy of the State, and on a more practical one by Ash Furrow's C-41 app. It showcases the Model-View-ViewModel (MVVM) architecture while serving as a digital logbook of [FIFA matches][fifa-wikipedia].

[fifa-wikipedia]: https://en.wikipedia.org/wiki/FIFA_(video_game_series)

As the Swift language and the ecosystem around it [matured][reactive-cocoa-releases], porting the original [ObjectiveGoal][objective-goal] project became a natural next step, as Swift's type safety makes it a perfect fit for functional reactive programming.

[reactive-cocoa-releases]: https://github.com/ReactiveCocoa/ReactiveCocoa/releases
[objective-goal]: https://github.com/richeterre/ObjectiveGoal

## Setup

The application uses Goalbase as a backend to store, process and retrieve information. It assumes you have a Goalbase instance running at `http://localhost:3000`, which is the default URL of the WEBrick server that ships with Rails. Please check out the [Goalbase documentation][goalbase-docs] for more detailed instructions.

[goalbase-docs]: https://github.com/richeterre/goalbase/blob/master/README.md

If you want to provide your own backend, simply change the base URL path in `Store.swift`.

## User Features

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

## Code Checklist

* [x] Validate player name before creating
* [x] Validate match player counts before creating
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

## Open Issues

* What does match identity mean? Is `first.identifier == second.identifier` enough?
    * Pro: Allows detection of match data changes via separate function, e.g. to animate list
    * Con: Breaks the concept of value-type identity, if two match structs differ only in data

## Acknowledgements

This project is kindly sponsored by [Futurice][futurice] as part of its fantastic [open-source program][spice-program]. Kiitos!

The icons within the app are courtesy of [Icons8][icons8] – a resource well worth checking out.

[futurice]: http://futurice.com/
[spice-program]: http://www.spiceprogram.org/
[icons8]: https://icons8.com/
