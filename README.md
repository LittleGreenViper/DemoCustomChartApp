![Project Icon](icon.png)

# Demonstration Custom [SwiftUI Chart](https://developer.apple.com/documentation/Charts/Chart)

This project demonstrates simple customizing of [SwiftUI Charts](https://developer.apple.com/documentation/Charts/Chart), by modifying the display, and adding "scrub to select," and "pinch to zoom" functionality.

The idea is to understand how the charts work, and places that we can customize them. The examples will be fairly simple, but every one of these adornments we'll be looking at, will allow a lot more than what we'll be covering, here.

## Chart Data

The chart will display dummy data, from an application that has user accounts. The chart will represent the number of users signed up for the app, with a differentiation between "active" users (users that have signed in, at least once), and "new" users (users that have accounts, but have never signed in). The data is a list of totals, at the end of each day, for 71 days successive.

## Project Structure

The project is set up as a very simple, 1-view SwiftUI app.

We should access the project, by opening [the workspace (`DemoCustomChartApp.xcworkspace`)](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/master/DemoCustomChartApp.xcworkspace) file.

If we do that, the project navigator panel (left side) will look like this (in the [`00.Starting-Point`](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/00.Starting-Point) tag):

| Figure 0: Initial Xcode Navigator Display |
| :-: |
| ![Figure 0](img/Fig-00.png) |

### Support Code

Much of the code is in a subdirectory, labeled [`Sources/DemoCustomChartApp/Structure`](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/master/Sources/DemoCustomChartApp/Structure). This has the files that we won't be looking at.

They consist of:

- [`Sources/DemoCustomChartApp/Structure/DataProvider.swift`](https://github.com/LittleGreenViper/DemoCustomChartApp/blob/master/Sources/DemoCustomChartApp/Structure/DataProvider.swift)
    This is the data provider for the chart data. It is a simple struct that converts some CSV data into a form that can be easily fed to the chart (plottable data).
    
- [`Sources/DemoCustomChartApp/Structure/ContainerApp.swift`](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/master/Sources/DemoCustomChartApp/Structure/ContainerApp.swift)
    This is the actual app and main screen wrapper.
    
- [`Sources/DemoCustomChartApp/Structure/Assets.xcassets`](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/master/Sources/DemoCustomChartApp/Structure/Assets.xcassets)
    This has the graphic assets, such as the accent color and app icon.
    
### Demonstration Code

The code that we will be working with, is in the main project directory, and is called [`Sources/DemoCustomChartApp/DemoChartDisplay.swift`](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/master/Sources/DemoCustomChartApp/DemoChartDisplay.swift).

### The Blog Series

This repo is meant to accompany [a blog series](https://littlegreenviper.com/series/swiftui-charts-gestures/), describing, in detail, how we will add the gestures to a chart.
