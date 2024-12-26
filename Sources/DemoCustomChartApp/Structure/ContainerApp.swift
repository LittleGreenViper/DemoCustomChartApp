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

@main
/* ######################################################### */
// MARK: - Main App -
/* ######################################################### */
/**
 The app is a very simple, one-view app.
 */
struct ContainerApp: App {
    /* ##################################################### */
    /**
     (Computed Property) We have a simple `WindowGroup`, containg the rest of the app.
     */
    var body: some Scene {
        WindowGroup {
            ChartContainer()
        }
    }
}

/* ######################################################### */
// MARK: - Container View For Chart -
/* ######################################################### */
/**
 This simply adds some visual structure to the displayed chart.
 */
struct ChartContainer: View {
    /* ##################################################### */
    /**
     (Computed Property) We wrap the chart in a `GroupBox` (to give it visual structure).
     */
    var body: some View {
        GeometryReader { inGeometry in
            GroupBox("User Types, Over Time") {
                DemoChartDisplay()
                    .padding()
            }
            .padding()
            // We want our box to be square, based on the width of the screen.
            .frame(
                minWidth: inGeometry.size.width,
                maxWidth: inGeometry.size.width,
                minHeight: inGeometry.size.width,
                maxHeight: inGeometry.size.width,
                alignment: .top
            )
        }
    }
}
