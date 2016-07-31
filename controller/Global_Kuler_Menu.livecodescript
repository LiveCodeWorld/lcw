script "Global_Kuler_Menu"
--> MetaData
-
license: GPLv3
name: Global_Kuler_Menu
type: controller
version: 0.1


--> Menu | Props
-
getprop menu_Target [mTitlePath]
   set the itemdelimiter to "|"
   switch
      case mTitlePath contains "Global | Kuler | Menu"
         put the card_View ["View|Rev|Datagrid"] of me into dgView
         return dgView
      case mTitlePath contains "Global | Kuler | Title | Menu"
         put menu_GetTargetObject() into targetObject
         put the dgDataControl of targetObject into recordView
         if exists(recordView) is false then
            opn_Notify "mTarget is not a dgDataControl!", true
            return empty
         end if
         return recordView
      case mTitlePath contains "Global | Image | Data | Menu"
         put "View|Image|OPN Image" into viewName
         put view_GetTemplateObject (viewName) into imageView
         return imageView
      default
         -- return the long id of grp "Swatches" 
         pass menu_Target
   end switch
end menu_Target


--> Global | Kuler | Menu
-
on submenu_MyColours
   menu_DoSub "Global | Colour | Palette | Menu"
end submenu_MyColours

on submenu_Colours
   menu_DoSub "Global | Colour | Menu"
end submenu_Colours

on _
end _

on menu_CoolestColours mTarget
   set the cursor to watch
   put kuler_FetchCoolestRss() into someRss
   kuler_DiplayRss someRSS, mTarget
end menu_CoolestColours

on menu_SearchForColours menuChoice, mTarget
   put the uOPN ["search_Term"] of me into searchTerm
   switch menuChoice
      case "Search for keywords"
         put opn_Ask("What keyword would you like to search for?", searchTerm) into searchTerm
         kuler_SearchForKeyWord searchTerm, mTarget
         break
      case "Free text search"
         put opn_Ask("What string would you like to search for?", searchTerm) into searchTerm
         put kuler_SearchRss(searchTerm) into someRSS
         kuler_DiplayRss someRSS, mTarget
         break
      case "Search for user colours"
         put opn_Ask("What user email would you like to search for?", userEmail) into userEmail
         put kuler_SearchUserRss(userEmail) into someRSS
         kuler_DiplayRss someRSS, mTarget
         break
   end switch
   set the uOPN ["search_Term"] of me to searchTerm
end menu_SearchForColours
        
on _
end _

on submenu_Tools
   menu_DoSub "Global | Kuler | Tools | Menu"
end submenu_Tools


--> Global | Record | Kuler | Menu | Props
-
