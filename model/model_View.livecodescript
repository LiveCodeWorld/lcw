script "model_View"
--> MetaData
-
license: GPLv3
name: model_View
type: model
version: 0.8


/*
This stack contains the model handlers for view data and template data.

Views can store arrays in their stacks using the template_Array property. 
The data is then no stored with teh view instance itself,
but as a custom property of the stack.

See also the library "libOPN_Style"
*/


--> View | File | hArray | Model | Wrappers
-
/*
These wrap the hArray database of view_names
*/

function view_StackNames
   return view_ListNames (empty, true)
end view_StackNames

function view_PathIndex includeStem
   return view_ListNames (empty, includeStem)
end view_PathIndex

function view_FilteredPaths vName, pIncludeStem
   return view_ListNames (vName, pIncludeStem)
end view_FilteredPaths



--> View | File | hArray | Model
-
/*
This is what libOPN_ViewBrowser uses to display stuff.
It's all stored in a standard model array on file.
*/

function view_ListNames pStartFilter, pIncludeStem
   put hArray_ListViewNames() into vNames
   if pIncludeStem is not true then put replacetext (vNames, "(View\|)\W*", empty) into vNames
   if pStartFilter is empty then return vNames
   
   view_NormalizeName pStartFilter
   if pIncludeStem is not true then
      set the itemdelimiter to "|"
      delete item 1 of pStartFilter
   end if
   filter vNames with (pStartFilter & "*")
   return vNames
end view_ListNames

function hArray_ListViewNames pStripViewBit
   put hArray_ListObjectNamesOfType ("view template") into vNames
   
   set the itemdelimiter to "|"
   sort vNames by item 5 of each
   sort vNames by item 4 of each
   sort vNames by item 3 of each
   sort vNames by item 2 of each
   
   if pStripViewBit is true then
      view_TrimFirstViewNameItem vNames
   end if
   return vNames
end hArray_ListViewNames

function hArray_GetViewTemplate viewName
   view_NormalizeName viewName
   put hArray_GetNamedObjectType (viewName, "view template") into viewTempate
   return viewTempate
end hArray_GetViewTemplate




--> View | File | Model | Weird
-
/*
These handlers are active, but flaky. Rationalise them.
*/

function view_NameToFile viewPath, pFileExt
   put view_PathToShortFile (viewPath, pFileExt) into shortFile
   put library_ViewFolder (shortFile) into viewFile
   return viewFile
end view_NameToFile

function view_FileToPath someFile, includeStem
   set the itemdelimiter to "/"
   put last item of someFile into viewPath
   
   replace "_" with "|" in viewPath
   set the itemdelimiter to "."
   if item -1 of viewPath is among the items of "livecode.rev.opml.html" then delete last item of viewPath
   if includeStem is true then view_NormalizeName viewPath
   return viewPath
end view_FileToPath

function view_PathToShortFile viewName, pFileExt
   view_NormalizeName viewName
   
   set the itemdelimiter to "|"
   if item 2 of viewName = "Compound" then
      put ".html" into someExension
   else if pFileExt is empty then
      put ".livecode" into someExension
      -- put ".rev" into someExension
   else
      put "." & pFileExt into someExension
   end if
   put rev_FixPath (viewName) into shortFile
   delete item 1 of shortFile
   replace "|" with "_" in shortFile
   put someExension after shortFile
   return shortFile
end view_PathToShortFile


--> View | File | Standard | Model
-
/*
Standard vies are stored in the standard library folder for views.
They are found using 

-  put library_StandardViewFolder() into someFolder

We now are moving to LCW - so it would eb good to add the LCW standard path.
*/

function view_ListStandardShortFiles
   -- was "view_ShortFiles"
   put library_StandardViewFolder() into someFolder
   put folder_ShortFiles (someFolder) into shortFiles
   return shortFiles
end view_ListStandardShortFiles

function view_ListStandardLongFiles
   put library_StandardViewFolder() into someFolder
   put folder_ShortFiles (someFolder) into shortFiles
   file_ShortToLong shortFiles, someFolder
   return shortFiles
end view_ListStandardLongFiles

function view_ListStandard
   -- was "view_ListNamesOfStandardFiles"
   put view_ListStandardLongFiles() into longViewFiles
   
   put empty into viewPaths
   repeat for each line longViewFile in longViewFiles
      -- put view_FileToPath (longViewFile, includeStem) into viewPath
      -- we assume the short name of the stack is the view_Name
      put the short name of stack longViewFile into vName
      put vName & CR after vNames
   end repeat
   delete last char of vNames
   return vNames
end view_ListStandard


--> View | File | Model
-
/*
"viewBrowser_ConstructArrayFromViewNames" is what libOPN_ViewBrowser uses to display stuff.
It's all stored in a standard model array on file.

This model stores text and data for browsing and navigating view templates,
but not needed for functioning of view - simply house-keeping.
So it is not necessary to distribute with working views.

Used for things like presenting and browsing library metadata.
Stored as a text file (an encoded array), and is not need ed to be distribute with view stack for it to work.
*/

getprop view_FileMetaData
   put the long id of the target into someView 
   put the view_Name of someView into vName
   if nameKey is empty then put the rugged_ID of someView into vName
   
   put view_GetFileMetaArray() into metaDataArray
   return metaDataArray [vName]
end view_FileMetaData

setprop view_FileMetaData vMetaDataArray
   put the long id of the target into someView 
   put the view_Name of someView into vName
   if nameKey is empty then put the rugged_ID of someView into vName
   
   put view_GetFileMetaArray() into metaDataArray
   put vMetaDataArray into metaDataArray [vName]
   view_SetFileMetaArray metaDataArray
   return metaDataArray
end view_FileMetaData


--> View | File | Model
-
/*
This is what libOPN_ViewBrowser uses to display stuff.
It's all stored in a standard model array on file.
*/

function viewBrowser_ConstructArrayFromViewNames vNames, pViewFilter, pExpandedViewNames
   -- uses "metaDataArray" for filtering
   
   put view_GetFileMetaArray() into metaDataArray
   set the wholematches to true
   repeat with lineNum = 1 to the number of lines of vNames
      put line lineNum of vNames into vName
      put metaDataArray [vName]["isTested"] into isTested
      
      switch pViewFilter
         case "all"
            -- don't skip whatever the value
            break
         case "favourites"
            if metaDataArray [vName]["isFavourite"] is not true then
               next repeat 
            end if
            break
         case "experimental"
            if isTested is true then
               next repeat 
            end if
            break
         case "old"
            if metaDataArray [vName]["isOld"] is not true then next repeat 
            break
         case "not old"
            if metaDataArray [vName]["isOld"] is true then next repeat 
            break
         default -- case "tested"
            if isTested is not true then
               next repeat 
            end if
            break
      end switch
      
      put vName into dgArray [lineNum]["title"]
      if vName is among the lines of pExpandedViewNames then
         put true into dgArray [lineNum]["isExpanded"]
      else
         put pIsExpanded is true into dgArray [lineNum]["isExpanded"]
      end if
   end repeat
   return dgArray
end viewBrowser_ConstructArrayFromViewNames

function view_GetMetaData vName
   put view_GetFileMetaArray() into metaDataArray
   return metaDataArray [vName]
end view_GetMetaData

command view_SetMetaData vName, vMetaArray
   put view_GetFileMetaArray() into metaDataArray
   put vMetaArray into metaDataArray [vName]
   view_SetFileMetaArray metaDataArray
end view_SetMetaData

command view_DeleteMetaData vName
   put view_GetFileMetaArray() into metaDataArray
   delete variable metaDataArray [vName]
   view_SetFileMetaArray metaDataArray
end view_DeleteMetaData

function view_GetFileMetaArray
   put model_GetFileArray ("viewMetaData.array") into viewMetaDataArray
   return viewMetaDataArray
end view_GetFileMetaArray

command view_SetFileMetaArray viewMetaDataArray
   model_SetFileArray "viewMetaData.array", viewMetaDataArray
   put the result into someFile
   return someFile
end view_SetFileMetaArray


--> View | File | Model | Wrappers
-
function view_IconUrl vName, pDontCreate
   put library_TextUrl ("icon.png", vName, "view", pDontCreate) into someUrl
   return someUrl
end view_IconUrl

function view_LocalIconFile vName, pDontCreate
   view_NormalizeName vName
   put library_TextFile ("icon.png", vName, "view", pDontCreate) into localFile
   return localFile
end view_LocalIconFile

command view_DeleteIcon vName
   view_NormalizeName vName
   put library_TextFile ("icon.png", vName, "view", true) into someFile
   delete file someFile
   return someFile
end view_DeleteIcon

function view_GetHelpHtml vName, pOnLineMode
   view_NormalizeName vName
   put library_TextUrl ("help.html", vName, "view", true) into someUrl
   if someUrl is empty then return empty
   put url someUrl into helpHtml
   return helpHtml
end view_GetHelpHtml

on view_SetHelpHtml vName, someHtml, pOnLineMode
   view_NormalizeName vName
   put library_TextUrl ("help.html", vName, "view", false) into someUrl
   if someUrl is not empty then put someHtml into url someUrl
   return someUrl
end view_SetHelpHtml

command view_DeleteHelpText vName
   view_NormalizeName vName
   put library_TextFile ("help.html", vName, "view", true) into someFile
   delete file someFile
   return someFile
end view_DeleteHelpText

function view_GetOld vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isOld"] into someBoolean
   return someBoolean is true
end view_GetOld

command view_SetOld vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isOld"]
   view_SetFileMetaArray metaDataArray
end view_SetOld

function view_GetPublished vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isPublished"] into someBoolean
   return someBoolean is true
end view_GetPublished

command view_SetPublished vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isPublished"]
   view_SetFileMetaArray metaDataArray
end view_SetPublished

function view_GetFavourite vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isFavourite"] into someBoolean
   return someBoolean is true
end view_GetFavourite

command view_SetFavourite vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isFavourite"]
   view_SetFileMetaArray metaDataArray
end view_SetFavourite

function view_GetTested vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isTested"] into someBoolean
   return someBoolean is true
end view_GetTested

command view_SetTested vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isTested"]
   view_SetFileMetaArray metaDataArray
end view_SetTested


--> View | Profile
-
getprop view_Profile
   put the view_Object of the target into viewObject
   if exists(viewObject) is false then return empty
   put the cREVGeneral ["profile"] of viewObject into profileName
   return profileName
end view_Profile

setprop view_Profile profileName
   put the view_Object of the target into viewObject
   if exists(viewObject) is false then return empty
   
   lock screen  
   set the cREVGeneral ["profile"] of viewObject to profileName
   repeat with cNum = 1 to the number of controls of viewObject
      set the cREVGeneral ["profile"] of control cNum of viewObject to profileName
   end repeat
   unlock screen
end view_Profile


--> View | Model | Wrappers
-
/*
These properties are stored as part of a structured array associated with a view.
The array can be sotred with the view, on the card, or with the views behavior (a template_Array).
*/

getprop view_Value [propName]
   put the view_DataArray of the target into viewDataArray
   return viewDataArray [propName]
end view_Value

setprop view_Value [propName] propValue
   put the view_DataArray of the target into viewDataArray
   if propValue is empty then
      delete local viewDataArray [propName]
   else
      put propValue into viewDataArray [propName]
   end if
   set the view_DataArray of the target to viewDataArray
   return viewDataArray
end view_Value

getprop card_ViewValue [propName]
   put the view_DataArray [true] of the target into viewDataArray
   return viewDataArray [propName]
end card_ViewValue

setprop card_ViewValue [propName] propValue
   put the view_DataArray [true] of the target into viewDataArray
   if propValue is empty then
      delete local viewDataArray [propName]
   else
      put propValue into viewDataArray [propName]
   end if
   set the view_DataArray [true] of the target to viewDataArray
   return viewDataArray
end card_ViewValue


--> View | Model
-
/*
There are a number of types of data associated with a view:

1) Metadata associated with a views instance on a card (it's name etc)
2) Data - the actual data displayed by a view
3) Display data controlling how the view dispays data
4) Controller Array

There are also a number of places this data can be stored:

a) associated with a view instance (ie as a named custom propoerty of the card the view is on) (view_Array)
b) as a custom property of the view templates stack (template_Array)
c) as a file (put library_ArrayFolder ("viewMetaDataArray") into someFile)

The template_Array and view_Array can be combined with the view-Array over-ridign the properties of the template_Array (not done yet?)

== Data ==
The data is indexed to view_Name and the short name of the views and not based on their ids
This is in order to allow replacing / updating of views while retaining their pros and data.

== Metadata ==
This is not the uRIP metadata attached to the object,
but the metadata associated with a view template ("class").

We use view_ClassMetaData (for the library object / class), and view_MetaData (for the instance on the card).

Class metadata is stored as a custom property of the library view stack.

== Controller Array ==
Used by event_Trigger handlers like "event_TriggerArray", "controller_Objects" etc

== Display ==
Each view should have it's own display model. 
Deleting a view and replacing / updating it with another view of the same name and type,
should (as far as posible) result in the new / updated view retaining the display properties of the old view.

The data is indexed to view_Name and the short name of the views and not based on their ids
This is in order to allow replacing / updating of views while retaining their pros and data.
The display model is by default stored on the card, and not linked to the id but to the short name of the view.
*/

getprop view_DataArray [pUseCard]
   put the long id of the target into someView
   put the view_Array [pUseCard] of someView into viewArray
   return viewArray ["data"]
end view_DataArray

setprop view_DataArray [pUseCard] dataArray
   put the long id of the target into someView 
   put the view_Array [pUseCard] of someView into viewArray
   put dataArray into viewArray ["data"]
   set the view_Array [pUseCard] of someView to viewArray
end view_DataArray

getprop view_MetaData [pUseCard]
   put the view_Array [pUseCard] of the target into viewArray
   put viewArray ["metadata"] into metaDataArray
   return metaDataArray
end view_MetaData

setprop view_MetaData [pUseCard] metaDataArray
   put the view_Array [pUseCard] of the target into viewArray
   put metaDataArray into viewArray ["metadata"]
   set the view_Array [pUseCard] of the target to viewArray
end view_MetaData

getprop view_ControllerArray [pUseCard]
   -- contains information about the controllers associated with a single view
   put the long id of the target into someView 
   put the view_Array [pUseCard] of someView into viewArray
   return viewArray ["controllers"]
end view_ControllerArray

setprop view_ControllerArray [pUseCard] controllerArray
   -- contains information about the controllers associated with a single view
   put the long id of the target into someView 
   put the view_Array [pUseCard] of someView into viewArray
   put controllerArray into viewArray ["controllers"]
   set the view_Array [pUseCard] of someView to viewArray
   return viewArray
end view_ControllerArray

setprop view_DeleteProperty [pUseCard] someProp
   put the view_DisplayArray [pUseCard] of the target into displayArray
   put displayArray [someProp] into oldValue
   delete local displayArray [someProp]
   set the view_DisplayArray [pUseCard] of the target to displayArray
   return oldValue
end view_DeleteProperty

getprop view_DisplayArray [pUseCard]
   put the long id of the target into someView 
   put the view_Array [pUseCard] of someView into viewArray
   return viewArray ["display"]
end view_DisplayArray

setprop view_DisplayArray [pUseCard] displayArray
   put the long id of the target into someView 
   put the view_Array [pUseCard] of someView into viewArray
   put displayArray into viewArray ["display"]
   set the view_Array [pUseCard] of someView to viewArray
end view_DisplayArray


--> View | Model | Array
-
getprop view_Array [pUseCard]
   if pUseCard is not false then return the view_CardArray of the target
   
   put the view_Object of the target into viewObject
   if exists(viewObject) is empty then return empty
   
   lock messages
   put the view_Array of viewObject into viewArray
   unlock messages
   
   return viewArray
end view_Array

setprop view_Array [pUseCard] viewArray
   if pUseCard is not false then
      set the view_CardArray of the target to viewArray
      return the result
   end if
   
   put the view_Object of the target into viewObject
   if exists(viewObject) is empty then return empty
   
   lock messages
   set the view_Array of viewObject to viewArray
   unlock messages
   
   return viewObject
end view_Array

getprop view_CardArray [pShortName]
   -- stores the info with the card (so replacing views is OK)
   put the view_Object of the target into viewObject
   if viewObject is empty then return empty
   
   if pShortName is empty then put the short name of viewObject into pShortName
   put the card_Object of the target into cardObject
   put the view_Name of viewObject into vName
   
   put the uOPN_NamedViewArray of cardObject into namedViewArray
   put namedViewArray [vName][pShortName] into viewArray
   return viewArray
end view_CardArray

setprop view_CardArray [pShortName] viewArray
   put the view_Object of the target into viewObject
   if viewObject is empty then return empty
   
   if pShortName is empty then put the short name of viewObject into pShortName
   put the card_Object of the target into cardObject
   put the view_Name of viewObject into vName
   
   put the uOPN_NamedViewArray of cardObject into namedViewArray
   put viewArray into namedViewArray [vName][pShortName]
   set the uOPN_NamedViewArray of cardObject to namedViewArray
   return namedViewArray
end view_CardArray


--> View | Model
-
/*
These handlers are the current way views store their metadata.
Eventually the aim is to update this to the way stacks in general store their metadata for any object,
which is based on the standard stack export model (with it's associated metadata folders for each exported object).
These handlers have been place here in order to encourage this migration :)
*/

command view_RenameTemplate oldViewName, newViewName
   view_NormalizeName oldViewName
   view_NormalizeName newViewName
   
   put view_GetTemplateObject (oldViewName) into templateObject
   if exists (templateObject) is false then return "error, cannot locate view tempate for stack" && kwote (oldViewName)
   
   put there is a stack oldViewName and oldViewName begins with "View|" into oldViewStack
   if oldViewStack is false then
      -- lets not rename the stack - but just update the view metadata
      set the view_NewName of templateObject to newViewName
   else
      put the filename of stack oldViewName into oldFile
      
      if there is a stack newViewName then return "error, there is already a stack" && kwote (newViewName)
      put view_NameToFile (newViewName) into newFile
      
      put the short id of templateObject into newTemplateID
      put "control id" && newTemplateID && "of stack" && kwote (newViewName) into newTemplateObject
      put the stack_SubName ["OPN Stack Menus"] of templateObject into subStackName
      
      set the object_IsIndexed of templateObject to false
      
      put the behavior of templateObject into templateBehavior
      if exists (templateBehavior) then
         set the object_IsIndexed of templateBehavior to false
         
         put the stack_Name of templateBehavior into templateStackName
         put the short id of templateBehavior into newBehaviorID
         switch templateStackName
            case oldViewName
               -- it is in the stack of the view being renamed
               put "control id" && newBehaviorID && "of stack" && kwote (newViewName) into newTemplateBehavior
               break
            case subStackName
               -- it is in the sub-stack of the view being renamed
               put newViewName & "|" & "OPN Stack Menus" into newSubStackName
               put "control id" && newBehaviorID && "of stack" && kwote (newSubStackName) into newTemplateBehavior
               break
            default
               -- it is a linked behavior in a stack that is not being renamed
               put templateBehavior into newTemplateBehavior
         end switch
      else
         put empty into newTemplateBehavior
      end if
      
      if exists (stack subStackName) then
         -- lets rename the substack first
         -- first a quick safety check
         put newViewName & "|" & "OPN Stack Menus" into newSubStackName
         if there is a stack newSubStackName then
            -- should not be let's exit
            return "error, for some strange reason there is already a sub-stack" && kwote (newSubStackName)
         end if
         
         -- now rename the substack
         
         set the object_IsIndexed of stack newSubStackName to false
         set the stack_IsKnown of stack subStackName to false
         set the name of stack subStackName to newSubStackName
      end if
      
      -- now rename the mainstack, it's file on disk (keeping it in the same folder), and set the new mainstacks fileName
      set the object_IsIndexed of stack oldViewName to false
      set the stack_IsKnown of stack oldViewName to false
      set the name of stack oldViewName to newViewName
      set the filename of stack newViewName to newFile
      -- file_Rename oldFile, newFile
      rename file oldFile to newFile
      set the stack_IsKnown of stack newViewName to true
      set the object_IsIndexed of stack newViewName to true
      
      if exists (stack newSubStackName) then
         set the stack_IsKnown of stack newSubStackName to true
         set the object_IsIndexed of stack newSubStackName to true
      end if
      
      -- done renaming, lets fix the uRip properties, and update hArray
      set the view_NewName of newTemplateObject to newViewName
   end if
end view_RenameTemplate

setprop view_NewName newViewName
   put the long id of the target into newTemplateObject
   put the view_Name of newTemplateObject into oldViewName
   
   put the object_Metadata of newTemplateObject into newTemplateMetadata
   put newViewName into newTemplateMetadata ["name"]
   -- tidy it up a bit
   put "view" into newTemplateMetadata ["type"] -- just in case
   delete variable newTemplateMetadata ["version"] -- tidy old version stuff
   put pref_GetValue ("username") into newTemplateMetadata ["author"]
   put pref_GetValue ("username") into newTemplateMetadata ["copyright"]
   set the object_Metadata of newTemplateObject to newTemplateMetadata
   set the object_IsIndexed of newTemplateObject to true
   
   put the behavior of newTemplateObject into newTemplateBehavior
   if exists (newTemplateBehavior) then
      put the object_Metadata of newTemplateBehavior into newBehaviorMetadata
      put newViewName into newBehaviorMetadata ["name"]
      
      -- tidy it up a bit
      put "view behavior" into newBehaviorMetadata ["type"] -- just in case
      delete variable newBehaviorMetadata ["version"] -- tidy old version stuff
      put pref_GetValue ("username") into newBehaviorMetadata ["author"]
      put pref_GetValue ("username") into newBehaviorMetadata ["copyright"]
      
      set the object_Metadata of newTemplateBehavior to newBehaviorMetadata
   end if
   
   put library_TextFolder (oldViewName, "view", true) into oldMetaDataFolder
   put library_TextFolder (newViewName, "view", true) into newMetaDataFolder
   if there is a folder oldMetaDataFolder and there is not a folder newMetaDataFolder then
      rename folder oldMetaDataFolder to newMetaDataFolder
   end if
end view_NewName

command view_DeleteTemplate vName
   view_NormalizeName vName
   if there is a stack vName then
      put the filename of stack vName into someFile
      delete stack vName
   else
      put view_NameToFile (vName) into someFile
   end if
   
   if there is a file someFile then delete file someFile
   view_DeleteMetaData vName
   view_DeleteHelpText vName
   view_DeleteIcon vName
   return someFile
end view_DeleteTemplate

command view_CreateIcon libraryView, pIconView
   if exists(libraryView) is false then
      beep
      opn_Notify "Library (mTarget) view does not exist!"
      exit to top
   end if
   
   get the mobile_Name of libraryView
   put the rect of libraryView into someRect
   put rect_SubtractMargin (-2, someRect) into someRect
   
   put the view_IconFile [false] of libraryView into imageFile
   
   set the wholeMatches to true
   put the stack_Name of libraryView into stackName
   put stackName is among the lines of the openstacks into stackOpen
   if stackOpen is false then object_GoTo libraryView
   
   switch pIconView
      case empty
         put the windowid of stack stackName into someWindowID
         export snapshot from rect someRect of window someWindowID to file imageFile as PNG
         break
      default
         put the width of pIconView & comma & the height of pIconView into iconDimensions
         export snapshot from libraryView at size iconDimensions to iconImage as PNG
         if iconImage is not empty then
            put iconImage into url ("binfile:" & imageFile)
            set the image_File of pIconView to imageFile
         end if
   end switch
   
   if stackOpen is false then close stack stackName
   return imageFile
end view_CreateIcon

getprop view_IconFile [pDontCreate]
   put the view_Name of the target into vName
   put view_LocalIconFile (vName, pDontCreate) into imageFile
   return imageFile
end view_IconFile



--> Private
-
private command view_TrimFirstViewNameItem @vNames
   put replacetext (vNames, "(View\|)\W*", empty) into vNames
   return empty
   
   set the itemdelimiter to "|"
   repeat with lineNum = 1 to the number of lines of vNames
      delete item 1 of line lineNum of vNames 
   end repeat
end view_TrimFirstViewNameItem
