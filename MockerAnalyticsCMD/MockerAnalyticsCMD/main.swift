//
//  main.swift
//  MockerAnalyticsCMD
//
//  Created by Александр Кравченков on 04.12.2019.
//  Copyright © 2019 SurfStudio. All rights reserved.
//

import Foundation

CommandLine.arguments.append("/Users/aleksandrkravcenkov/mocker_logs.json")

let fileContent = try! String(contentsOfFile: CommandLine.arguments[1])

let splited = fileContent.split(separator: "\n")

let logs = splited.compactMap { (str: String.SubSequence) -> Log? in

    let jsonDecoder = JSONDecoder()
    guard let log = try? jsonDecoder.decode(Log.self, from: str.data(using: .utf8)!) else {
        print(str)
        return nil
    }

    return log
}

let dispatchGroup = DispatchGroup()

dispatchGroup.enter()

DispatchQueue.global(qos: .userInitiated).async {
    print("Всего было запросов на моки: \(logs.filter { $0.event == .getMock }.count)")
    dispatchGroup.leave()
}

dispatchGroup.enter()

DispatchQueue.global(qos: .userInitiated).async {
    let updates = logs.filter { $0.event == .updateModels}
    print("Всего было запросов на обновление: \(updates.count)")

    let results = updates.map { log in
        log.payload.endTime!.date!.timeIntervalSince1970 - log.payload.startTime!.date!.timeIntervalSince1970
    }

    print("Самое быстрое обновление: \(results.min(by: { $0 < $1 })!)")
    print("Самое долгое обновление: \(results.min(by: { $0 > $1 })!)")
    print("В среднем обновление занимает: \(results.reduce(into: 0, { $0 += $1 })/Double(results.count))")
    dispatchGroup.leave()
}

dispatchGroup.enter()

DispatchQueue.global(qos: .userInitiated).async {
    print("Дата первого запроса: \(logs.min(by: { $0.time.date! < $1.time.date! })!.time.date!)")
    print("Дата последнего запроса: \(logs.min(by: { $0.time.date! > $1.time.date! })!.time.date!)")
    dispatchGroup.leave()
}

dispatchGroup.enter()

DispatchQueue.global(qos: .userInitiated).async {

    let error = logs.filter { $0.payload.err != nil}

    print("Всего завершилось с ошибками: \(error.count)")
    print("Типы ошибок: \(Set(error.compactMap { $0.payload.err }))")
    dispatchGroup.leave()
}

dispatchGroup.enter()

DispatchQueue.global(qos: .userInitiated).async {

    var urls = logs.compactMap {
        $0.payload.requestedUrl?.split(separator: "/").first
    }.map { $0.contains("products") ? "sbi" : $0}
    .map { $0.contains("family") ? "sbi" : $0}
    .map { $0.contains("transfer") ? "sbi" : $0}
    .map { $0.contains("user") ? "sbi" : $0}


    urls = urls
        .filter { !$0.contains("-") }
        .filter {!$0.contains("?") }
        .filter {!$0.contains(".") }
        .filter {!$0.contains("products") }
        .filter {!$0.contains("family") }
        .filter {!$0.contains("transfer") }
        .filter {!$0.contains("user") }

    print("Активно используется на: \(Set(urls))")
    print("Иcпользование rendezvous: \(urls.filter { $0 == "rendezvous" }.count)")
    print("Иcпользование rif: \(urls.filter { $0 == "rif" }.count)")
    print("Иcпользование sbi: \(urls.filter { $0 == "sbi" }.count)")
    print("Иcпользование irg: \(urls.filter { $0 == "irg" }.count)")
    dispatchGroup.leave()
}

dispatchGroup.enter()

DispatchQueue.global(qos: .userInitiated).async {

    let events = logs.map {
        $0.event.rawValue
    }

    print("Произошедшие события: \(Set(events))")
    dispatchGroup.leave()
}

dispatchGroup.wait()
