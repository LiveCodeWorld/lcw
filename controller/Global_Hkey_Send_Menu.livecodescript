script "Global_Hkey_Send_Menu"
--> MetaData
-
license: GPLv3
name: Global_Hkey_Send_Menu
type: controller
version: 0.3

local LocalArray


--> Global | Hkey | Send | Menu
-
on menu_SendCommand mTarget
   put LocalArray ["hKey"] into hKey
   put LocalArray ["someHandler"] into someHandler
   put LocalArray ["scriptObject"] into hObject
   
   put line 1 of someHandler into handlerLine
   put item 1 of hKey into hName
   if word 1 of handlerLine is "function" then
      -- get value("MyFunction()", the long id of button "Function Library")
      put hName & "()" into someFunction
      put value (someFunction, hObject)
   else
      dispatch hName to hObject
   end if
end menu_SendCommand

on menu_EvaluateFunction mTarget
   put LocalArray ["hKey"] into hKey
   put LocalArray ["someHandler"] into someHandler
   put LocalArray ["scriptObject"] into hObject
   
   put line 1 of someHandler into handlerLine
   put item 1 of hKey into hName
   if word 1 of handlerLine is "function" then
      if the number of words of handlerLine = 3 then
         put opn_Ask ("Give this function a value", empty) into paramValue
         put hName & "(" & kwote(paramValue) & ")" into someFunction
      else
         -- get value("MyFunction()", the long id of button "Function Library")
         put hName & "()" into someFunction
      end if
      put value (someFunction, hObject)
   else
      dispatch hName to hObject
   end if
end menu_EvaluateFunction


--> Global | Hkey | Send | Menu | Props
-
getprop disabled_SendCommand [mTarget]
   put LocalArray ["someHandler"] into someHandler
   put line 1 of someHandler into handlerLine
   switch
      case word 1 of handlerLine = "function"
         return "delete"
      case word 1 of handlerLine = "private"
         return "delete"
      case the number of words of handlerLine > 2
         return true
      default
         return false
   end switch
end disabled_SendCommand

getprop disabled_EvaluateFunction [mTarget]
   put LocalArray ["someHandler"] into someHandler
   put line 1 of someHandler into handlerLine
   switch
      case word 1 of handlerLine = "on"
         return "delete"
      case word 1 of handlerLine = "command"
         return "delete"
      case word 1 of handlerLine = "private"
         return "delete"
      case the number of items of handlerLine = 1
         -- the number of words of handlerLine > 2
         return false
      default
         return true
   end switch
end disabled_EvaluateFunction


--> Menu | Props
-
on menu_Init targetObject, mPath, mTitlePath
   put rev_GetHandlerTreeSelectedInfo() into hInfo
   put word 1 of hInfo into hType
   switch hType
      case "M"
         put "c" into hType
         break
      default
   end switch
   put word 2 of hInfo into hName
   put word 3 of hInfo into startLineNum
   put word 4 of hInfo into endLineNum
   put rev_ScriptObject() into hObject
   put hName,hType,hObject,1 into hKey
   
   put hKey into LocalArray ["hKey"]
   put hObject into LocalArray ["scriptObject"]
   put startLineNum into LocalArray ["startLineNum"]
   put endLineNum into LocalArray ["endLineNum"]
   put line startLineNum to endLineNum of the script of hObject into LocalArray ["someHandler"]
   
   put library_HandlerFile (hKey, empty, true) into LocalArray ["hkeyFolder"]
   
   put hArray_ListHkeyObjects (hKey) into otherObjects
   line_Delete hObject, otherObjects
   put word 1 to -1 of otherObjects into LocalArray ["other objects"]
end menu_Init
