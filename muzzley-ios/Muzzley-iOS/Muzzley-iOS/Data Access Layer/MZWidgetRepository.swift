//
//  MZWidgetRepository.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 15/05/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit
import Foundation
import SSZipArchive

class MZWidgetRepository: NSObject
{
	let WIDGET_INTERFACES_CACHE_FOLDER = "WidgetInterfaces"
	let WIDGET_INTERFACE_META_FILE = "interface-meta.json"
	let STORED_INTERFACES_PLIST = "StoredInterfaces.plist"
	let TEMPORARY_FOLDER = "tmp"
	
	let widgetInterfacesFolderPath : String
	let storedInterfacesPlistPath : String
	let temporaryFolderPath : String

	override init()
	{
		let fileManager = FileManager.default
		let pathList = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
		let userDomainCacheFolderPath = pathList[0]
		let bundleName = Bundle.main.infoDictionary?["CFBundleIdentifier"]
		
		// Create widget interfaces folder if it doesn't exist
		let bundleFolderPath = userDomainCacheFolderPath.appending("/" + (bundleName as! String))
		self.widgetInterfacesFolderPath = bundleFolderPath.appending("/" + WIDGET_INTERFACES_CACHE_FOLDER)
		do
		{
			try fileManager.createDirectory(atPath: self.widgetInterfacesFolderPath, withIntermediateDirectories: true, attributes: nil)
		}
		catch let error as NSError
		{
			NSLog("Unable to create directory \(error.debugDescription)")
		}
		
		// Create StoredInterfaces.plist if it doesn´t exist
		self.storedInterfacesPlistPath = self.widgetInterfacesFolderPath.appending("/" + STORED_INTERFACES_PLIST)
		if(!fileManager.fileExists(atPath: self.storedInterfacesPlistPath))
		{
			let storedInterfacesDictionary = NSDictionary()
			storedInterfacesDictionary.write(toFile: self.storedInterfacesPlistPath, atomically: true)
		}
		
		// Create zip sources folder if it doesn't exist
		self.temporaryFolderPath = bundleFolderPath.appending("/" + TEMPORARY_FOLDER)
		do
		{
			try fileManager.createDirectory(atPath: self.temporaryFolderPath, withIntermediateDirectories: true, attributes: nil)
		}
		catch let error as NSError
		{
			NSLog("Unable to create directory \(error.debugDescription)")
		}
		
	}
	
	
	func unzipWidgetContent(zipData : Data, eTag: String, widgetUUID: String) -> Bool
	{
		let fileManager = FileManager.default
		let zipFileName = widgetUUID + ".zip"
		let zipPath = self.temporaryFolderPath.appending("/" + zipFileName)
		let destinationPath = self.widgetInterfacesFolderPath.appending("/" + widgetUUID)
		
		do
		{
			try fileManager.createFile(atPath: zipPath, contents: zipData, attributes: nil)
			try fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
		}
		catch let error as NSError
		{
			NSLog("Error unziping interface archive\(error.debugDescription)")
		}
		
		let success = SSZipArchive.unzipFile(atPath: zipPath, toDestination: destinationPath)
		if(success)
		{
			let mainFileName = self.widgetMainFileNameForId(widgetUUID)
			let metadata : NSDictionary = NSDictionary(dictionary: ["etag" : eTag, "main" : mainFileName])
			self.generateMetada(metadata: metadata, widgetUUID: widgetUUID)
		}
		
		return success
	}
	
	
	
	func generateMetada(metadata: NSDictionary, widgetUUID: String)
	{
		let storedInterfaces : NSMutableDictionary? = self.storedInterfacesDictionary()
		if(storedInterfaces != nil && metadata.isKind(of: NSDictionary.self))
		{
			storedInterfaces?.setValue(metadata, forKey: widgetUUID)
			storedInterfaces?.write(toFile: self.storedInterfacesPlistPath, atomically: true)
		}
	}
	
	
	func storedInterfacesDictionary() -> NSMutableDictionary?
	{
		var storedInterfaces : NSMutableDictionary? =  NSMutableDictionary(contentsOfFile: self.storedInterfacesPlistPath)
		if(!storedInterfaces!.isKind(of: NSMutableDictionary.self))
		{
			storedInterfaces = nil
		}
		
		return storedInterfaces
	}
	
	func widgetMainFileNameForId(_ widgetUUID: String) -> String
	{
		let widgetFolderPath = self.widgetInterfacesFolderPath.appending("/" + widgetUUID)
		let interfaceMetaFilePath = widgetFolderPath.appending("/" + WIDGET_INTERFACE_META_FILE)
		
		var jsonString : String = ""
		do
		{
			jsonString = try String(contentsOfFile: interfaceMetaFilePath)
			do
			{
				
				let interfaceMeta = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers)
				if(!(interfaceMeta as AnyObject).isKind(of: NSDictionary.self))
				{
					return ""
				}
				else
				{
					return (interfaceMeta as! NSDictionary).object(forKey: "main") as! String
				}
			}
			catch let error as NSError
			{
				return ""
			}
		}
		catch let error as NSError
		{
			NSLog("Error loading interface metadata file\(error.debugDescription)")
			return ""
		}
		
		return ""
	}
	
	
	func widgetURIForId(_ widgetUUID: String) -> URL?
	{
		let storedInterfaces = self.storedInterfacesDictionary()
		let interfaceInfo = storedInterfaces?.object(forKey: widgetUUID) as? NSDictionary

		var widgetMainFileName = interfaceInfo?.object(forKey: "main") as? String
		if(widgetMainFileName == nil)
		{
			widgetMainFileName = ""
		}
		
		let widgetURIString = self.widgetInterfacesFolderPath.appending("/" + widgetUUID).appending("/" + widgetMainFileName!)
		
		return URL(string: widgetURIString)
	}
	
	
	func ETagForId(_ widgetUUID: String) -> String
	{
		let storedInterfaces = self.storedInterfacesDictionary()
		let keyPath = widgetUUID + ".etag"
		
		var eTag = storedInterfaces?.value(forKey: keyPath) as? String
		if(eTag == nil)
		{
			eTag = ""
		}
		
		return eTag!

	}
	
}
