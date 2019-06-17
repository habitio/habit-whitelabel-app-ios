//
//  MZMQTTDelegatesProxy.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 16/03/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CocoaMQTT

class MZMQTTDelegateProxy: DelegateProxy, DelegateProxyType, CocoaMQTTDelegate
{

	let didConnectSubject = PublishSubject<CocoaMQTT>()
	let didConnectAckSubject = PublishSubject<CocoaMQTTConnAck>()
	let didPublishMessageSubject = PublishSubject<MZMQTTMessage>()
    let didPublishAckSubject = PublishSubject<CocoaMQTT>()
    let didReceiveMessageSubject = PublishSubject<MZMQTTMessage>()
    let didSubscribeTopicSubject = PublishSubject<String>()
    let didUnsubscribeTopicSubject = PublishSubject<String>()
    let mqttDidPingSubject = PublishSubject<CocoaMQTT>()
    let mqttDidReceivePongSubject = PublishSubject<CocoaMQTT>()
    let mqttDidDisconnectSubject = PublishSubject<CocoaMQTT>()

	
	static func currentDelegateFor(_ object: AnyObject) -> AnyObject?
	{
		let mqtt : CocoaMQTT  = object as! CocoaMQTT
		return mqtt.delegate as! AnyObject
	}
	
	static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
		
		let mqtt : CocoaMQTT = object as! CocoaMQTT
		mqtt.delegate = delegate as? CocoaMQTTDelegate
	}
    
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int)
    {
        didConnectSubject.on(.next(mqtt))
		self._setForward(toDelegate: mqtt, retainDelegate: false)
        //self._setForwardToDelegate(mqtt as! AnyObject, retainDelegate: false)
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck)
    {
        didConnectAckSubject.on(.next(ack))
		self._setForward(toDelegate: mqtt, retainDelegate: false)
//        self._setForwardToDelegate(mqtt as! AnyObject, retainDelegate: false)
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16)
    {
//        dLog(message: "didPublishMessage:\(message.string)")
		
        var dictonary:NSDictionary?
        
        if let data = message.string!.data(using: String.Encoding.utf8) {
            
            do {
                dictonary =  try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as! NSDictionary
                
                if let myDictionary = dictonary
                {
                    let mqttMessage = MZMQTTMessage(topic: message.topic, message: myDictionary)
                    didPublishMessageSubject.on(.next(mqttMessage))
					self._setForward(toDelegate: mqtt, retainDelegate: false)
                    //self._setForwardToDelegate(mqtt as! AnyObject, retainDelegate: false)
                }
            } catch let error as NSError {
//                dLog(message: "Error parsing core message! error:\(error)")
            }
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16)
    {
        didPublishAckSubject.on(.next(mqtt))
		self._setForward(toDelegate: mqtt, retainDelegate: false)
        //self._setForwardToDelegate(mqtt as! AnyObject, retainDelegate: false)
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 )
    {
//        dLog(message: "didReceiveMessage:\(message.string)")

        var dictonary:NSDictionary?
        
        if let data = message.string!.data(using: String.Encoding.utf8) {
            
            do {
                dictonary =  try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                
                if let myDictionary = dictonary
                {
                    let mqttMessage = MZMQTTMessage(topic: message.topic, message: myDictionary)
                    didReceiveMessageSubject.on(.next(mqttMessage))
					self._setForward(toDelegate: mqtt, retainDelegate: false)
					//self._setForwardToDelegate(mqtt as! AnyObject, retainDelegate: false)
                }
            } catch let error as NSError {
//                dLog(message: "Error parsing core message! error:\(error)")
            }
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String)
    {
        didSubscribeTopicSubject.on(.next(topic))
		self._setForward(toDelegate: mqtt, retainDelegate: false)
        //self._setForwardToDelegate(mqtt as! AnyObject, retainDelegate: false)
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String)
    {
        didUnsubscribeTopicSubject.on(.next(topic))
		self._setForward(toDelegate: mqtt, retainDelegate: false)
        //self._setForwardToDelegate(mqtt as! AnyObject, retainDelegate: false)
    }

    func mqttDidPing(_ mqtt: CocoaMQTT)
    {
        mqttDidPingSubject.on(.next(mqtt))
		self._setForward(toDelegate: mqtt, retainDelegate: false)
		//self._setForwardToDelegate(mqtt as! AnyObject, retainDelegate: false)
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT)
    {
        mqttDidReceivePongSubject.on(.next(mqtt))
		self._setForward(toDelegate: mqtt, retainDelegate: false)
		//self._setForwardToDelegate(mqtt as! AnyObject, retainDelegate: false)
    }

	func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
		mqttDidDisconnectSubject.on(.next(mqtt))
		self._setForward(toDelegate: mqtt, retainDelegate: false)
		//self._setForwardToDelegate(mqtt as! AnyObject, retainDelegate: false)

	}


	deinit
	{
        didConnectSubject.on(.completed)
        didConnectAckSubject.on(.completed)
        didPublishMessageSubject.on(.completed)
        didPublishAckSubject.on(.completed)
        didReceiveMessageSubject.on(.completed)
        didSubscribeTopicSubject.on(.completed)
        didUnsubscribeTopicSubject.on(.completed)
        mqttDidPingSubject.on(.completed)
        mqttDidReceivePongSubject.on(.completed)
        mqttDidDisconnectSubject.on(.completed)
	}
}


