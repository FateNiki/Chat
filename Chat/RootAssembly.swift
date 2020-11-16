//
//  RootAssembly.swift
//  Chat
//
//  Created by Алексей Никитин on 09.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import Foundation

class RootAssembly {
    lazy var router: Router = Router(presentationAssembly: presentationAssembly)
    private lazy var presentationAssembly: PresentationAssemblyProtocol = PresentationAssembly(serviceAssembly: self.serviceAssembly)
    private lazy var serviceAssembly: ServicesAssemblyProtocol = ServicesAssembly(coreAssembly: self.coreAssembly)
    private lazy var coreAssembly: CoreAssemblyProtocol = CoreAssembly()
}
