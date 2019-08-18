//
//  Resource.swift
//  SwiftUIMapKit
//
//  Created by Sasha Prokhorenko on 18.08.19.
//  Copyright © 2019 Sasha Prokhorenko. All rights reserved.
//

import Combine
import Foundation

final class Resource<A>: ObservableObject {
    // todo is there a better way to have an empty publisher?
    var objectWillChange: AnyPublisher<A?, Never> = Publishers.Sequence<[A?], Never>(sequence: []).eraseToAnyPublisher()
    @Published var value: A? = nil
    let endpoint: Endpoint<A>
    private var firstLoad = true
    
    init(endpoint: Endpoint<A>) {
        self.endpoint = endpoint
        self.objectWillChange = $value.handleEvents(receiveSubscription: { [weak self] sub in
            guard let s = self, s.firstLoad else { return }
            s.firstLoad = false
            s.reload()

        }).eraseToAnyPublisher()
    }
    
    func reload() {
        print(endpoint.request.url!)
        URLSession.shared.load(endpoint) { result in
            DispatchQueue.main.async {
                self.value = try? result.get()
            }
        }
    }
}
