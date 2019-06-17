//
//  MZCocoaMQTTExtensions.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 16/03/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CocoaMQTT

extension CocoaMQTT
{
	public var rx_delegate : DelegateProxy
	{
		return  MZMQTTDelegateProxy.self.proxyForObject(self)
	}
    
	
	public var rx_didConnect : Observable<CocoaMQTT>
	{
		let proxy = MZMQTTDelegateProxy.self.proxyForObject(self)
		//proxyForObject(MZMQTTDelegateProxy.self, self)
		return proxy.didConnectSubject
	
	}
    
    public var rx_didConnectAck : Observable<CocoaMQTTConnAck>
    {
        let proxy = MZMQTTDelegateProxy.self.proxyForObject(self)
		//proxyForObject(MZMQTTDelegateProxy.self, self)
        return proxy.didConnectAckSubject
    }
    
    public var rx_didPublishMessage : Observable<MZMQTTMessage>
    {
        let proxy = MZMQTTDelegateProxy.self.proxyForObject(self)
		//proxyForObject(MZMQTTDelegateProxy.self, self)
        return proxy.didPublishMessageSubject
    }

    public var rx_didPublishAck : Observable<CocoaMQTT>
    {
        let proxy = MZMQTTDelegateProxy.self.proxyForObject(self)
		//proxyForObject(MZMQTTDelegateProxy.self, self)
        return proxy.didPublishAckSubject
    }

    public var rx_didReceiveMessage : Observable<MZMQTTMessage>
    {
        let proxy = MZMQTTDelegateProxy.self.proxyForObject(self)
		//proxyForObject(MZMQTTDelegateProxy.self, self)
        return proxy.didReceiveMessageSubject
    }
    
    public var rx_didSubscribeTopic : Observable<String>
    {
        let proxy = MZMQTTDelegateProxy.self.proxyForObject(self)
		//proxyForObject(MZMQTTDelegateProxy.self, self)
        return proxy.didSubscribeTopicSubject
    }
    
    public var rx_didUnsubscribeTopic : Observable<String>
    {
        let proxy = MZMQTTDelegateProxy.self.proxyForObject(self)
		//proxyForObject(MZMQTTDelegateProxy.self, self)
        return proxy.didUnsubscribeTopicSubject
    }
    
    public var rx_mqttDidPing : Observable<CocoaMQTT>
    {
        let proxy = MZMQTTDelegateProxy.self.proxyForObject(self)
		//proxyForObject(MZMQTTDelegateProxy.self, self)
        return proxy.mqttDidPingSubject
    }
    
    public var rx_mqttDidReceivePong : Observable<CocoaMQTT>
    {
        let proxy = MZMQTTDelegateProxy.self.proxyForObject(self)
		//proxyForObject(MZMQTTDelegateProxy.self, self)
        return proxy.mqttDidReceivePongSubject
    }
    
    public var rx_mqttDidDisconnect : Observable<CocoaMQTT>
    {
        let proxy = MZMQTTDelegateProxy.self.proxyForObject(self)
		//proxyForObject(MZMQTTDelegateProxy.self, self)
        return proxy.mqttDidDisconnectSubject
    }

}
