script "behavior_FedwikiOverides"
--> MetaData
-
license: GPLv3
name: behavior_FedwikiOverides
type: behavior
version: 0.1


--> Fedwiki | Overrides
-
-- command fedwiki_ReturnError someValue, errorText
-- but here we override it (as it needs to then call fedwiki_ReturnJSON below)
if someValue is empty then
   put fedwiki_ConstructErrorJSON (errorText) into errorJSON
   fedwiki_ReturnJSON errorJSON
   exit to top
end if
end fedwiki_ReturnError

before fedwiki_ReturnJSON pageJSON
   -- this would normally return pageJSON back to the Fedwiki client
   -- but here we override it
   -- could be a front script
   
   if the shiftkey is "Down" then put pageJSON
   put json_ToArray (pageJSON) into pageArray
   display_Array pageArray, "fedwiki_ReturnJSON()"
   exit to top
end fedwiki_ReturnJSON
