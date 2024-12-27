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
     This is a utility function, for extracting discrete date steps from a date range. The step size will always be 1 day, and the dates will always be at 00:00:00 (Midnight AM).
     
     - parameter numberOfValues: This is an optional (default is 6) integer, with the number of date steps we want. This is an arbitrary number, and will be used to determine the number of full days, between steps, but is not days, in itself.
     - parameter for: The closed date range we want. The returned dates will be the start of day for the first date in the range, up to the start of day for the last date (may not include the last date, if the days can't be evenly divided).
     */
    private static func _xAxisDateValues(numberOfValues inNumberOfValues: Int = 6, for inDateRange: ClosedRange<Date>?) -> [Date] {
        guard let inDateRange = inDateRange,
              let numberOfDays = Calendar.current.dateComponents([.day], from: inDateRange.lowerBound, to: inDateRange.upperBound).day,
              0 < numberOfDays,
              0 < inNumberOfValues
        else { return [] }
        
        var dates = [Date]()    // We start by filling an array of dates, with each day in the range.

        // We use the calendar to calculate the dates, because it will account for things like DST and leap years.
        Calendar.current.enumerateDates(startingAfter: inDateRange.lowerBound.addingTimeInterval(-86399),   // We start the day before.
                                        matching: DateComponents(hour: 0, minute: 0, second:0),
                                        matchingPolicy: .nextTime) { (date, _, stop) in
            guard let date = date,
                  date <= inDateRange.upperBound.addingTimeInterval(86399)  // We stop at the end of the last day.
            else {
                stop = true // This causes the iteration to stop.
                return
            }

            dates.append(date.addingTimeInterval(43200))    // We return noon, of each day. This ensures the bars center.
        }
        
        // We now filter out just the ones we want, to satisfy the count request.
        var ret = [Date]()
        let strideCount = numberOfDays / (inNumberOfValues - 1)
        for index in stride(from: 0, to: dates.count, by: strideCount) { ret.append(dates[index]) }
        return ret
    }

    /* ##################################################### */
    /**
     (Stored Property) This is the actual data that we'll be providing to the chart.
     */
    @State var data = DataProvider()
    
    /* ##################################################### */
    /**
     (Computed Property) The date range of our complete list of values.
     
     If not able to compute, nil is returned.
     */
    var totalDateRange: ClosedRange<Date>? {
        guard let lowerBound = data.rows.first?.sampleDate,
              let upperBound = data.rows.last?.sampleDate
        else { return nil }
        
        return Calendar.current.startOfDay(for: lowerBound) ... Calendar.current.startOfDay(for: upperBound)
    }
    
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
        // This is covered in more detail in [the SwiftUI documentation](https://developer.apple.com/documentation/charts/customizing-axes-in-swift-charts).
        // This moves the Y-axis labels over to the leading edge, and displays them, so that their trailing edges are against the chart edge (so they don't overlap the chart).
        // Default, is for the Y-axis to display against the trailing edge, with the values displayed with their leading edge against the chart's trailing edge.
        .chartYAxis {
            // This cycles through all of the value labels on the Y-axis, giving each level of the Y-axis a chance to strut its stuff.
            // The closure parameter is an instance of [`AxisValue`](https://developer.apple.com/documentation/charts/axisvalue), representing the Y-axis value. We ignore this.
            AxisMarks(preset: .aligned, position: .leading) { _ in
                AxisTick()                          // This adds a short "tick" between the value label and the leading edge of the chart. Default is about 4 display units, solid thin line.
                AxisGridLine()                      // This draws a gridline, horizontally across the chart, from the leading edge of the chart, to the trailing edge. Default is a solid thin line.
                AxisValueLabel(anchor: .trailing)   // This draws the value for this Y-axis level, as a label. It is set to anchor its trailing edge to the axis tick.
            }
        }
        // This moves the X-axis labels down, and centers them on the tick marks. It also sets up a range of values to display.
        .chartXAxis {
            AxisMarks(preset: .aligned, position: .bottom, values: Self._xAxisDateValues(for: totalDateRange)) { inValue in
                AxisTick(stroke: StrokeStyle()) // This adds a short "tick" between the value label and the leading edge of the chart. Adding the `stroke` parameter, with a default `StrokeStyle` instance, makes it a solid (as opposed to dashed) line.
                AxisGridLine()                  // This draws a gridline, vertically down the chart, from the top of the chart, to the bottom. Default is a thin, dashed line.
                if let dateString = inValue.as(Date.self)?.formatted(Date.FormatStyle().month(.abbreviated).day(.twoDigits)) {  // Fetch the date as a formatted string.
                    AxisValueLabel(dateString, anchor: .top)  // This draws the value for this X-axis date, as a label. It is set to anchor its top to the axis tick.
                }
            }
        }
    }
}
