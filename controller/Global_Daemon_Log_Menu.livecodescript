script "Global_Daemon_Log_Menu"
--> Global | Daemon | Log | Menu
-
/*
Scripts only have access to handlers in the behavior hierarchy before the current script.
In this case that would be only "lib_DaemonUtils, lib_Log"
Another reason to put any useful utility scripts out of the minimal lib_Daemon script.
*/

on menu_Display treeView
   dispatch "daemon_DisplayLogArray" to stack "Fedwiki Server"
end menu_Display

on menu_Test treeView
   put the tree_Field of treeView into treeField
   put the tree_Array of treeView into treeArray
   put json_FromArray (treeArray)
end menu_Test


--> Global | Daemon | Log | Line | Menu
-
on menu_TestRoute treeField
   put the selected_ArrayValue of treeField into requestArray
   put the daemon_RouterLibrary of me & CR & the daemon_Server of me -- into
   -- display_Array requestArray
end menu_TestRoute
