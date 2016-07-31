script "behavior_ViewRecordDescription"
--> MetaData
-
license: GPLv3
name: behavior_ViewRecordDescription
type: behavior
version: 0.6

/*
A view with a title, an extra single line field and a scroling text field
*/

--> Events | Datagrid
-
on FillInData pDataArray
   put the long id of me into recordView
   put the dgControl of me into dgView
   
   put the event_Watchers ["FillInData"] of dgView into controllerObjects
   if controllerObjects is empty then
      dispatch "dg_FillInData" to dgView with pDataArray,recordView
   else
      repeat for each line controllerObject in controllerObjects
         dispatch "dg_FillInData" to controllerObject with pDataArray,recordView
      end repeat
   end if
end FillInData

on CloseFieldEditor pFieldEditor
   put the long id of me into recordView
   -- put the dgControl of me into dgView
   
   put the event_Watchers ["CloseFieldEditor"] of me into controllerObjects
   if controllerObjects is empty then
      dispatch "dg_CloseFieldEditor" to recordView with pFieldEditor,recordView
      -- dispatch "closefield" to the dgControl of me -- resets the target so useless dgView needs to pass!
   else
      repeat for each line controllerObject in controllerObjects
         dispatch "dg_CloseFieldEditor" to controllerObject with pFieldEditor,recordView
      end repeat
   end if
   pass CloseFieldEditor
end CloseFieldEditor

on resizeControl
    put the rect of me into someRect
    LayoutControl someRect
end resizeControl

-- setprop view_Rect someRect
   LayoutControl someRect
end view_Rect

on LayoutControl someRect
   lock screen
   
   put the drag_Button of me into scriptButton
   put title_Field() into titleField
   put the disclosure_Button of me into disclosureButton
   put graphic_Background() into graphicBackground
   
   put the info_Group of me into infoGroup
   
   put the view_Spacing of me into someMargin
   put the info_Height of me into infoHeight
   
   put rect_SubtractMargin(someMargin, someRect) into innerRect
   put the title_Height of titleField into headerHeight
   if headerHeight is empty then
      -- put the height of titleField into headerHeight
      put 18 into headerHeight
   end if
   
   put innerRect into headerRect
   put item 2 of headerRect + headerHeight into headerBotton
   put headerBotton into item 4 of headerRect
   
   put headerRect into rightButtonRect
   put item 3 of headerRect - headerHeight into rightButtonLeft
   put rightButtonLeft into item 1 of rightButtonRect
   
   put rect_SubtractMargin(3, rightButtonRect) into rightButtonRect
   
   put headerRect into leftButtonRect
   put item 1 of headerRect + headerHeight into leftButtonRight
   put leftButtonRight into item 3 of leftButtonRect
   
   put headerRect into titleRect
   put leftButtonRight + someMargin into item 1 of titleRect
   put rightButtonLeft - someMargin into item 3 of titleRect
   
   if the visible of infoGroup is true then
      put innerRect into infoRect
      put headerBotton + someMargin into bodyTop
      put bodyTop into item 2 of infoRect
      put leftButtonRight + someMargin into item 1 of infoRect
      put bodyTop + infoHeight into item 4 of infoRect
      
      put someRect into graphicRect
      put item 4 of infoRect + someMargin into item 4 of graphicRect
      -- rect_CreateMask graphicRect, "graphicRect"
      
      set the view_Rect of infoGroup to infoRect
      -- rect_CreateMask infoRect, "infoRect"
   else
      put someRect into graphicRect
      put headerBotton + someMargin into item 4 of graphicRect
   end if
   
   set the rect of titleField to titleRect
   set the rect of disclosureButton to leftButtonRect
   set the rect of scriptButton to rightButtonRect
   set the rect of graphicBackground to graphicRect
   
   unlock screen
end LayoutControl

on DiscloseView someBoolean
   -- sent on mouseDown by View|Button|Disclose|Down   
   put the dgLine of me into vLineNum
   if vLineNum is empty then
      -- view is not inside a datagrid
      -- lets do a toggle for show
      set the record_IsExpanded of me to not the record_IsExpanded of me
   else
      put the dgDataOfLine [vLineNum] of me into recordArray
      if the shiftKey is "Up" then
         put someBoolean into recordArray ["isExpanded"]
         set the dgDataOfLine [vLineNum] of me to recordArray
      else
         put the dgControl of me into dgView
         put the dgData of dgView into dataArray
         repeat for each key indexNum in dataArray
            put someBoolean into dataArray [indexNum]["isExpanded"]
         end repeat
         -- send "set the dgData of dgView to dataArray" to me in 0 ticks
         send "dg_SetDataArray dataArray" to me in 0 ticks
      end if
   end if
end DiscloseView


--> Events
-
on mouseDoubleUp pMouseBtnNum
   if pMouseBtnNum is 1 then
      put the dgControl of me into dgView
      if exists(dgView) is false then return false
      
      if the dgProps["allow editing"] of dgView then
         put the long id of the target into targetObject
         put the short name of targetObject into theKey
         put the dgIndex of me into indexNum
         
         switch
            case theKey is among the items of "help"
               EditFieldText targetObject, indexNum, theKey
               break
            case word 1 of targetObject is "player"
               -- display_Movie
               break
            default
               put the linked_Template of me into templateView
               object_GoTo templateView
         end switch
      end if
   end if
   pass mouseDoubleUp
end mouseDoubleUp

on mouseDown
   set the dgHilitedLine of me to the dgLine of me
   put the dgControl of me into dgView
   if exists(dgView) then
      put the event_Watchers ["mouseDown"] of dgView into eventWatchers
      if eventWatchers is not empty then
         beep
         return empty
      end if
   end if
   
   put the long id of the target into targetObject
   put the short name of targetObject into shortName
   switch
      case shortName = "Script"
         put the record_ImageID of me into imageID
         _startDrag
         break
      case shortName = "Title"
         if the clicktext is not empty then menu_PullDown
         break
      case word 1 of targetObject is "player"
         put the short id of targetObject into playerID
         get the paused of player id playerID
         if it is true then
            start player id playerID
         else
            stop player id playerID
         end if
         break
      case shortName = "Image"
         put the short id of targetObject into imageID
         _startDrag imageID
         break
      default
         -- opn_Notify the short name of the target
         pass mouseDown
   end switch
end mouseDown

command _startDrag pImageID
   -- drag_View viewName
   if pImageID is not empty then
      set the dragImage to pImageID
   end if
   put the record_Name of me into viewName
   set the dragdata ["private"] to viewName
   drag_SetGlobalStatus true
end _startDrag

on drag_SetGlobalStatus isTrue
    global OPN
    put isTrue into OPN ["Global_Drag"]
end drag_SetGlobalStatus

on mouseUp
   put the dgControl of me into dgView
   if exists(dgView) then
      put the event_Watchers ["mouseUp"] of dgView into eventWatchers
      if eventWatchers is not empty then
         beep
         return empty
      end if
   end if
   
   put the long id of the target into targetObject
   put the short name of targetObject into shortName
   switch
      case shortName = "Script"
         break
      case shortName = "Title"
         break
      case shortName = "Image"
         put the record_Name of me into viewName
         break
      default
         -- opn_Notify the short name of the target
         pass mouseUp
   end switch
end mouseUp


--> Controls
-
getprop viewDescription_Record
   return the long id of me
end viewDescription_Record

getprop view_Object
   return the long id of me
end view_Object

getprop dgDataControl
   -- Required by library so that it can locate your control.
   return the long id of me
end dgDataControl

getprop linked_Template
   put the record_Name of me into vName
   put view_GetTemplateObject (vName) into viewTemplate
   return viewTemplate
end linked_Template


--> Datagrid
-
setprop dgHilite someBoolean
   -- opn_Notify (someBoolean,the short id of me), true
   put the dgControl of me into dgView
   put _ColourMe (someBoolean) into mainColour
   put colour_Darken (mainColour, 5) into darkColour
   
   set the backgroundcolor of graphic_Background() to mainColour
   set the backgroundcolor of the info_Group of me to darkColour
end dgHilite

private function _ColourMe someBoolean
   put the linked_Template of me into viewTemplate
   if exists(viewTemplate) is false then
      return "red"
   else  
      put the behavior of viewTemplate into templateBehavior
      if exists(templateBehavior) is true then
         if the stack_Object of viewTemplate is the stack_Object of templateBehavior then
            if someBoolean then
               put the dgProps ["hilite color"] of the dgControl of me into onColour
               if onColour is empty then put the hilitecolor into onColour
               return onColour
            else
               put the dgProps ["row color"] of the dgControl of me into offColour
               if offColour is empty then put the effective backgroundcolor of me into offColour
               return offColour
            end if
         else
            return "light blue"
         end if
      else
         return "light green"
      end if
   end if
end _ColourMe


--> Record
-
getprop background_Colour
   return the backgroundcolor of graphic_Background()
end background_Colour

setprop background_Colour newColour
   set the backgroundcolor of graphic_Background() to newColour
end background_Colour

getprop record_InfoViewName
   put the info_Group of me into infoGroup
   return the view_Name of infoGroup
end record_InfoViewName

setprop record_InfoViewName viewName
   put the info_Group of me into infoGroup
   set the view_Swap of infoGroup to viewName
   return the result
end record_InfoViewName

getprop record_Name
   put title_Field() into titleField
   put the text of titleField into recordName
   return recordName
end record_Name

setprop record_Name someName
   put title_Field() into titleField
   set the text of titleField to someName
end record_Name


--> Record | Movie
-
getprop record_ImageID
   put the info_Group of me into infoGroup
   return the image_ID of infoGroup
end record_ImageID

getprop record_ImageContents
   put the info_Group of me into infoGroup
   return the image_Contents of infoGroup
end record_ImageContents

setprop record_ImageContents someImage
   put the info_Group of me into infoGroup
   set the image_Contents of infoGroup to someImage
end record_ImageContents

getprop record_ImageFile
   put the info_Group of me into infoGroup
   return the image_File of infoGroup
end record_ImageFile

setprop record_ImageFile imageFile
   put the info_Group of me into infoGroup
   set the image_File of infoGroup to imageFile
end record_ImageFile


--> Record | Movie
-
getprop record_MovieFile
   put the info_Group of me into infoGroup
   return the movie_File of infoGroup
end record_MovieFile

setprop record_MovieFile movieFile
   put the info_Group of me into infoGroup
   set the movie_File of infoGroup to movieFile
end record_MovieFile


--> Record | Description
-
getprop record_HelpHtml
   put the image_Description of the info_Group of me into displayedHelpHtml
   return displayedHelpHtml
end record_HelpHtml

setprop record_HelpHtml someHtml
   set the image_Description of the info_Group of me to someHtml
end record_HelpHtml


--> Geometry
-
getprop view_Spacing
   put the uOPN ["view_Spacing"] of me into viewSpacing
   if viewSpacing is not a number then put the view_DefaultSpacing of me into viewSpacing
   if viewSpacing is empty then put 2 into viewSpacing
   -- opn_Notify viewSpacing
   return viewSpacing
end view_Spacing

setprop view_Spacing pixelNum
   set the uOPN ["view_Spacing"] of me to pixelNum
end view_Spacing

getprop formatted_Height
   if the long id of the target = the long id of me then
      put title_Field() into titleField
      -- put the margins of me into someMargin
      -- margin_Normalize someMargin, lMargin, tMargin, rMargin, bMargin
      return the formattedheight of titleField -- + tMargin + bMargin
   else
      -- blocks something higher up interfering
      return empty
   end if
end formatted_Height

getprop info_Height
   put the info_Group of me into infoGroup
   put the formatted_Height of infoGroup into infoHeight
   if infoHeight is empty then
      return 80
   else
      return infoHeight
   end if
end info_Height


--> Geometry | Disclose
-
setprop record_IsExpanded someBoolean
   lock screen
   put the rect of me into oRect
   set the visible of the info_Group of me to someBoolean
   LayoutControl oRect
   set the disclosure_Status of the disclosure_Button of me to someBoolean
   unlock screen
end record_IsExpanded

getprop record_IsExpanded
   return the visible of the info_Group of me
end record_IsExpanded


--> Objects
-
getprop dg_TopDataControl
   -- allows nesting of dgDataControls
   -- the dgControl can then refer only to the dg_TopDataControl's to do it's thing
   put the long id of me into topRecordView
   repeat
      put topRecordView into nextRecordView
      delete word 1 to 4 of nextRecordView
      put the dgDataControl of nextRecordView into nextRecordView
      if nextRecordView is empty then
         -- put the mobile_Name of topRecordView into topRecordView
         return topRecordView
      end if
      put nextRecordView into topRecordView
   end repeat
   return empty
end dg_TopDataControl


--> View | Objects
-
getprop info_Group
   put the long id of control "Info" of me into infoGroup
   return infoGroup
end info_Group

getprop disclosure_Button
    return the long id of btn "Disclosure" of me
end disclosure_Button

getprop drag_Button
   return the long id of btn "Script" of me
end drag_Button


--> Controls | Private
-
private function title_Field
    return the long id of field "title" of me
end title_Field

private function graphic_Background
   return the long id of grc "Background" of me
end graphic_Background


--> Library | Deps
-
function colour_Darken rgbColour, pDarkenPercent
   if rgbColour is empty then put "256,256,256" into rgbColour
   colour_RgbNormalise rgbColour
   if pDarkenPercent is empty then put 10 into pDarkenPercent
   put colour_RgbToHSV (rgbColour) into hsvColour
   put (100 - pDarkenPercent)/100 * item 3 of hsvColour into darkerV
   put min (darkerV, 100) into darkerV
   put max (darkerV, 0) into darkerV
   put darkerV into item 3 of hsvColour
   put colour_HsvToRgb (hsvColour) into newRgbColour
   
   -- return rgbColour
   return newRgbColour
end colour_Darken

function rect_SubtractMargin someMargin, someRect
   margin_Normalize someMargin, lMargin, tMargin, rMargin, bMargin   
   add lMargin to item 1 of someRect
   add tMargin to item 2 of someRect
   subtract rMargin from item 3 of someRect
   subtract bMargin from item 4 of someRect
   return someRect
end rect_SubtractMargin
