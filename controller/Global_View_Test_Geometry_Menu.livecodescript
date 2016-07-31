script "Global_View_Test_Geometry_Menu"
--> MetaData
-
license: GPLv3
name: Global_View_Test_Geometry_Menu
type: controller
version: 0.1


--> Global | View | Test | Geometry | Menu
-
on menu_Clone mTarget
   put the stack_Name of mTarget into stackNameToClone
   stack_Clone stackNameToClone
end menu_Clone

on menu_DispatchLayoutControl mTarget
   put the card_Object of mTarget into cardControl
   put the rect of cardControl into cardRect
   
   dispatch "LayoutControl" to mTarget with cardRect
   opn_Notify the name of mTarget
end menu_DispatchLayoutControl

on _
end _

on menu_TestLayoutControl mTarget, menuChoice
   test_ViewRect "LayoutControl", mTarget
end menu_TestLayoutControl

on menu_TestViewRect mTarget, menuChoice
   test_ViewRect "view_rect", mTarget
end menu_TestViewRect

on menu_TestRect mTarget, menuChoice
   test_ViewRect "rect", mTarget
end menu_TestRect

on menu_TestFormattedRect mTarget, menuChoice
   test_ViewRect "view_FormattedRect", mTarget
end menu_TestFormattedRect

on menu_TestViewRectToFormattedRect mTarget, menuChoice
   test_ViewRect "set the view_Rect to view_FormattedRect", mTarget
end menu_TestViewRectToFormattedRect

on _
end _
    
on menu_TestMashed mTarget
   opn_Notify the mobile_Name of mTarget, true
   put the view_Props of mTarget into viewProps
   display_Text (the view_MashedProperties of mTarget), the name of mTarget
end menu_TestMashed


--> Global | View | Test | Geometry | Menu | Disabled
-
getprop disabled_TestFormattedRect [mTarget]
   if exists(mTarget) is false then return true
   put the view_FormattedRect of mTarget into fRect
   return fRect is empty
end disabled_TestFormattedRect

getprop disabled_TestViewRectToFormattedRect [mTarget]
   if exists(mTarget) is false then return true
   put the view_FormattedRect of mTarget into fRect
   return fRect is empty
end disabled_TestViewRectToFormattedRect


--> Menu | Props
-
--> Deps
-
command test_ViewRect menuChoice, mTarget
   -- put the rect of mTarget into oRect
   put the template_CardRect of mTarget into oRect
   rect_CreateMask oRect, "Original Rect", mTarget, "yellow"
   
   repeat 6
      switch menuChoice
         case "LayoutControl"
            put the rect of mTarget into someRect
            dispatch "LayoutControl" to mTarget with someRect
            break
         case "view_Rect"
            put the rect of mTarget into someRect
            set the view_Rect of mTarget to someRect
            break
         case "rect"
            put the rect of mTarget into someRect
            set the rect of mTarget to someRect
            break
         case "view_FormattedRect"
            put the view_FormattedRect of mTarget into someRect
            set the rect of mTarget to someRect
            break
         case "set the view_Rect to view_FormattedRect"
            put the view_FormattedRect of mTarget into someRect
            set the view_Rect of mTarget to someRect
            break
      end switch
   end repeat
   put the rect of mTarget into newRect
   rect_CreateMask someRect, "Test Mask", mTarget
   
   if newRect = oRect then
      put "Test passed - same as original rect!" into someMessage
      if menuChoice = "rect" then
         put CR & CR & "However, setting a rect of a group to it's original rect doed not trigger a resizeControl handler" after someMessage
      end if
   else
      beep
      put "Test failed - new rect is different from original!" into someMessage
   end if
   opn_Notify someMessage, true
end test_ViewRect
