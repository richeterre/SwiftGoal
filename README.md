# SwiftGoal

This project was inspired on a theoretical level by Justin Spahr-Summers' talk Enemy of the State, and on a more practical one by Ash Furrow's C-41 app. It showcases the Model-View-ViewModel (MVVM) architecture while serving as a digital logbook of [FIFA matches][fifa-wikipedia].

[fifa-wikipedia]: https://en.wikipedia.org/wiki/FIFA_(video_game_series)

As the Swift language and the ecosystem around it matured, porting the original [ObjectiveGoal][objective-goal] project became a natural next step, as Swift's type safety makes it a perfect fit for functional reactive programming.

[objective-goal]: https://github.com/richeterre/ObjectiveGoal

## Setup

The application uses Goalbase as a backend to store, process and retrieve information. It assumes you have a Goalbase instance running at `http://localhost:3000`, which is the default URL of the WEBrick server that ships with Rails. Please check out the [Goalbase documentation][goalbase-docs] for more detailed instructions.

[goalbase-docs]: https://github.com/richeterre/goalbase/blob/master/README.md

If you want to provide your own backend, simply change the base URL path in `Store.swift`.

## Todo

* Handle network errors
* Allow deletion of players (and their dependent matches)
* Cancel network requests when the view model that started them becomes inactive
* Write tests for VMs, models and Store
* Deduplicate `isActiveSignal` code on VCs, probably using Swift 2's protocol extensions?

## Acknowledgements

This project is kindly sponsored by [Futurice][futurice] as part of its fantastic [open-source program][spice-program]. Kiitos!

[futurice]: http://futurice.com/
[spice-program]: http://www.spiceprogram.org/
