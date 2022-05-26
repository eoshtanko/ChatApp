//
//  SavingServiceAssembly.swift
//  ChatApp
//
//  Created by Екатерина on 15.05.2022.
//

import Foundation

class SavingServiceAssembly {
    
    var userSavingService: AnyTypeSavingService<User> {
        let savingService = SavingService<User>(memoryManager: GCDMemoryManagerInterface<User>(), fileName: FileNames.plistFileNameForProfileInfo)
        return AnyTypeSavingService(sourceSavingService: savingService)
    }
    
    var themeSavingService: AnyTypeSavingService<ApplicationPreferences> {
        let savingService = SavingService<ApplicationPreferences>(
            memoryManager: GCDMemoryManagerInterface<ApplicationPreferences>(),
            fileName: FileNames.plistFileNameForPreferences)
        return AnyTypeSavingService(sourceSavingService: savingService)
    }
}
