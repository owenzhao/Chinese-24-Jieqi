# Chinese 24 Jieqi
## Chinese 24 Solar Terms

This is a Swift package of Chinese 24 solar Terms. The core function was from [js calculate solar terms](https://programmerall.com/article/4491119638/).

A sample project could be found here. [Jieqi](https://github.com/owenzhao/Jieqi/tree/master).

```swift
// get Jieqi at date, if the date was not a Jieqi, get the Jieqis before and after the date.
let result = Jieqi().at(date) -> String

// get previous Jieqi and previous dateComponents at cps.
let (previousJieqi, previousCps) = Jieqi().previousJieqi(at:cps) 

// get next Jieqi and next dateComponents at cps.
let (nextJieqi, nextCps) = Jieqi().nextJieqi(at:cps)

// get season at date.
let season = whichSeason(at:date)
```