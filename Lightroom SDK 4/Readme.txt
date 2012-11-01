Welcome to the Adobe® Photoshop® Lightroom® 4 Software Development Kit 
_____________________________________________________________________________

This file contains the latest information for the Adobe Photoshop 
Lightroom SDK. The information applies to Adobe Photoshop 
Lightroom. It has the following sections:

1. Introduction
2. SDK content overview
3. Development environment
4. Sample plug-ins
5. Running the plug-ins
6. Adobe Labs

**********************************************
1. Introduction
**********************************************

The SDK provides information and examples for the scripting interface to Adobe 
Photoshop Lightroom.  The SDK defines a scripting interface for the Lua language.

**********************************************
2. SDK content overview
**********************************************

The SDK contents include the following:

- <sdkInstall>/Manual/Lightroom SDK Guide.pdf: 
	Describes the SDK and how to extend the functionality of 
	Adobe Photoshop Lightroom.

- <sdkInstall>/API Reference/:  
	The Scripting API reference in HTML format. Start at index.html.

- <sdkInstall>/Sample Plugins: 
	Sample plug-ins and demonstration code (see section 4).

**********************************************
3. Development environment
**********************************************

You can use any text editor to write your Lua scripts, and you can
use the LrLogger namespace to write debugging information to a console. 
See the section on "Debugging your Plug-in" in the Lightroom SDK Guide.

**********************************************
4. Sample Plugins
**********************************************

The SDK provides the following samples:

- <sdkInstall>/Sample Plugins/flickr.lrdevplugin/: 
	Sample plug-in that demonstrates creating a plug-in which allows 
	images to be directly exported to a Flickr account.

- <sdkInstall>/Sample Plugins/ftp_upload.lrdevplugin/: 
	Sample plug-in that demonstrates how to export images to an FTP server.

- <sdkInstall>/Sample Plugins/helloworld.lrdevplugin/: 
	Sample code that accompanies the Getting Started section of the 
	Lightroom SDK Guide.

  <sdkInstall>/Sample Plugins/custommetadatasample.lrdevplugin/:
	Sample code that accompanies the custommetadatasample plug-in that
	demonstrates custom metadata.

- <sdkInstall>/Sample Plugins/metaexportfilter.lrdevplugin/: 
	Sample code that demonstrates using the metadata stored in a file 
	to filter the files exported via the export dialog.

- <sdkInstall>/Sample Plugins/websample.lrwebengine/: 
	Sample code that creates a new style of web gallery template 
	using the Web SDK.

**********************************************
5. Running the plug-ins
**********************************************

To run the sample code, load the plug-ins using the Plug-in Manager
available within Lightroom.  See the Lightroom SDK Guide for more information.

*********************************************************
6. Adobe Labs
*********************************************************

To learn more about Adobe Labs, point your browser to:

  http://labs.adobe.com

_____________________________________________________________________________

Copyright 2012 Adobe Systems Incorporated. All rights reserved.

Adobe, Lightroom, and Photoshop are registered trademarks or trademarks of 
Adobe Systems Incorporated in the United States and/or other countries. 
Windows is either a registered trademark or a trademark of Microsoft Corporation
in the United States and/or other countries. Macintosh is a trademark of 
Apple Computer, Inc., registered in the United States and  other countries.

_____________________________________________________________________________
