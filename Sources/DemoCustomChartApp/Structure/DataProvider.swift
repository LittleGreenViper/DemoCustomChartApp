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

import SwiftUI        // For ``Color``
import TabularData    // For ``DataFrame``

/* ######################################################### */
// MARK: - App Data Provider -
/* ######################################################### */
/**
 This is a simple struct that acts as a data provider to the rest of the app.
 
 It has dummy data, taken from an aggregated dump of a shipping app.
 
 > NOTE: This is not meant to be a demonstration of efficient data handling. It's a small dataset, and this just makes it easy to access.
 */
public struct DataProvider {
    // MARK: Private Property
    
    /* ##################################################### */
    /**
     The data that we will supply to the rest of the app, as a string of CSV data.
     
     This is a representation of users registered with an app.
     
     - LEGEND (All values are positive Int):
     - sample_date: The date this sample was taken, as a Unix Epoch Time (seconds since 1970-01-01 00:00:00)
     - total_users: The total number of registered users
     - new_users: The number of users (included in `total_users`) that are "new" (have not completed their first sign-in).
     */
    private static let _dummyChartDataCSV = """
sample_date,total_users,new_users
1729008013,660,47
1729094406,667,53
1729180807,672,55
1729267207,677,56
1729353606,681,55
1729440009,683,55
1729526409,685,57
1729612810,684,55
1729699210,684,54
1729785608,688,55
1729872008,692,57
1729958408,693,55
1730044812,694,55
1730131207,695,56
1730217607,700,59
1730304007,702,56
1730390408,699,52
1730476810,701,53
1730563209,704,54
1730653207,713,60
1730739609,719,63
1730826009,718,60
1730912407,723,63
1730998809,726,66
1731085209,730,68
1731171609,729,65
1731258010,740,69
1731344410,750,77
1731430808,752,75
1731517208,756,75
1731603608,759,77
1731690008,761,77
1731776407,763,76
1731862807,762,70
1731949210,761,67
1732035609,766,67
1732122008,763,64
1732208410,769,66
1732294807,769,63
1732381207,777,65
1732467608,781,68
1732554010,782,67
1732640409,780,64
1732726808,780,62
1732813209,783,62
1732899609,784,62
1732986007,784,61
1733072411,788,65
1733158813,793,67
1733245208,782,57
1733331607,785,57
1733418008,788,60
1733504410,791,61
1733590810,792,58
1733677208,796,57
1733763609,793,52
1733850006,796,52
1733936408,798,52
1734022808,802,55
1734109208,807,58
1734195607,810,55
1734282007,815,56
1734368409,817,57
1734454808,819,59
1734541205,823,56
1734627605,823,55
1734714007,828,57
1734800408,832,59
1734886807,840,63
1734973207,841,62
1735059608,842,63
"""
    
    /* ################################################# */
    /**
     (Stored Property) This contains an explicit sub-range of the entire data X-axis range. Default is the entire range.
     */
    private var _dataWindowRange: ClosedRange<Date> = .distantPast ... .distantPast

    // MARK: - Public API -
    
    /* ##################################################### */
    /**
     One element of the legend. A simple tuple.
     
     - parameter description: A textual name for the legend element. This must be unique (`Hashable`).
     - parameter color: The color to assign to that legend element.
     */
    public typealias LegendElement = (description: String, color: Color)
    
    /* ##################################################### */
    // MARK: One Row Of Data
    /* ##################################################### */
    /**
     This interprets the untyped DataFrame Row data into data that we find useful.
     */
    public struct Row: Identifiable, Equatable {
        /* ################################################# */
        // MARK: Plottable User Type Data Struct
        /* ################################################# */
        /**
         This allows us to represent the user type data in a plottable form.
         */
        public struct PlottableUserTypes: Identifiable {
            /* ############################################# */
            // MARK: File Private Data Type Enums
            /* ############################################# */
            /**
             This is used to indicate the type of user.
             */
            fileprivate enum _UserTypes {
                /* ######################################### */
                /**
                 The total number of "new" users (users that have never logged in).
                 */
                case newUsers(isSelected: Bool, numberOfNewUsers: Int)
                
                /* ######################################### */
                /**
                 The total number of "active" users (users that have logged in, at least once).
                 */
                case activeUsers(isSelected: Bool, numberOfActiveUsers: Int)
                
                /* ######################################### */
                /**
                 (Computed Property) Returns a string we can use for UI. This must be unique (`Hashable`).
                 */
                var description: String {
                    switch self {
                    case .activeUsers:
                        return "Active Users"
                    case .newUsers:
                        return "New Users"
                    }
                }
                
                /* ######################################### */
                /**
                 (Computed Property) Returns a color to use for The bar element.
                 */
                var color: Color {
                    switch self {
                    case .activeUsers:
                        return .green
                    case .newUsers:
                        return .blue
                    }
                }
                
                /* ######################################### */
                /**
                 (Computed Property) Returns the associated value.
                 */
                var value: Int {
                    switch self {
                    case let .activeUsers(_, inUsers):
                        return inUsers
                    case let .newUsers(_, inUsers):
                        return inUsers
                    }
                }
                
                /* ######################################### */
                /**
                 (Computed Property) Returns true, if the row is currently selected.
                 */
                var isSelected: Bool {
                    switch self {
                    case let .activeUsers(inIsSelected, _):
                        return inIsSelected
                    case let .newUsers(inIsSelected, _):
                        return inIsSelected
                    }
                }
            }
            
            // MARK: Private Property
            
            /* ############################################# */
            /**
             (Stored Property) This defines the user type this data is representing.
             */
            fileprivate let _userType: _UserTypes
            
            // MARK: Public API
            
            /* ############################################# */
            /**
             (Static) The text to use, for a selected row.
             */
            public static let selectedDescription: String = "Selected"
            
            /* ############################################# */
            /**
             (Static) The color to use, for a selected row.
             */
            public static let selectedColor: Color = .red

            /* ############################################# */
            /**
             (Stored Property) Make me identifiable.
             */
            public let id = UUID()

            /* ############################################# */
            /**
             (Computed Property) True, if this row is selected.
             */
            public var isSelected: Bool { _userType.isSelected }

            /* ######################################### */
            /**
             (Computed Property) Returns a string we can use for UI. This must be unique (`Hashable`).
             */
            var description: String { _userType.description }
            
            /* ######################################### */
            /**
             (Computed Property) Returns a color to use for The bar element. If selected, then we return red.
             */
            var color: Color { isSelected ? Self.selectedColor : _userType.color }
            
            /* ######################################### */
            /**
             (Computed Property) Returns the associated value.
             */
            var value: Int { _userType.value }
        }
        
        // MARK: Private Property
        
        /* ################################################# */
        /**
         (Stored Property) The untyped `DataFrame.Row` instance assigned to this struct instance.
         */
        private var _dataRow: DataFrame.Row

        /* ################################################# */
        /**
         (Computed Property) The total number of users (private, to simplify).
         */
        private var _totalUsers: Int { _dataRow["total_users"] as? Int ?? 0 }
        
        /* ################################################# */
        /**
         (Computed Property) The total number of "new" users (users that have never logged in).
         */
        private var _newUsers: Int { _dataRow["new_users"] as? Int ?? 0 }
        
        /* ################################################# */
        /**
         (Computed Property) The total number of "active" users (users that have logged in, at least once).
         */
        private var _activeUsers: Int { _totalUsers - _newUsers }
        
        /* ################################################# */
        /**
         (File private Computed Property) The total number of users (both types).
         */
        fileprivate var _rowTotalUsers: Int { _totalUsers }

        /* ################################################# */
        /**
         File private initializer
         
         - parameter dataRow: The `DataFrame.Row` for the line we're saving.
         */
        fileprivate init(dataRow inDataRow: DataFrame.Row) {
            _dataRow = inDataRow
        }

        // MARK: Public API
        
        /* ################################################# */
        /**
         (Stored Property) Make me identifiable.
         */
        public let id = UUID()

        /* ############################################# */
        /**
         (Stored Property) True, if this row is selected.
         */
        public var isSelected = false

        /* ################################################# */
        /**
         (Computed Property) The date the sample was taken. `.distantFuture` is returned, if there is an error.
         */
        public var sampleDate: Date { _dataRow["sample_date"] as? Date ?? .distantFuture }

        /* ################################################# */
        /**
         (Computed Property) This returns the row data in one set of plottable data points.
         
         Active users are in the first element, and new users in the second.
         */
        public var userTypes: [PlottableUserTypes] {
            [
                PlottableUserTypes(_userType: .activeUsers(isSelected: isSelected, numberOfActiveUsers: _activeUsers)),
                PlottableUserTypes(_userType: .newUsers(isSelected: isSelected, numberOfNewUsers: _newUsers))
            ]
        }
        
        /* ################################################# */
        /**
         Equatable Conformance. We base this on the sample date.
         
         - parameter lhs: The left-hand side of the comparison.
         - parameter rhs: The right-hand side of the comparison.
         */
        public static func == (lhs: Row, rhs: Row) -> Bool { lhs.sampleDate == rhs.sampleDate }
    }
    
    /* ##################################################### */
    /**
     (Stored Property) This provides the data frame rows as an array of our own ``Row`` struct.
     */
    public var rows: [Row]

    /* ##################################################### */
    /**
     Public Default initializer
     
     It just loads the DataFrame with the dummy data.
     */
    public init() {
        /* ################################################# */
        /**
         Converts the dummy CSV data to a `DataFrame`. Nil, if there was an error.
         */
        func convertCSVData() -> DataFrame? {
            if let data = Self._dummyChartDataCSV.data(using: .utf8),
               var dataFrame = try? DataFrame(csvData: data) {
                // We convert the integer timestamp to a more usable Date instance.
                dataFrame.transformColumn("sample_date") { (inUnixTime: Int) -> Date in Date(timeIntervalSince1970: TimeInterval(inUnixTime)) }
                return dataFrame
            } else {
                return nil
            }
        }
        
        rows = convertCSVData()?.rows.map { Row(dataRow: $0) } ?? []
        
        if let lowerBound = rows.first?.sampleDate,
           let upperBound = rows.last?.sampleDate {
            _dataWindowRange = Calendar.current.startOfDay(for: lowerBound) ... Calendar.current.startOfDay(for: upperBound)
        }
    }
}

/* ######################################################### */
// MARK: Computed Properties
/* ######################################################### */
public extension DataProvider {
    /* ##################################################### */
    /**
     (Computed Property) This provides the data frame rows as an array of our own ``Row`` struct, but filtered for the window date range.
     */
    var windowedRows: [Row] { rows.filter { dataWindowRange.contains(Calendar.current.startOfDay(for: $0.sampleDate)) } }
    
    /* ##################################################### */
    /**
     (Computed Property) This provides a row that is currently selected. Nil, if no row selected.
     
     > NOTE: This may return rows not in the window.
     */
    var selectedRow: Row? { rows.first(where: { $0.isSelected }) }

    /* ##################################################### */
    /**
     (Computed Property) The date range of our complete list of values.
     
     If not able to compute, an empty (distant past) range is returned.
     */
    var totalDateRange: ClosedRange<Date> {
        guard let lowerBound = rows.first?.sampleDate,
              let upperBound = rows.last?.sampleDate
        else { return .distantPast ... .distantPast }
        
        return Calendar.current.startOfDay(for: lowerBound) ... Calendar.current.startOfDay(for: upperBound)
    }
    
    /* ################################################# */
    /**
     (Computed Property) This contains an explicit sub-range of the entire data X-axis range. If in error, an empty range is returned. Default means use ``totalDateRange``.
     */
    var dataWindowRange: ClosedRange<Date> {
        get {
            guard !_dataWindowRange.isEmpty,
                  !totalDateRange.isEmpty
            else { return totalDateRange }
            
            return _dataWindowRange.clamped(to: totalDateRange)
        }
        
        set {
            guard !newValue.isEmpty
            else {
                _dataWindowRange = totalDateRange
                return
            }
            _dataWindowRange = newValue.clamped(to: totalDateRange)
        }
    }

    /* ##################################################### */
    /**
     (Computed Property) This provides a legend for the chart.
     
     The order of elements is first -> left (active users), last -> right (new users).
     */
    var legend: KeyValuePairs<String, Color> {
        KeyValuePairs<String, Color>(dictionaryLiteral: (description: Row.PlottableUserTypes._UserTypes.activeUsers(isSelected: false, numberOfActiveUsers: 0).description,
                                                         color: Row.PlottableUserTypes._UserTypes.activeUsers(isSelected: false, numberOfActiveUsers: 0).color),
                                                        (description: Row.PlottableUserTypes._UserTypes.newUsers(isSelected: false, numberOfNewUsers: 0).description,
                                                         color: Row.PlottableUserTypes._UserTypes.newUsers(isSelected: false, numberOfNewUsers: 0).color),
                                                        (description: Row.PlottableUserTypes.selectedDescription,
                                                         color: Row.PlottableUserTypes.selectedColor)
        )
    }
    
    /* ##################################################### */
    /**
     (Computed Property) This is the maximum of users.
     */
    var maxUsers: Int { rows.reduce(0) { max($0, $1._rowTotalUsers) } }
}

/* ######################################################### */
// MARK: Utility Functions
/* ######################################################### */
public extension DataProvider {
    /* ##################################################### */
    /**
     This is a utility function, for extracting discrete user count steps from a user maximum value range. It will "pad" the gridlines to round numbers, depending on the level of the maximum value.
     
     The result will ensure that we have a top value, and a bottom value, with discrete, padded steps, in nice, round numbers, in between.
     
     - parameter numberOfValues: This is an optional (default is 4) integer, with the number of gridline steps we want. This is an arbitrary number, and will be used to determine the number of counts, between steps.
     
     - returns: An array of `Int`s, each representing one step in the Y-array values. There will be a maximum of `numberOfValues` steps, but there could be less.
     */
    func yAxisCountValues(numberOfValues inNumberOfValues: Int = 4) -> [Int] {
        guard 1 < inNumberOfValues,
              0 < maxUsers
        else { return [] }
        
        // This will be used for the "round up" operation. Crude, but sufficient for our needs.
        let divisor = 100
        
        let stepSizeStart = Int(ceil(Double(maxUsers) / Double(inNumberOfValues - 1)))  // We start, by getting the maximum step size necessary to reach the maximum users.
        
        let stepSize = ((stepSizeStart / divisor) + 1) * divisor    // We then, pad that, so we get nice, even numbers.
        
        let finalValue = inNumberOfValues * stepSize    // The maximum value, if we go all the way.
        
        var ret = [Int]()
        
        for value in stride(from: 0, to: finalValue, by: stepSize) { ret.append(value) }
        
        return ret
    }
    
    /* ##################################################### */
    /**
     This is a utility function, for extracting discrete date steps from a date range. The step size will always be 1 day, and the returned dates will always be at 12:00:00 (Noon).
     
     - parameter numberOfValues: This is an optional (default is 6) integer, with the number of date steps we want. This is an arbitrary number, and will be used to determine the number of full days, between steps, but is not days, in itself.
     
     - returns: An array of `Date` instances, each representing one day. Each date will be at noon. There will be a maximum of `numberOfValues` dates, but there could be less.
     */
    func xAxisDateValues(numberOfValues inNumberOfValues: Int = 6) -> [Date] {
        guard 1 < inNumberOfValues,
              !dataWindowRange.isEmpty,
              let numberOfDays = Calendar.current.dateComponents([.day], from: dataWindowRange.lowerBound, to: dataWindowRange.upperBound).day,
              0 < numberOfDays
        else { return [] }
        
        var dates = [Date]()    // We start by filling an array of dates, with each day in the range.

        let startingPoint = Calendar.current.startOfDay(for: dataWindowRange.lowerBound)                            // We start at the beginning of the first day.
        let endingPoint = Calendar.current.startOfDay(for: dataWindowRange.upperBound).addingTimeInterval(86400)    // We stop at the end of the last day.
        
        // We use the calendar to calculate the dates, because it will account for things like DST and leap years.
        Calendar.current.enumerateDates(startingAfter: startingPoint,
                                        matching: DateComponents(hour: 12, minute: 0, second:0),                // We return noon, of each day. This ensures the bars center.
                                        matchingPolicy: .nextTime) { inDate, _, inOutStop in
            guard let date = inDate,
                  date < endingPoint
            else {
                inOutStop = true    // This causes the iteration to stop.
                return
            }

            dates.append(date)
        }
        
        // At this point, we have an array with consecutive dates; each, representing a single day, and at noon of that day.
        // We now filter out just the ones we want, to satisfy the count request.
        var ret = [Date]()
        let strideCount = numberOfDays / (inNumberOfValues - 1) // Subtract one, because it's an inclusive total.
        for index in stride(from: 0, to: dates.count, by: strideCount) { ret.append(dates[index]) }
        return ret
    }
}

/* ######################################################### */
// MARK: Mutating Utility Functions
/* ######################################################### */
public extension DataProvider {
    /* ##################################################### */
    /**
     (Mutating Function) This will allow you to set the selection of a row, at the given index.
     
     > NOTE: The index is in terms of ``totalDateRange``.
     
     - parameter inIndex: The 0-based index (in terms of ``totalDateRange``) of the row to be affected.
     - parameter isSelected: Optional (default is true) state for the new selection (set to false, to deselect a row).
     
     - returns: The previous state of the row.
     */
    @discardableResult
    mutating func selectRow(_ inIndex: Int, isSelected inIsSelected: Bool = true) -> Bool {
        precondition((0..<rows.count).contains(inIndex), "Index out of bounds")
        
        let ret = rows[inIndex].isSelected
        
        // If we are selecting a row, we make sure to deselect all others. As Connor MacLeod would say, "There can only be one."
        if inIsSelected {
            for row in rows.enumerated() { rows[row.offset].isSelected = false }
        }
        
        rows[inIndex].isSelected = inIsSelected
        
        return ret
    }
    
    /* ##################################################### */
    /**
     (Mutating Function) This will allow you to set the selection of a a row, given a copy of the row.
     
     - parameter inRow: The row to be selected.
     - parameter isSelected: Optional (default is true) state for the new selection (set to false, to deselect a row).

     - returns: The previous state of the row.
     */
    @discardableResult
    mutating func selectRow(_ inRow: Row, isSelected inIsSelected: Bool = true) -> Bool {
        guard let index = rows.firstIndex(where: { $0 == inRow }) else { return false }
        return selectRow(index, isSelected: inIsSelected)
    }
}

/* ###################################################################################################################################### */
// MARK: - Array Extension For Arrays of Rows -
/* ###################################################################################################################################### */
extension Array where Element == DataProvider.Row {
    /* ################################################################## */
    /**
     This returns the sample closest to the given date.
     
     - parameter inDate: The date we want to compare against.
     
     - returns: The sample that is closest to (above or below) the given date.
     */
    func nearestTo(_ inDate: Date) -> Element? {
        var ret: Element?
        
        forEach {
            let currentDate = $0.sampleDate
            
            guard let compDate = ret?.sampleDate
            else {
                ret = $0
                return
            }
            
            ret = abs(currentDate.timeIntervalSince(inDate)) < abs(compDate.timeIntervalSince(inDate)) ? $0 : ret
        }
        
        return ret
    }
}
