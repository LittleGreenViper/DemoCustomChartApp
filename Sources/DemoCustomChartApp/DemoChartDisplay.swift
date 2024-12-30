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
    // MARK: Private Properties
    
    // MARK: - PART 4A - Tap/Swipe to Select (State Properties) -

    /* ################################################################## */
    /**
     The string that displays the data for the selected bar.
     
     This is attached to the text item that we added for the drag gesture.
     */
    @State private var _selectedValuesString: String = " "  // It needs to always be filled with something, so it doesn't vertically collapse (making the chart jump).

    /* ################################################################## */
    /**
     The value being selected by the user, while dragging.
     
     Setting this, changes the text that is displayed in the text item at the top, and also selects/deselects the row, in the model.
     */
    @State private var _selectedValue: DataProvider.Row? {
        didSet {
            if let selectedValue = _selectedValue,
               1 < selectedValue.userTypes.count {
                data.selectRow(selectedValue)
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                _selectedValuesString = String(format: "%@: Active: %d, New: %d, Total: %d",
                                               dateFormatter.string(from: selectedValue.sampleDate),
                                               selectedValue.userTypes[0].value,
                                               selectedValue.userTypes[1].value,
                                               selectedValue.userTypes[0].value + selectedValue.userTypes[1].value
                )
            } else {
                _selectedValuesString = " "
                data.deselectAllRows()
            }
        }
    }

    /* ################################################################## */
    /**
     This contains the data window, at the start of the gesture.
     */
    @State private var _firstRange: ClosedRange<Date>?

    /* ##################################################### */
    /**
     (Stored Property) This is the actual data that we'll be providing to the chart.
     
     It's somewhat mutable (we can set observational state, like marking rows as selected, or setting a "window" of dates to examine).
     */
    @State var data = DataProvider()
    
    /* ##################################################### */
    /**
     (Computed Property) The main chart view. It is a simple bar chart, with each bar, segregated vertically, by user type.
     */
    var body: some View {
        // MARK: - PART 4B - Tap/Swipe to Select (VStack and Text Item) -
        
        // We need to add a `VStack`, so that the text item and chart play well together.
        VStack {
            // This displays the value of the selected bar. It is one line of red text, so we make it small enough to fit.
            Text(_selectedValuesString)
                .font(.system(size: 14))
                .foregroundStyle(data.legend.last?.value ?? .yellow)    // If it's yeller, we gots problems.

            // MARK: - PART 0 - The Chart, Itself -
            
            // This builds bars. The date determines the X-axis, and the Y-axis has the number of each type of user, stacked.
            Chart(data.windowedRows) { inRow in // Note that we use the `windowedRows` computed property. This comes into play, when we implement pinch-to-zoom.
                                                // Each bar is comprised of two sections, which are built, here. `userTypes` returns an array of `UserType` enum instances.
                                                // The order of the components in the array determines which will be above the other. Previous is under next.
                ForEach(inRow.userTypes) { inUserType in
                    BarMark(
                        x: .value("Date", inRow.sampleDate, unit: .day),    // The date is the same, for each component. Each bar represents one day.
                        y: .value(inUserType.description, inUserType.value) // The components "stack," with subsequent ones being placed above previous ones.
                    )
                    // Each bar component gets a color, assigned by the enum.
                    .foregroundStyle(inUserType.color)
                }
            }
            
            // MARK: - PART 1 - Chart Legend -
            
            // This displays the "legend," under the chart, indicating what color indicates what user type.
            .chartForegroundStyleScale(data.legend)
            
            // The following adornments are covered in more detail in [the SwiftUI documentation](https://developer.apple.com/documentation/charts/customizing-axes-in-swift-charts).
            
            // MARK: - PART 2 - Y-Axis Customization -
            
            // This moves the Y-axis labels over to the leading edge, and displays them, so that their trailing edges are against the chart edge (so they don't overlap the chart).
            // Default, is for the Y-axis to display against the trailing edge, with the values displayed with their leading edge against the chart's trailing edge.
            .chartYAxis {
                // This cycles through all of the value labels on the Y-axis, giving each level of the Y-axis a chance to strut its stuff.
                // The closure parameter is an instance of [`AxisValue`](https://developer.apple.com/documentation/charts/axisvalue), representing the Y-axis value. We ignore this.
                AxisMarks(preset: .aligned, position: .leading, values: data.yAxisCountValues()) { _ in  // We use the data provider utility function to give us a bunch of axis steps. We want 4 of them, in this case (default). This also fixes the scale, for pinch-to-zoom.
                    AxisGridLine()                      // This draws a gridline, horizontally across the chart, from the leading edge of the chart, to the trailing edge. Default is a solid thin line.
                    AxisTick()                          // This adds a short "tick" between the value label and the leading edge of the chart. Default is about 4 display units, solid thin line.
                    AxisValueLabel(anchor: .trailing)   // This draws the value for this Y-axis level, as a label. It is set to anchor its trailing edge to the axis tick.
                }
            }
            .chartYAxisLabel("Users")                   // This displays the axis title, above the upper, left corner of the chart, over the Y-axis labels.
            
            // MARK: - PART 3 - X-Axis Customization -
            
            // This moves the X-axis labels down, and centers them on the tick marks. It also sets up a range of values to display, and aligns them with the start of the data range.
            // Default, is for the X-axis to display to the right of the tickmark, and the gridlines seem to radiate from the middle.
            .chartXAxis {
                AxisMarks(preset: .aligned, position: .bottom, values: data.xAxisDateValues()) { inValue in  // We use the data provider utility function to give us a bunch of axis steps. We want 6 of them, in this case (default). It also tells the chart what domain to use.
                    if let dateString = inValue.as(Date.self)?.formatted(Date.FormatStyle().month(.abbreviated).day(.twoDigits)) {  // Fetch the date as a formatted string.
                        AxisGridLine()                              // This draws a gridline, vertically down the chart, from the top of the chart, to the bottom. Default is a thin, dashed line.
                        AxisTick(stroke: StrokeStyle())             // This adds a short "tick" between the value label and the leading edge of the chart. Adding the `stroke` parameter, with a default `StrokeStyle` instance, makes it a solid (as opposed to dashed) line.
                        AxisValueLabel(dateString, anchor: .top)    // This draws the value for this X-axis date, as a label. It is set to anchor its top to the axis tick.
                    }
                }
            }
            .chartXAxisLabel("Date", alignment: .center)            // This displays the axis title, under the center of the X-axis, under its labels.
            
            // MARK: - PART 4C - Tap/Swipe to Select (Drag Gesture) -
            
            // This implements tap/swipe to select.
            // We start, by covering the chart with an overlay.
            .chartOverlay { inChart in              // The chart instance is passed in.
                GeometryReader { inGeom in          // We need to know the dimensions of the overlay.
                    Rectangle()                     // The overlay will be a rectangle
                        .fill(Color.clear)          // It is filled with clear, so we can see the chart through it.
                        .contentShape(Rectangle())  // We need to explicitly give it a shape.
                        // This is the gesture context that is attached to the overlay.
                        .gesture(
                            // This is the actual gesture that tracks our tap/drag. We will only be paying attention to horizontal dragging (X-axis).
                            DragGesture(minimumDistance: 0)             // It's a drag gesture, but specifying a `minimumDistance` of 0, makes it a tap/drag gesture.
                                // This is where the magic happens. This closure is called, whenever the gesture moves.
                                .onChanged { inValue in                 // `inValue` contains the current gesture state.
                                    if let frame = inChart.plotFrame {  // We need the chart's frame, as we'll be figuring out our X-axis value, based on that.
                                        // We query the chart for the X-axis value, corresponding to the local position, given by the gesture value. We clip the gesture, to within the chart dimensions.
                                        guard let date = inChart.value(atX: max(0, min(inChart.plotSize.width, inValue.location.x - inGeom[frame].origin.x)), as: Date.self) else { return }
                                        _selectedValue = data.windowedRows.nearestTo(date)
                                    }
                                }
                                .onEnded { _ in _selectedValue = nil }
                        )
                        .gesture(
                            MagnifyGesture()
                                .onChanged { inValue in
                                    data.deselectAllRows()
                                    
                                    _firstRange = _firstRange ?? data.dataWindowRange

                                    guard let firstRange = _firstRange else { return }
                                    
                                    let rangeInSeconds = (firstRange.upperBound.timeIntervalSinceReferenceDate - firstRange.lowerBound.timeIntervalSinceReferenceDate) / 2
                                    let centerDateInSeconds = (TimeInterval(inValue.startAnchor.x) * (rangeInSeconds * 2)) + firstRange.lowerBound.timeIntervalSinceReferenceDate
                                    let centerDate = Calendar.current.startOfDay(for: Date(timeIntervalSinceReferenceDate: centerDateInSeconds)).addingTimeInterval(43200)
                                    
                                    // No less than 2 days.
                                    let newRange = max((86400 * 2), (rangeInSeconds * 1.2) / inValue.magnification)
                                    
                                    data.dataWindowRange = (centerDate.addingTimeInterval(-newRange)...centerDate.addingTimeInterval(newRange)).clamped(to: data.totalDateRange)
                                }
                                .onEnded { _ in _firstRange = nil }
                        )

                }
            }
        }
    }
}
