script "Global_Text_Square_Menu"
--> MetaData
-
license: GPLv3
name: Global_Text_Square_Menu
type: controller
version: 0.1


--> Global | Text | Square | Menu
-
on menu_TestFirstText mTarget
   /*
   Gentleness means being kindly, tender and mild tempered. I practice it by speaking and behaving in a pleasant, soothing. even tempered manner.
   
   The opposite is harsheness.
   */
   put script_GetCommentAboveMe() into someText
   
   put the sivaSquareText_View of mTarget into sivaTraitView
   set the view_Text of sivaTraitView to someText
end menu_TestFirstText

on menu_TestSecondText mTarget
   /*
   Patience means remaining composed when faced with delays, time constraints or other challenges that hinder expectations.
   
   I cultivate it by planning in advance and controlling the tendency to become frustrated or upset.
   
   The opposite is frustration.
   */
   put script_GetCommentAboveMe() into someText
   
   put the sivaSquareText_View of mTarget into sivaTraitView
   set the view_Text of sivaTraitView to someText
end menu_TestSecondText

on menu_ClearText mTarget
   put the sivaSquareText_View of mTarget into sivaTraitView
   set the view_Text of sivaTraitView to empty
end menu_ClearText

on _
end _

on submenu_Tools
   return "Global | View | Card | Tools | Menu"
end submenu_Tools
