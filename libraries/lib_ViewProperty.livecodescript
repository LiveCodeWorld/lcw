script "lib_ViewProperty"
--> MetaData
-
license: GPLv3
name: lib_ViewProperty
type: library
version: 0.1


--> Template | Property Menu
-
getprop template_PropertyMenu [pFetchLive]
   if pFetchLive is true then
      local liveMenu, publicProps
      put the view_Template of the target into templateObject
      extractViewPropertyMenu templateObject, liveMenu, publicProps
      return liveMenu
   else
      put the template_Array of the target into templateArray
      put the uOPN_ViewArray of templatePropertyModel into templateArray
      put templateArray ["metadata"]["view_PropertyMenu"] into cachedMenu
      return cachedMenu
   end if
end template_PropertyMenu

setprop template_PropertyMenu cachedMenu
   put the template_Array of the target into templateArray
   put the uOPN_ViewArray of templatePropertyModel into templateArray
   put cachedMenu into templateArray ["metadata"]["view_PropertyMenu"]
   set the uOPN_ViewArray of templatePropertyModel to templateArray
   return templateArray
end template_PropertyMenu

function template_GetPropertyMenu vName, pFetchLive
   if exists (stack vName) is false then return empty
   put the name of stack vName into templatePropertyModel
   
   put the uOPN_ViewArray of templatePropertyModel into templateArray
   put templateArray ["metadata"]["view_PropertyMenu"] into cachedMenu
   
   if cachedMenu is empty or pFetchLive is true then
      local liveMenu, publicProps
      put view_GetTemplateObject (vName) into templateObject
      extractViewPropertyMenu templateObject, liveMenu, publicProps
      return liveMenu
   else
      return cachedMenu
   end if
end template_GetPropertyMenu

getprop view_HasProp [propName]
   put the view_Props of the target into viewProps
   return propName is among the lines of viewProps
end view_HasProp

getprop view_Props [fetchLive]
   put the template_MetaData ["view_Props"] of the target into cachedProps
   if cachedProps is empty or fetchLive is true then
      local liveMenu, publicProps
      put the long id of the target into targetObject
      extractViewPropertyMenu targetObject, liveMenu, publicProps
      return publicProps
   else
      return cachedProps
   end if
end view_Props

setprop view_Props viewProps
   set the template_MetaData ["view_Props"] of the target to viewProps
   return the result
end view_Props

getprop view_PropertyMenu [fetchLive]
   put the template_MetaData ["view_PropertyMenu"] of the target into cachedMenu
   if cachedMenu is empty or fetchLive is true then
      local liveMenu, publicProps
      put the long id of the target into targetObject
      extractViewPropertyMenu targetObject, liveMenu, publicProps
      return liveMenu
   else
      return cachedMenu
   end if
end view_PropertyMenu

setprop view_PropertyMenu cachedMenu
   set the template_MetaData ["view_PropertyMenu"] of the target to cachedMenu
   return the result
end view_PropertyMenu

getprop view_LivePropertyMenu
   put the long id of the target into targetObject
   local liveMenu, publicProps
   extractViewPropertyMenu targetObject, liveMenu, publicProps
   return liveMenu
end view_LivePropertyMenu

getprop view_PropertyMenuIsCached
   put the template_MetaData of the target into metaArray
   put keys(metaArray) into metaKeys
   set the wholematches to true
   return "view_PropertyMenu" is among the lines of metaKeys
end view_PropertyMenuIsCached

setprop view_PropertyMenuIsCached someBoolean
   set the cursor to watch -- this can take a long time
   put the long id of the target into targetObject
   if someBoolean is true then
      local liveMenu, publicProps
      extractViewPropertyMenu targetObject, liveMenu, publicProps
      set the view_Props of the target to publicProps
      set the template_MetaData ["view_PropertyMenu"] of targetObject to liveMenu
      return liveMenu
   else
      -- set the view_PropertyMenu of targetObject to empty
      set the template_MetaData ["view_PropertyMenu"] of targetObject to empty
      set the view_Props of the target to empty
      return empty
   end if
end view_PropertyMenuIsCached

getprop script_PublicProps
   local propMenu, publicProps
   put the long id of the target into scriptObject
   
   extractViewPropertyMenu scriptObject, propMenu, publicProps
   sort publicProps
   return publicProps
end script_PublicProps

command view_DoPropertyMenu viewPropPath, someView
   menu_SetChoice viewPropPath, publicProp, publicValue
   if publicValue is empty then
      put view_AskPublicValue (publicProp, someView) into publicValue
      set the publicProp of someView to publicValue
   else
      -- if publicValue is not an "s", or perhaps a switch
      -- lets check by introspecting the script and checking the name of the param
      put the view_BehaviorScript of someView into viewBehaviorScript
      put script_GetSetProp (publicProp, viewBehaviorScript) into propHandler
      if propHandler is empty then
         -- check to see if it is OK, then continue
         breakPoint
      end if
      
      script_DeconstructSetPropHandler propHandler, handlerName, setPropValue, setPropParam
      if setPropParam = empty then
         set the publicProp of someView to publicValue
      else
         view_DoParamProp someView, publicProp, publicValue
      end if
   end if
end view_DoPropertyMenu

command menu_SetChoice menuChoice, @mainChoice, @secondChoice
   -- bug - needs to take account of quoted things like stack names with "|" in their name.
   text_StarQuoted menuChoice
   put the result into replacedArray
   put replacedArray ["original text"] into oText
   
   put line 1 of menuChoice into menuChoice
   set the itemdelimiter to "|"
   put the number of chars of item 1 of menuChoice into firstLength
   put char 1 to firstLength of oText into mainChoice
   
   put firstLength + 2 into secondStart
   put char secondStart to -1 of oText into secondChoice
end menu_SetChoice


--> Private
-
private command extractViewPropertyMenu someView, @propMenu, @publicProps  
   put empty into propMenu
   put empty into publicProps
   put the view_BehaviorScript of someView into viewBehaviorScript
   
   put viewBehaviorScript into setPropLines
   filter setPropLines with "setprop *"
   
   put viewBehaviorScript into getPropLines
   filter getPropLines with "getprop *"
   repeat for each line scriptLine in getPropLines
      put word 2 of scriptLine into gProp
      put gProp & CR after getProps
   end repeat
   delete char -1 of getProps
   
   set the wholeMatches to true
   sort setPropLines
   repeat for each line scriptLine in setPropLines
      put word 2 of scriptLine into someProp
      
      if someProp is among the items of "view_Rect" then next repeat
      if someProp is among the lines of foundProps then next repeat
      if someProp is not among the lines of getProps then next repeat
      
      put someProp & CR after foundProps
      try
         put someProp & CR after publicProps
         put someProp & CR after propMenu
         put word -1 of line 1 of scriptLine into setPropParam
         if setPropParam is among the items of "boolean,someBoolean" then
            get the someProp of someView
            if it is true then
               put tab & "!ctrue" & CR & tab & "false" & CR after propMenu
            else if it is false then
               put tab & "true" & CR & tab & "!cfalse" & CR after propMenu
            else -- could be empty ?
               put "(" before line -1 of propMenu
               put tab & "true" & CR & tab & "false" & CR after propMenu
            end if
         else
            if char - 1 of someProp = "y" then
               put char 1 to -2 of someProp & "ies" into somePropChoice
            else
               put someProp & "s" into somePropChoice
            end if
            
            if somePropChoice is among the lines of getProps then
               put the somePropChoice of someView into subMenu
            else
               put script_ExtractSetpropConditions (someProp, viewBehaviorScript) into subMenu
            end if
            
            if subMenu is not empty then
               replace comma with CR in subMenu
               put the someProp of someView into someMenuItem
               menu_SetCheckedItem someMenuItem, subMenu, true
               put outline_IncreaseIndent (subMenu, 1) & CR after propMenu
            end if
         end if
      catch someError
         put "(" before line -1 of propMenu
      end try
   end repeat
   delete char -1 of propMenu
   delete char -1 of publicProps
   return propMenu
end extractViewPropertyMenu
