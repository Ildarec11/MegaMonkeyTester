//
//  CrashCollectorManager.swift
//  MegaMonkeyTester
//
//  Created by i.arslambekov on 12.11.2023.
//

import Foundation
import CrashReporter

class CrashCollectorManager {

    var crashReporter: PLCrashReporter? = nil

    func enableReporter() {
        let config = PLCrashReporterConfig(signalHandlerType: .mach, symbolicationStrategy: .all)
          guard let reporter = PLCrashReporter(configuration: config) else {
            print("Could not create an instance of PLCrashReporter")
            return
          }
        crashReporter = reporter

          // Enable the Crash Reporter.
          do {
            try reporter.enableAndReturnError()
          } catch let error {
              print("--error \(error)")
          }
    }

    func getCrashErrorReport() -> String? {
        // Try loading the crash report.
        guard let crashReporter else { return nil }
        if crashReporter.hasPendingCrashReport() {
          do {
            let data = try crashReporter.loadPendingCrashReportDataAndReturnError()

            // Retrieving crash reporter data.
            let report = try PLCrashReport(data: data)

            // We could send the report from here, but we'll just print out some debugging info instead.
            if let text = PLCrashReportTextFormatter.stringValue(for: report, with: PLCrashReportTextFormatiOS) {
                crashReporter.purgePendingCrashReport()
                print("-- found crash text: \(text)")
              return text
            } else {
              print("CrashReporter: can't convert report to text")
                return nil
            }
          } catch let error {
            print("CrashReporter failed to load and parse with error: \(error)")
              return nil
          }
        }
        return nil
    }
}
