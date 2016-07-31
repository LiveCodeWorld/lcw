script "Global_revIgniter_Remote_Menu"
--> MetaData
-
license: GPLv3
name: Global_revIgniter_Remote_Menu
type: controller
version: 0.1


--> Global | revIgniter | Remote | Menu
-
on menu_TestLocalTransporter hKey
   set the behavior of stack "lib_Fedwiki" to the long id of stack "behavior_FedwikiOverides"
   --
   
   put item 1 of hKey into controllerHandler
   put item 3 of hKey into stackObject
   
   put fedwiki_GetDroppedUrl() into droppedURL
   dispatch controllerHandler to stackObject
   
   --
   set the behavior of stack "lib_Fedwiki" to empty
end menu_TestLocalTransporter

on menu_TestRemoteTransport hKey
   put item 1 of hKey into controllerHandler
   put item 3 of hKey into stackObject
   put the short name of stackObject into controllerName
   put liveworld_ConstructControllerUrl (controllerName, controllerHandler) into restURL
   
   put fedwiki_GetDroppedUrl() into droppedURL
   fedwiki_PostJSON $_POST_RAW, restURL
   put the result into pageJSON
   
   put json_ToArray (pageJSON) into pageArray
   if pageArray is an array then
      display_Array pageArray
   else
      -- an error (not json)
      put pageJSON
   end if
end menu_TestRemoteTransport

on _
end _

on menu_GraphTransporter hKey
   put item 3 of hKey into scriptObject
   display_IndexScriptAndDisplaySVG scriptObject, "LCW"
end menu_GraphTransporter


--> Fedwiki | Utils
-
function fedwiki_GetDroppedUrl
   -- this would normally parse $_POST_RAW
   -- but here we override it
   put the fedwiki_DroppedURL of stack "Transporter Drop Urls" into droppedURL
   put fedwiki_ConstructDroppedJSON (droppedURL) into $_POST_RAW
   return droppedURL
end fedwiki_GetDroppedUrl
   
command fedwiki_PostJSON someJSON, restURL
   set the httpheaders to "Content-Type: application/json" -- required for revIgnitor
   post someJSON to url restURL
   put it into jsonResult
   if the shiftKey is "Down" then put restURL
   return jsonResult
end fedwiki_PostJSON

function fedwiki_ConstructDroppedJSON droppedURL
   /*
   •	{"text":"https://media.ccc.de/v/32c3-7403-a_new_kid_on_the_block#video","html":""}
   */
   put droppedURL into dropArray ["text"]
   put empty into dropArray ["html"]
   put json_FromArray (dropArray) into someJSON
   return someJSON
end fedwiki_ConstructDroppedJSON


--> LiveWorld
-
function liveworld_ConstructControllerUrl controllerName, shortControllerFile
   set the itemdelimiter to "."
   put item 1 of shortControllerFile into restPath
   put "https://" & server_GetURL() & "/" into restURL
   
   set the itemdelimiter to "."
   put item 1 of controllerName after restURL
   
   switch restPath
      case empty
      case "index"
         return restURL
      default
         put "/" &  restPath after restURL
         return restURL
   end switch
end liveworld_ConstructControllerUrl

command liveworld_SaveHTML someHTML
   -- but here we override it
   put the tempname & ".html" into someFile
   put ("file:" & someFile) into someUrl
   put someHTML into url someUrl
   launch url someUrl
   return someUrl
end liveworld_SaveHTML

function liveworld_FetchTemplate pTemplateName
   -- but here we override it
   put url "https://www.livecode.world/index_template.html" into someTemplate
   return someTemplate
end liveworld_FetchTemplate
