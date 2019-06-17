//
//  MQTTConnection.swift
//  MuzzleyCoreIOS
//
//  Created by Ana Figueira on 10/03/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import Foundation
import RxSwift
import CocoaMQTT
import CocoaLumberjack


@objc class MZMQTTConnection : NSObject, CocoaMQTTDelegate
{
	fileprivate let _keepAlive : UInt16 = 30
	fileprivate let _cleanSession : Bool = true
	fileprivate let _mqttQoS : CocoaMQTTQOS = CocoaMQTTQOS.qos0
	fileprivate var _host : String = ""
	fileprivate var _port : UInt16 = 0
	fileprivate var _useSSL : Bool = true
	fileprivate var _username : String = ""
	fileprivate var _password : String = ""
	fileprivate var _clientId : String = ""
    //TODO change to enum
	fileprivate var _isDisconnecting = false
    fileprivate var _isConnecting = false
    fileprivate var _retry : UInt16 = 3
    
    var subscribedChannels = [String]()
    
	
	open var mqtt : CocoaMQTT?
	
	open var userId : String = ""
	
	var cid = 0
	
	var reachabilityChecker = Reachability.forInternetConnection()

	class var sharedInstance : MZMQTTConnection
	{
		struct Singleton
		{
			static let instance = MZMQTTConnection()
		}
		return Singleton.instance
	}
	
	
	override init()
	{
		super.init()
        self.subscribedChannels = [String]()
		NotificationCenter.default.addObserver(self, selector: Selector("handleNetworkChange:"), name: NSNotification.Name.reachabilityChanged, object: nil)
		reachabilityChecker!.startNotifier()
	}

	func handleNetworkChange(_ notification:Notification)
	{
		switch(reachabilityChecker!.currentReachabilityStatus())
		{
		case ReachableViaWiFi,
		     ReachableViaWWAN:
			self.reconnect()
			break
			
        case NotReachable:
            disconnectOnNoInternet()
            break
		
		default:
			break
		}
	}
	
	func connect(_ username: String, password: String, host: String, port: UInt16, useSSL: Bool, completion: ((_ success: Bool, _ error: NSError?) -> Void)?)
	{
        self.subscribedChannels = [String]()

		if(host.isEmpty || username.isEmpty || password.isEmpty)
		{
			// Error
            completion?(false, nil)
            return
		}
        
        let reachability = Reachability.forInternetConnection
        let internetStatus = reachability()!.currentReachabilityStatus
		if (internetStatus() == NotReachable)
		{
			completion?(false, nil)
			return
		}
		else
		{
            if self.mqtt == nil
            {
                self._host = host
                self._port = port
                self._useSSL = useSSL
                self._username = username
                self._password = password
                self._clientId = UUID().uuidString
				
                self.mqtt = CocoaMQTT(clientID: self._clientId, host: self._host, port: self._port)
                self.mqtt!.logLevel = CocoaMQTTLoggerLevel.off
                self.mqtt!.username = self._username
                self.mqtt!.password = self._password
                self.mqtt!.secureMQTT = self._useSSL
                self.mqtt!.enableSSL = self._useSSL
                //mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
                self.mqtt!.keepAlive = self._keepAlive
                self.mqtt!.delegate = self
                
                self.listenToDidConnectAck(nil)
				
                self.listenToMqttDidDisconnect(nil)
            }
            
            
            if self.mqtt!.connState != CocoaMQTTConnState.connecting
            {
                Log.mqtt("MQTT: connect will connect", saveInDebugLog: true)
                self.mqtt!.connect()
            }
		}
	}
	
	
    func subscribe(_ topic: String, completion: @escaping (_ success: Bool, _ topic: String,_ error: NSError?) -> Void)
	{
		if(mqtt == nil || self.mqtt!.connState != CocoaMQTTConnState.connected)
		{
            Log.mqtt("MQTT: subscribe: there's no mqtt connection, will reconnect", saveInDebugLog: true)
			completion(false, topic, nil)
            self.reconnect()
		}
		else
		{
            
            if(!self.subscribedChannels.contains(topic))
            {
                Log.mqtt("MQTT: Will subscribe to : " + topic)
                self.listenToDidSubscribeTopic(completion: { (topic) in
                    self.subscribedChannels.append(topic)
                    completion(true,topic, nil)
                })
                mqtt!.subscribe(topic, qos: self._mqttQoS)
            }
            else // Is already subscribed
            {
                completion(true,topic, nil)
            }
		}
	}
	
    func unsubscribe(_ topic: String, completion: @escaping (_ success: Bool, _ topic: String,  _ error: NSError?) -> Void)
	{
		if(mqtt == nil || self.mqtt!.connState != CocoaMQTTConnState.connected)
		{
            Log.mqtt("MQTT: unsubscribe: there's no mqtt connection, will reconnect", saveInDebugLog: true)
			completion(false, topic, nil)
            self.reconnect()
		}
		else
		{
            if(self.subscribedChannels.contains(topic))
            {
                let index = self.subscribedChannels.index(of: topic)
                if(index != nil)
                {
                    self.subscribedChannels.remove(at: index!)
                }
            }
            self.listenToDidUnsubscribeTopic({ (topic) in
                completion(true, topic, nil)
            })
			mqtt!.unsubscribe(topic)
		}
	}
	
	func publish(_ topic: String, jsonDict : NSDictionary, completion: ((_ success: Bool, _ error: NSError?) -> Void)?)
	{        
        if topic == nil || topic.characters.count == 0
        {
            return
        }
        
		if(mqtt == nil || self.mqtt!.connState != CocoaMQTTConnState.connected)
		{
            Log.mqtt("MQTT: publish: there's no mqtt connection, will reconnect", saveInDebugLog: true)
			completion?(false, nil)
            self.reconnect()
		}
		else
		{
			var nTopic = topic
			if(nTopic.hasSuffix("/#"))
			{
				nTopic = nTopic.removeCharsAtEnd(2)
			}
            
//            let mutableDict = NSMutableDictionary(dictionary: jsonDict)
//            mutableDict.addEntries(from: ["sender": self.userId])
        
            Log.mqtt("MQTT: sending publish to core -------- " + topic + " | message:  \(MZJsonHelper.stringify(jsonDict))")

            self.listenToDidPublishMessage({ (message) in
                completion?(true, nil)
            })
            
            do {
                let data = try! JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.init(rawValue: 0))
                let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
                mqtt!.publish(topic, withString: json)
            } catch let error as NSError {
                Log.mqtt("MQTT: Error:\(error)", saveInDebugLog: true)
            }
		}
	}

	func disconnect()
	{
        self._retry = 0
		_isDisconnecting = true
		if(self.mqtt != nil)
		{
            Log.mqtt("MQTT: disconnect: will disconnect")
			self.mqtt?.disconnect()
            self.mqtt = nil
		}
	}
	
	func disconnectOnNoInternet()
	{
		_isDisconnecting = false // Not on purpose. Want to keep credentials for reconnect
		if(self.mqtt != nil)
		{
            Log.mqtt("MQTT: disconnectOnNoInternet: will disconnect", saveInDebugLog: true)
			self.mqtt?.disconnect()
            self.mqtt = nil
		}
		
	}
	
	func reconnect()
	{
        self.subscribedChannels = [String]()

        if MZSession.sharedInstance.authInfo != nil
        {
            MZMQTTConnection.sharedInstance.userId = MZSession.sharedInstance.authInfo!.userId
            
            var useSSL = true
            
            let mqttUrl = URL(string: MZSession.sharedInstance.authInfo!.mqttUrl)
            
            if(mqttUrl?.scheme == nil)
            {
                MZSession.sharedInstance.closeAndClear()
                return
            }
            
            switch mqttUrl!.scheme!.lowercased()
            {
            case "mqtts":
                useSSL = true
                break
            case "mqtt":
                useSSL = false
                break
                
            default:
                // Show Error and signout!!!
                MZSession.sharedInstance.closeAndClear()
                return
            }
            
            if(mqttUrl?.port == nil)
            {
                MZSession.sharedInstance.closeAndClear()
                return
            }
            
            let mqttPort : UInt16 = UInt16(mqttUrl!.port!)
            
            if(mqttUrl?.host == nil || mqttUrl!.host == nil || mqttUrl!.host!.isEmpty)
            {
                MZSession.sharedInstance.closeAndClear()
                return
            }
            
            let mqttHost = mqttUrl!.host!
            
            Log.mqtt("MQTT: reconnect: will connect")
            MZMQTTConnection.sharedInstance.connect(
                MZSession.sharedInstance.authInfo!.clientId,
                password: MZSession.sharedInstance.authInfo!.accessToken,
                host: mqttHost,
                port: mqttPort,
                useSSL: useSSL,
                completion: nil)
        }
//        if _retry >= 0
//        {
//        self.connect(MZSession.sharedInstance.authInfo!.clientId,
//                     password: MZSession.sharedInstance.authInfo!.accessToken,
//                     host: mqttHost,
//                     port: mqttPort,
//                     useSSL: useSSL,
//                     completion: nil) { (success, error) in
//                if(success)
//                {
//                    DDLogDebug("did reconnect")
//                }
//                else
//                {
//                    DDLogDebug("failed reconnect")
//                }
//                if (!success)
//                {
//                    self._retry--
//                }
//            }
//        } else {
//            let alertView: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_force_logout", comment: ""), preferredStyle: .alert)
//            alertView.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: { action in
//                MZSessionDataManager.sharedInstance.logout()
//                NSNotificationCenter.defaultCenter().postNotificationName("cleanUpAndGoToStart", object: nil)
//            }))
//            
//            
//            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
//        }
	}

    
    func listenToDidConnectAck(_ completion:((_ success: Bool) -> Void)?)
    {
		MZMQTTConnection.sharedInstance.mqtt?.rx_didConnectAck.subscribe(onNext: { (ack) in
			self.didConnectAck(ack)
            Log.mqtt("MQTT: listenToDidConnectAck Mqtt connected", saveInDebugLog: true)

			completion?(ack == CocoaMQTTConnAck.accept)
		}, onError: { (error) in
            Log.mqtt("MQTT: listenToDidConnectAck onError", saveInDebugLog: true)
			completion?(false)
		}, onCompleted: {
            Log.mqtt("MQTT: listenToDidConnectAck onCompleted", saveInDebugLog: true)
		}, onDisposed: {
            Log.mqtt("MQTT: listenToDidConnectAck onDisposed", saveInDebugLog: true)
		})
    }
    
    func listenToDidPublishMessage(_ completion:((_ message: MZMQTTMessage) -> Void)?)
    {
		MZMQTTConnection.sharedInstance.mqtt!.rx_didPublishMessage.subscribe(onNext: { (message) in
			completion?(message)
		}, onError: { (error) in
            Log.mqtt("MQTT: listenToDidPublishMessage onError")
		}, onCompleted: {
            Log.mqtt("MQTT: listenToDidPublishMessage onCompleted")
		}, onDisposed: {
            Log.mqtt("MQTT: listenToDidPublishMessage onDisposed")
		})
    }

    func listenToDidReceiveMessage(_ completion:@escaping (_ message: MZMQTTMessage) -> Void)
    {
        if(MZMQTTConnection.sharedInstance.mqtt != nil)
        {
            MZMQTTConnection.sharedInstance.mqtt!.rx_didReceiveMessage
                .subscribe(onNext: { (mqttMsg) in
                    dLog("MQTT: received message: \(mqttMsg.topic) ---- \(mqttMsg.message)")
                    if(mqttMsg.message.object(forKey: "io") != nil)
                    {
                        completion(mqttMsg)
                    }
                    else
                    {
//                      DDLogDebug("MQTT: received not io: " + mqttMsg.message.description)
                    }
                }, onError: { (
                    error) in
                    Log.mqtt("MQTT: listenToDidReceiveMessage onError")
                }, onCompleted: {
                    Log.mqtt("MQTT: listenToDidReceiveMessage onCompleted")
                }, onDisposed: {
                    Log.mqtt("MQTT: listenToDidReceiveMessage onDisposed")
                })
        }
    }
    
    func getSingleFilteredMessage(filterPredicate: @escaping (_ message: MZMQTTMessage) -> Bool, completion:@escaping (_ message: MZMQTTMessage) -> Void) -> Disposable
    {
        let disposable = MZMQTTConnection.sharedInstance.mqtt!.rx_didReceiveMessage.filter(filterPredicate).take(1).subscribe(onNext: { (mqttMsg) in
            if(mqttMsg.message.object(forKey: "io") != nil)
            {
                completion(mqttMsg)
            } else {
                Log.mqtt("MQTT: received not io: " + mqttMsg.message.description)
            }

        }, onError: { (Error) in
        }, onCompleted: {
        }, onDisposed: {
        })
        return disposable
    }
    
    func listenToDidSubscribeTopic(completion:((_ topic: String) -> Void)?)
    {
		MZMQTTConnection.sharedInstance.mqtt!.rx_didSubscribeTopic
		.subscribe(onNext: { (topic) in
            Log.mqtt("MQTT: listenToDidSubscribeTopic Success!")

			completion?(topic)
		}, onError: { (error) in
			Log.mqtt("MQTT: listenToDidSubscribeTopic onError")
		}, onCompleted: { 
			Log.mqtt("MQTT: listenToDidSubscribeTopic onCompleted")
		}, onDisposed: {
            Log.mqtt("MQTT: listenToDidSubscribeTopic onDisposed")
        })
    }
    
    func listenToDidUnsubscribeTopic(_ completion:((_ topic: String) -> Void)?)
    {
		MZMQTTConnection.sharedInstance.mqtt!.rx_didUnsubscribeTopic
		.subscribe(onNext: { (topic) in
			completion?(topic)
		}, onError: { (error) in
			Log.mqtt("MQTT: listenToDidUnsubscribeTopic onError")
		}, onCompleted: { 
			Log.mqtt("MQTT: listenToDidUnsubscribeTopic onCompleted")
		}, onDisposed: {
            Log.mqtt("MQTT: listenToDidUnsubscribeTopic onDisposed")
        })
	}

    func listenToMqttDidDisconnect(_ completion:((Void) -> Void)?)
    {
        if(MZMQTTConnection.sharedInstance.mqtt != nil)
        {
            MZMQTTConnection.sharedInstance.mqtt!.rx_mqttDidDisconnect
            .subscribe(onNext: { (mqtt) in
                self.didDisconnect()
                completion?()
            }, onError: { (error) in
                Log.mqtt("MQTT: listenToMqttDidDisconnect onError")
            }, onCompleted: {
                Log.mqtt("MQTT: listenToMqttDidDisconnect onCompleted")
            }, onDisposed: {
                Log.mqtt("MQTT: listenToMqttDidDisconnect onDisposed")
            })
        }
    }

	func cleanUp()
	{
		mqtt = nil
		_password = ""
		_username = ""
		_host = ""
		_port = 8883
	}
	
	func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
		Log.mqtt("MQTT: didConnectAck")
	}
    
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int)
    {
        Log.mqtt("MQTT: didConnect")
    }
	
    func didConnectAck(_ ack: CocoaMQTTConnAck)
    {
        if(ack == CocoaMQTTConnAck.accept)
        {
            self._retry = 0
            Log.mqtt("MQTT: Connection to mqtt successful. Will subscribe", saveInDebugLog: true)
            let channelsTopic = MZTopicParser.createSubscribeAllChannelsTopic(self.userId)
            
            self.subscribe(channelsTopic, completion: { (success,topic, error) in
                if(success && topic == channelsTopic)
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MQTTDidSubscribe), object: nil)
                }
            })
        } else {
            Log.mqtt("MQTT: Connection to mqtt failed : \(ack)", saveInDebugLog: true)
			
            if (ack == CocoaMQTTConnAck.badUsernameOrPassword)
            {
                self.disconnect()
                
                let alertView: UIAlertController = UIAlertController(title: NSLocalizedString("mobile_error_title", comment: ""), message: NSLocalizedString("mobile_force_logout", comment: ""), preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: NSLocalizedString("mobile_ok", comment: ""), style: .cancel, handler: { action in
                    MZSessionDataManager.sharedInstance.logout()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cleanUpAndGoToStart"), object: nil)
                }))
				
                UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
            }
        }
    }
	
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16)
    {
        Log.mqtt("MQTT: Publish successful: " + message.topic)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16)
    {
        Log.mqtt("MQTT: Publish successful: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 )
    {
        Log.mqtt("MQTT: Message from core -> Topic: " + message.topic + " message: \(message.string)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String)
    {
        Log.mqtt("MQTT: Subscribe successful: " + topic)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String)
    {
        Log.mqtt("MQTT: Unsubscribe successful: " + topic)
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT)
    {
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT)
    {
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?)
    {
        self.didDisconnect()
    }
    
    func didDisconnect()
    {
        self.subscribedChannels = [String]()

        if(self._isDisconnecting)
        {
            self._retry = 0
            self._isDisconnecting = false

//            DDLogDebug(message: "MQTT: Disconnected Successfully")
        }
        else //if(self.mqtt!.connState == CocoaMQTTConnState.connected)
        {
//
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                Log.mqtt("MQTT: Forced disconnected, will reconnect")
                self.reconnect()
            })
        }
    }
}

