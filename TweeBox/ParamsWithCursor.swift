//
//  ParamsWithCursor.swift
//  TweeBox
//
//  Created by 4faramita on 2017/8/24.
//  Copyright © 2017年 4faramita. All rights reserved.
//

import Foundation

protocol ParamsWithCursorProtocol: ParamsProtocol {
    
    var cursor: String? { get set }
}
