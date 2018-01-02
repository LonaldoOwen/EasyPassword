//
//  GenerateView.swift
//  EasyPassword
//
//  Created by owen on 27/12/2017.
//  Copyright © 2017 libowen. All rights reserved.
//
/// GenerateView
/// 功能：自定义UIView用于显示生成密码界面
/// 1、设置密码规则、位数（是否要联动？？？）
/// 2、生成密码
/// 3、创建代理协议，用于处理生成的password
///
///
///
///
///
///
///




import UIKit

protocol GeneratePasswordDelegate {
    func passwordDidGenerated(password: String)
}

class GenerateView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var reGeneratePasswordBtn: UIButton!
    @IBOutlet weak var lengthValue: UILabel!
    @IBOutlet weak var digitValue: UILabel!
    @IBOutlet weak var symbolValue: UILabel!
    
    var delegate: GeneratePasswordDelegate!
    
    // MARK: - Action
    
    @IBAction func handleReGeneratePasswordAction(_ sender: Any) {
        // 根据设置条件重新生成一个密码
        let password = generatePassword(ofLength: 0, digit: 0, symbol: 0)
        delegate.passwordDidGenerated(password: password)
    }
    
    @IBAction func handleLengthChange(_ sender: Any) {
        print((sender as! UISlider).value)
        print("ceilF: \(ceilf((sender as! UISlider).value))")
        print("lrintf: \(lrintf((sender as! UISlider).value))")
        
        // 如果数字和符号先设置了，总数需要跟着变
        
        lengthValue.text = String(lrintf((sender as! UISlider).value))
    }
    
    @IBAction func handleDigitChange(_ sender: Any) {
        // 需要考虑总数和符号数量
        
        let showValue = lrintf((sender as! UISlider).value)
        digitValue.text = String(showValue)
    }
    
    @IBAction func handleSymbolChange(_ sender: Any) {
        // 需要考虑总数和数字数量
        
        let showValue = lrintf((sender as! UISlider).value)
        symbolValue.text = String(showValue)
    }
    
    
    // MARK: - Helper
    
    enum PasswordType {
        case letter, digit, symbol
    }
    
    // 生成密码方法
    func randomString(withLength length: Int, ofType type: PasswordType) -> String {
        var passwordPool: String = ""
        var typeLength: UInt32 = 0
        switch type {
        case .letter:
            passwordPool = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz"// 52
            typeLength = 52
        case .digit:
            passwordPool = "0123456789" // 10
            typeLength = 10
        case .symbol:
            passwordPool = "~!@#$%^&*()_+" // 13
            typeLength = 13
        default:
            passwordPool = "" //
        }
        //srandom(10)
        var randomString = ""
        for _ in 0..<length {
            let randomIndex: Int = Int(arc4random() % typeLength)
            let index = passwordPool.index(passwordPool.startIndex, offsetBy: randomIndex)
            let subString = String.init(passwordPool[index])
            randomString += subString
        }
        
        return randomString
    }
    
    // 生成密码方法
    func generatePassword(ofLength length: Int, digit: Int, symbol: Int) -> String {
        let digitLength: Int = Int(digitValue.text!)!
        let symbolLength: Int = Int(symbolValue.text!)!
        let letterLength: Int = length - digitLength - symbolLength
        var password: String = ""
        let digitString = randomString(withLength: digitLength, ofType: PasswordType.digit)
        let symbolString = randomString(withLength: symbolLength, ofType: PasswordType.symbol)
        let letterString = randomString(withLength: letterLength, ofType: PasswordType.letter)
        
        // 分别将数字、符号随机插入到字母中
        
        
        return password
        //return "Password123"
    }
    
    
    // 生成随机数方法
    
}
