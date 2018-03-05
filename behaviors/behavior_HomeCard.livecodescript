script "behavior_HomeCard"
--> MetaData
-
license: GPLv3
name: behavior_HomeCard
type: behaviors
version: 0.2

/*
The idea here is to create a generic behavior for "home" stack displays.
So that we can present easily new and different interactive content on a per-project basis.
For now we simply show a browser widget.
*/


--> Events
-
on resizeStack
   set the rect of widget 1 of me to the rect of this card
end resizeStack

on commandKeyDown whichKey
   put the long id of widget "Home Browser" of me into browserWidget
   switch whichKey
      case 1
         put "http://google.com" into someURL
         break
      case 2
         go back in widget "Home Browser" of me
         break
      case 3
         go forward in widget "Home Browser" of me
         break
      case 4
         put "http://future.fedwiki.org" into someURL
         break
      case 5
         -- put "https://vector.im/beta/#/room/#fedwiki:matrix.org" into someURL
         put "https://vector.im/beta" into someURL
         -- put url_EncodeUrlPaths (someURL) into someURL
         -- put someURL
         break
      default
         if the shiftkey is "Down" then put the params
         pass commandKeyDown
   end switch
   set the url of browserWidget to someURL
end commandKeyDown


--> Deps
-
private function url_EncodeUrlPaths someURL
   -- https://vector.im/beta/#/room/#fedwiki:matrix.org
   -- https://vector.im/beta/%23/room/%23fedwiki%3Amatrix.org
   set the itemdelimiter to "/"
   repeat with itemNum = 3 to the number of items of someURL
      put item itemNum of someURL into someItem
      replace space with "%20" in someItem
      put urlencode (someItem) into item itemNum of someURL
   end repeat
   return someURL
end url_EncodeUrlPaths
