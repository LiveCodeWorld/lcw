script "lib_Gitter"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Gitter
type: script library
version: 0.3

/*
A library for interfacing with Gitter via GitHub APIv3.
*/

constant GitterApiStem = "https://api.gitter.im/v1/"

function gitter_FetchMyRooms
   -- curl -i -H "Accept: application/json" -H "Authorization: Bearer 6de5229ab216b137776afd3f0e0da393400f4481" 
   -- "https://api.gitter.im/v1/user/54cfdaf2db8155e6700f5d5d/rooms"
   
   put gitter_MyUserID() into userID
   put "user/" & userID & "/rooms" into someCommand
   put gitter_RestfulGet (someCommand) into jsonResult
   return jsonResult
end gitter_FetchMyRooms

function gitter_FetchMyUserArray
   -- curl -i -H "Accept: application/json" -H "Authorization: Bearer 6de5229ab216b137776afd3f0e0da393400f4481" "https://api.gitter.im/v1/user"  
   put gitter_RestfulGet ("user") into jsonResult
   return jsonResult
end gitter_FetchMyUserArray

function gitter_RestfulGet someCommand
   put GitterApiStem & someCommand into someUrl
   gitter_SetAuthHeaders
   put url someUrl into userJson
   put json_ToArray (userJson) into userArray
   return userArray
end gitter_RestfulGet

command gitter_SetAuthHeaders
   local someHeader
   put gitter_GetApiToken() into gitterApiToken
   -- http_SetBasicAuthentication "Bearer", somePassWord, moreHeaders
   put "Content-Type: application/json" & CR after someHeader
   put "Accept: application/json" & CR after someHeader
   put "Authorization: Bearer" && gitterApiToken & CR after someHeader
   -- put "Host: api.gitter.im" into someHeader
   
   delete char -1 of someHeader
   set the httpheaders to someHeader
end gitter_SetAuthHeaders
