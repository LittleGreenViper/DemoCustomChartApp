/*
 © Copyright 2024-2025, Little Green Viper Software Development LLC
 LICENSE:
 
 MIT License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
 modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import SwiftUI
import Charts

/* ######################################################### */
// MARK: - The Actual Chart View -
/* ######################################################### */
/**
 This is the meat of the demonstration.
 
 It's a simple bar chart that displays a set of bars, across 71 days, that represent the total number of users of an app, with "active" ones, and "new" ones, separated by color.
 
 X-axis is date, and Y-axis is a simple, linear, number of users of the system.
 */
struct DemoChartDisplay: View {
    /* ##################################################### */
    /**
     (Stored Property) This is the actual data that we'll be providing to the chart.
     */
    @State var data = DataProvider()

    /* ##################################################### */
    /**
     (Computed Property) The main chart view. It is a simple bar chart, with each bar, segregated vertically, by user type.
     */
    var body: some View {
        // This builds bars. The date determines the X-axis, and the Y-axis has the number of each type of user, stacked.
        Chart(data.rows) { inRow in
            // Each bar is comprised of two sections, which are built, here. `userTypes` returns an array of `UserType` enum instances.
            // The order of the components in the array determines which will be above the other. Previous is under next.
            ForEach(inRow.userTypes) { inUserType in
                BarMark(
                    x: .value("Date", inRow.sampleDate, unit: .day),    // The date is the same, for each component. Each bar represents one day.
                    y: .value(inUserType.description, inUserType.value)
                )
                // Each bar component gets a color, assigned by the enum.
                .foregroundStyle(inUserType.color)
            }
        }
        // This displays the "legend," under the chart, indicating what color indicates what user type.
        .chartForegroundStyleScale(
            [
                data.legend[0].description: data.legend[0].color,
                data.legend[1].description: data.legend[1].color
            ]
        )
    }
}
