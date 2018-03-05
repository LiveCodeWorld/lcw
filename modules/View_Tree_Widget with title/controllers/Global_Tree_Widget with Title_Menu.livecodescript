script "View|Tree|Widget"
--> MetaData
-
license: GPLv3
name: Global_Tree_Widget with Title_Menu
type: controllers
version: 0.1


--> Global | Tree | Widget with Title | Menu
-
on menu_Test mTarget, someProp
   beep
end menu_Test

on _
end _

on submenu_Tree
   return "Global | Tree | Menu"
end submenu_Tree

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Tree | Widget with Title | Menu | Props
-
getprop some_Prop
   return "yellow"
end some_Prop

getprop some_Props
   return "yellow,green,blue"
end some_Props


--> Global | Tree | Widget with Title | Menu | Disabled
-
getprop disabled_Test [mTarget]
   return false
end disabled_Test


--> Menu | Target
-
getprop menu_Target [mTitlePath]
   put menu_GetTargetObject() into tObject
   switch
      case mTitlePath contains "Some|Path|To|Menu"
         break
      default
         pass menu_Target
   end switch
end menu_Target

getprop menu_CheckTarget [mTarget]
   return true
end menu_CheckTarget


--> Dev | Menu
-
on menu_Dev mTarget
   beep
end menu_Dev
