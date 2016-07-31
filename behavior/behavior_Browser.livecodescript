script "behavior_Browser"
--> MetaData
-
version: 0.1
license: GPLv3
name: behavior_Browser
type: behavior
copyright: David Bovill
licence:  GPLv3

/*
This is real old and needs complete refactoring.
Not much point to this at the moment :)
*/


--> Events
-
on dragEnter
   set the dragAction to "link"
   pass dragEnter
end dragEnter

on dragDrop
   get the dragsource
   put the dragData into someUrl
   set the itemdelimiter to ":"
   if item 1 of someUrl is among the items of "http:https" then
      set the browser_Url of me to someUrl
   end if
   pass dragDrop
end dragDrop

on deleteGroup
   put the browser_ID of me into browserID
   browser_Close browserID
   pass deleteGroup
end deleteGroup


--> View | Object
-
getprop view_Object
    return the long id of me
end view_Object

getprop browser_View
    return the long id of me
end browser_View


--> Browser | Props
-
getprop browser_Type
   put the browser_Type of me into browserType
   if browserType = "safari" then
      return "safari"
   else
      return "chrome"
   end if
end browser_Type

setprop browser_Type browserType
   set the browser_Type of me to browserType
end browser_Type

getprop browser_Types
   return "chrome,safari"
   return "cef,webkit"
end browser_Types

getprop browser_URL
   put the browser_ID of me into browserID
   if browserID is empty then
      return empty  -- a default if the browser is not open
   else
      return revBrowserGet (browserID, "url")
   end if
end browser_URL

setprop browser_URL [someRect] someUrl
   -- open the browser if it does not already exist!
   put the browser_ID of me into browserID
   if browserID is empty then
      if someRect is empty then put the browser_Rect of me into someRect
      
      put object_ExtractStack (the long id of me) into stackObject
      if the browser_Type of me is "chrome" then
         put revBrowserOpenCef (the windowid of stackObject, someUrl) into browserID
      else
         put revBrowserOpen (the windowid of stackObject, someUrl) into browserID
      end if
      revBrowserSet browserID, "rect", someRect
      set the browser_ID of me to browserID
      return browserID
   else if someUrl is empty then
      set the browser_ID of me to empty
   else
      revBrowserSet browserID, "url", someUrl
      if someRect is empty then put the browser_Rect of me into someRect
      revBrowserSet browserID, "rect", someRect
      return browserID
   end if
end browser_URL

getprop browser_ID
   put the long id of the target into tObject
   return browser_GetID (tObject)
end browser_ID

setprop browser_ID browserID
   put the long id of the target into tObject
   if browserID is empty then
      put browser_GetID (tObject) into oldBrowserID
      if oldBrowserID is a number then
         browser_Close oldBrowserID
      end if
   else
      browser_AddToRegister browserID, tObject
   end if
end browser_ID

function browser_Exists browserID
   set the wholematches to true
   put revBrowserInstances() into browserInstances
   put browserID is among the items of browserInstances into isTrue
   return isTrue
end browser_Exists


--> Geometry
-
command LayoutControl pRect
   -- this default does not require an image or a menu button
   -- it should be over-ridden by handler that also resizes those objects in a view if needed
   if pRect is empty then put the rect of me into pRect
   lock screen  
   set the browser_Rect of me to pRect
   unlock screen   
end LayoutControl

getprop browser_Rect [someRect]
   put the long id of the target into tObject
   put the browser_ID of tObject into browserID
   if browserID is empty then
      return the browser_DefaultRect [someRect] of tObject  -- a default if the browser is not open
   else
      return revBrowserGet (browserID, "rect")   -- return actual rect of displayed browser instance
   end if
end browser_Rect

setprop browser_Rect someRect
   put the browser_ID of me into browserID
   if browserID is empty then return "Error: no browser open for this object"
   
   put the inner_Rect [someRect] of me into innerRect
   if innerRect is empty then put someRect into innerRect
   revBrowserSet browserID, "rect", innerRect	
   return the result
end browser_Rect


--> Browser | Utils
-
function browser_GetID tObject
   put browser_GetFromRegister (tObject) into browserID
   if browser_Exists (browserID) then
      return browserID
   else -- tidy up
      browser_DeleteFromRegister browserID
      return empty
   end if
end browser_GetID

command browser_Close pBrowserID
   if pBrowserID is empty then put the browser_ID of the target into pBrowserID
   if pBrowserID is not a number then return empty
   
   browser_DeleteFromRegister pBrowserID
   if browser_Exists (pBrowserID) is true then
      revBrowserClose pBrowserID
   end if
   return the result
end browser_Close


--> Browser | ID
-
/*
This dictionary stuff is probably a bit more complex than we need. Simplify.
*/

function browser_GetFromRegister IdOrObject
   global gOPN_BrowserArray
   if IdOrObject is a number then
      put IdOrObject into browserID
      put dictionary_GetReverseValue (gOPN_BrowserArray, browserID) into browserID
      return browserID
   else if exists(IdOrObject) then
      put revRuggedID (IdOrObject) into tObject
      put dictionary_GetValue (gOPN_BrowserArray, tObject) into browserID
      return browserID
   else
      return empty
   end if
end browser_GetFromRegister

command browser_AddToRegister browserID, browserView
   global gOPN_BrowserArray
   put revRuggedID (browserView) into browserView
   dictionary_Set gOPN_BrowserArray, browserID, browserView
end browser_AddToRegister

command browser_DeleteFromRegister IdOrObject
   global gOPN_BrowserArray
   if IdOrObject is a number then
      put IdOrObject into browserID
      dictionary_Delete gOPN_BrowserArray, browserID
   else if exists (IdOrObject) then
      put revRuggedID (tObject) into tObject
      dictionary_Delete gOPN_BrowserArray, tObject
   end if
end browser_DeleteFromRegister

function dictionary_GetValue dataArray, someKey
   put dataArray ["key"][someKey] into someValue
   return someValue
end dictionary_GetValue

function dictionary_GetReverseValue dataArray, someValue
   put dataArray ["value"][someValue] into someKey
   return someKey
end dictionary_GetReverseValue

command dictionary_Set @dataArray, someKey, someValue
   -- was "array_TwoWaySet"
   put someValue into dataArray ["value"][someKey]
   put someKey into dataArray ["key"][someValue]
end dictionary_Set

command dictionary_Delete @dataArray, someKey
   put dataArray ["value"][someKey] into someValue
   delete variable dataArray ["value"][someKey]
   delete variable dataArray ["key"][someValue]
   if dataArray ["value"] is not an array then
      delete variable dataArray ["value"]
      delete variable dataArray ["key"]
   end if
end dictionary_Delete


--> Deps
-
function object_ExtractStack someObject
   set the wholematches to true
   put word (wordOffset ("stack", someObject)) to -1 of someObject into stackObject
   return stackObject
end object_ExtractStack


