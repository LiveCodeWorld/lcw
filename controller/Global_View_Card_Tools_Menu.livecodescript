script "Global_View_Card_Tools_Menu"
--> MetaData
-
license: GPLv3
name: Global_View_Card_Tools_Menu
type: controller
version: 0.1

local LocalArray


--> Global | View | Card | Tools | Menu
-
on menu_Clone someView
   put the stack_Name of someView into stackName
   stack_Clone stackName
   put it into clonedStack
end menu_Clone

on menu_ViewProperty someView, viewProp
   view_DoPropertyMenu viewProp, someView
end menu_ViewProperty

on _
end _

on menu_EditBehavior someView
   put the behavior of someView into bStackObject
   edit the script of bStackObject
end menu_EditBehavior

on menu_ResetBehavior someView
   put the behavior of someView into bStackObject
   set the behavior of someView to bStackObject
end menu_ResetBehavior

on menu_FixBehaviors someView
   fix_Behaviors
end menu_FixBehaviors

on _
end _

on menu_OpenSubstack someView, substackName
   go to stack substackName
end menu_OpenSubstack

on menu_TestLayout someView
   put the card_Object of someView into cardControl
   put the template_CardRect of cardControl into cardRect
   
   repeat 6
      set the cursor to busy
      dispatch "LayoutControl" to someView with cardRect
   end repeat
   
   put merge ("Dispatched 'LayoutControl' to [[the name of someView]] 6 times") into someComment
   opn_Notify someComment
end menu_TestLayout

on submenu_Geometry
   return "Global | View | Test | Geometry | Menu"
end submenu_Geometry

on _
end _

on menu_EditViewCardScript someView
   put the card_Object of someView into cardObject
   edit the script of cardObject
end menu_EditViewCardScript

on menu_EditViewCardBehavior someView
   put the card_Object of someView into cardObject
   put the behavior of cardObject into bObject
   edit the script of bObject
end menu_EditViewCardBehavior

on menu_SetViewCardBehavior someView
   put the card_Object of someView into cardObject
   put the name of stack "behavior_ViewTemplateCard" into bObject
   set the behavior of cardObject to bObject
end menu_SetViewCardBehavior


--> Global | View | Card | Tools | Menu | Disabled
-
getprop disabled_EditBehavior [someView]
   put the behavior of someView into bObject
   put exists (bObject) into bExists
   return bExists is false
end disabled_EditBehavior

getprop disabled_SetViewCardBehavior [someView]
   put the card_Object of someView into cardObject
   put the behavior of cardObject into bObject
   put exists (bObject) into bExists
   return bExists is true
end disabled_SetViewCardBehavior

getprop disabled_EditViewCardBehavior [someView]
   put the card_Object of someView into cardObject
   put the behavior of cardObject into bObject
   put exists (bObject) into bExists
   return bExists is false
end disabled_EditViewCardBehavior

getprop disabled_OpenSubstack [someView]
   put the stack_Object of someView into stackObject
   put the mainstack of stackObject into stackName
   put the substacks of stack stackName into substackNames
   if substackNames is empty then
      return "delete"
   else
      put substackNames into LocalArray ["substackNames"]
      return false
   end if
end disabled_OpenSubstack


--> Global | View | Card | Tools | Menu | Props
-
getprop substack_Names [someView]
   return LocalArray ["substackNames"]
end substack_Names

getprop view_Props [mTarget]
   return the view_PropertyMenu of mTarget -- into LocalArray ["view_PropertyMenu"]
   return LocalArray ["view_PropertyMenu"]
end view_Props
