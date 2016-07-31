script "Global_Kuler_Tools_Menu"
--> MetaData
-
license: GPLv3
name: Global_Kuler_Tools_Menu
type: controller
version: 0.1


--> Global | Kuler | Tools | Menu
-
on menu_ItemsPerPage kulerItemsPerPage
   set the kuler_ItemsPerPage of me to kulerItemsPerPage
end menu_ItemsPerPage

on menu_ClearKulerData mTarget
   put the dgControl of mTarget into dgView
   if exists(dgView) then
      set the dgData of dgView  to empty
   else
      beep
   end if
end menu_ClearKulerData

on menu_KulerDocumentation menuChoice
   switch menuChoice
      case "API"
         revGoUrl "http://learn.adobe.com/wiki/display/kulerdev/B.+Feeds"
         break
      case "Kuler"
         break
         revGoUrl "http://kuler.adobe.com/"
   end switch
end menu_KulerDocumentation

on _
end _

on submenu_Datagrid
   menu_DoSub "Global | Rev | Datagrid | Menu"
end submenu_Datagrid

on menu_SetDataGridRecord mTarget
   set the record_ViewName of mTarget to "View|Record|Kuler"
end menu_SetDataGridRecord

on menu_EditScript menuChoice
   switch menuChoice
      case "Kuler Library"
         edit the script of stack "View|Record|Kuler"
         break
      case "Kuler View"
         put view_GetTemplateObject ("View|Record|Kuler") into libraryObject
         edit the script of the behavior of libraryObject
         break
   end switch
end menu_EditScript

on _
end _

on submenu_View
   menu_DoSub "Global | View | Script | Menu"
end submenu_View
