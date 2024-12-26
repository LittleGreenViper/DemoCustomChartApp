![Project Icon](icon.png)

# Demonstration Custom Chart

This project demonstrates simple customizing SwiftUI Charts, by modifying the display, and adding "scrub to select," and "pinch to zoom" functionality.

## Chart Data

The chart will display dummy data, from an application that has user accounts. The chart will represent the number of users signed up for the app, with a differentiation between "active" users (users that have signed in, at least once), and "new" users (users that have accounts, but have never signed in). The data is a list of totals, at the end of each day, for 71 days successive.

## Project Structure

The project is set up as a very simple, 1-view SwiftUI app.

You should access the project, by opening the workspace (`DemoCustomChartApp.xcworkspace`) file.

If you do that, the project navigator panel (left side) will look like this (in the `00.Starting-Point` tag):

| Figure 0: Initial Xcode Navigator Display |
| :-: |
| ![Figure 0](img/Fig-00.png) |

### Support Code

Much of the code is in a subdirectory, labeled [`Sources/DemoCustomChartApp/Structure`](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/master/Sources/DemoCustomChartApp/Structure). This has the files that we won't be looking at.

They consist of:

- [`Sources/DemoCustomChartApp/Structure/ChartData.swift`](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/master/Sources/DemoCustomChartApp/Structure/ChartData.swift)
    This is the data provider for the chart data. It is a simple struct that converts some CSV data into a form that can be easily fed to the chart (plottable data).
    
- [`Sources/DemoCustomChartApp/Structure/ContainerApp.swift`](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/master/Sources/DemoCustomChartApp/Structure/ContainerApp.swift)
    This is the actual app and main screen wrapper.
    
- [`Sources/DemoCustomChartApp/Structure/Assets.xcassets`](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/master/Sources/DemoCustomChartApp/Structure/Assets.xcassets)
    This has the graphic assets, such as the accent color and app icon.
    
### Demonstration Code

The code that we will be working with, is in the main project directory, and is called [`Sources/DemoCustomChartApp/DemoChartDisplay.swift`](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/master/Sources/DemoCustomChartApp/DemoChartDisplay.swift).

## Tags

### [00.Starting-Point](https://github.com/LittleGreenViper/DemoCustomChartApp/releases/tag/00.Starting-Point)

At this point, we have not done any customization. The table is completely default. We have an app that will compile, run, and display a chart, like that, shown in Figure 1:

| Figure 1: Initial Chart Display |
| :-: |
| ![Figure 1](img/Fig-01.png) |

The code in the [`DemoChartDisplay.swift`](https://github.com/LittleGreenViper/DemoCustomChartApp/tree/master/Sources/DemoCustomChartApp/DemoChartDisplay.swift) file, will look like this (comments removed, in order to reduce the code listing size):

#### Listing 1. Basic Bar Chart Display

```swift
import SwiftUI
import Charts

struct DemoChartDisplay: View {
    @State var data = DataProvider()

    var body: some View {
        Chart(data.rows) { inRow in
            ForEach(inRow.userTypes) { inUserType in
                BarMark(
                    x: .value("Date", inRow.sampleDate, unit: .day),
                    y: .value(inUserType.description, inUserType.value)
                )
                .foregroundStyle(inUserType.color)
            }
        }
        .chartForegroundStyleScale(
            [
                data.legend[0].description: data.legend[0].color,
                data.legend[1].description: data.legend[1].color
            ]
        )
    }
}
```

This is the most basic bar chart that you can have, with a "legend" at the bottom (that `chartForegroundStyleScale` adornment, which displays the dots, followed by the names of the user types).

Note that each bar has two colors, with the green color representing the number of "active" users, and the blue color representing the number of "new" users.

The X-axis and Y-axis positions and labels are default.
