//
//  BarCountViewModel.swift
//  iFlow
//
//  Created by Tom Novotny on 07.06.2023.
//

import Foundation

class BarCountViewModel: ObservableObject {
    @Published var currentBarIndex: Int = 0
    @Published var currentBeatIndex: Int = 0

    private let barCountInteractor: BarCountInteractor

    init(barCountInteractor: BarCountInteractor) {
        self.barCountInteractor = barCountInteractor
    }

    func onAppear() {
        barCountInteractor.observeCurrentBar(
            onBeatChanged: { [weak self] beat in
                DispatchQueue.main.async {
                    self?.currentBeatIndex = beat
                }
            },
            onBarChange: { [weak self] bar in
                DispatchQueue.main.async {
                    self?.currentBarIndex = bar
                }
            })
    }
}
