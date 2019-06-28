//
//  main.swift
//  XCTestHTMLReport
//
//  Created by Titouan van Belle on 21.07.17.
//  Copyright © 2017 Tito. All rights reserved.
//

import Foundation

var version = "1.7.0"

print("XCTestHTMLReport \(version)")

var command = Command()
var help = BlockArgument("h", "", required: false, helpMessage: "Print usage and available options") {
    print(command.usage)
    exit(EXIT_SUCCESS)
}
var verbose = BlockArgument("v", "", required: false, helpMessage: "Provide additional logs") {
    Logger.verbose = true
}

var shouldIncludeActivitesAndLogs = false
var includeActivitiesAndLogs = BlockArgument("i", "includeActivitiesAndLogs", required: false, helpMessage: "Include or exclude activities and logs") {
    shouldIncludeActivitesAndLogs = true
}

var junitEnabled = false
var junit = BlockArgument("j", "junit", required: false, helpMessage: "Provide JUnit XML output") {
    junitEnabled = true
}
var result = ValueArgument(.path, "r", "resultBundlePath", required: true, allowsMultiple: true, helpMessage: "Path to a result bundle (allows multiple)")

command.arguments = [help, verbose, junit, result, includeActivitiesAndLogs]

if !command.isValid {
    print(command.usage)
    exit(EXIT_FAILURE)
}

let summary = Summary(roots: result.values, shouldIncludeActivitesAndLogs: shouldIncludeActivitesAndLogs)

Logger.step("Building HTML..")
let html = summary.html

do {
    var fileName = ""
    if shouldIncludeActivitesAndLogs {
        fileName = "index"
    } else {
        fileName = "index-short-summary"
    }
    let path = "\(result.values.first!)/\(fileName).html"
    Logger.substep("Writing report to \(path)")

    try html.write(toFile: path, atomically: false, encoding: .utf8)
    Logger.success("\nReport successfully created at \(path)")
}
catch let e {
    Logger.error("An error has occured while creating the report. Error: \(e)")
}

if junitEnabled {
    Logger.step("Building JUnit..")
    let junitXml = summary.junit.xmlString
    do {
        let path = "\(result.values.first!)/report.junit"
        Logger.substep("Writing JUnit report to \(path)")

        try junitXml.write(toFile: path, atomically: false, encoding: .utf8)
        Logger.success("\nJUnit report successfully created at \(path)")
    }
    catch let e {
        Logger.error("An error has occured while creating the JUnit report. Error: \(e)")
    }
}

exit(EXIT_SUCCESS)
