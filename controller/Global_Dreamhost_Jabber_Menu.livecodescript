script "Global_Dreamhost_Jabber_Menu"
--> MetaData
-
license: GPLv3
name: Global_Dreamhost_Jabber_Menu
type: controller
version: 0.1


--> Global | Dreamhost | Jabber | Menu
-
on menu_JabberDomains
   put dreamhost_ApiKey() into apiKey
   put merge("https://api.dreamhost.com/?key=[[apiKey]]&cmd=jabber-list_valid_domains") into someUrl
   put url someUrl into domainIndex
   display_Lines domainIndex
end menu_JabberDomains

on menu_JabberUsers
   put dreamhost_ApiKey() into apiKey
   put merge("https://api.dreamhost.com/?key=[[apiKey]]&cmd=jabber-list_users") into someUrl
   put url someUrl into someResult
   
   put dreamHost_ParseTableResult (someResult) into tableArray
   display_Array tableArray, "jabber-list_users", "Global | Dreamhost | Jabber | Menu", "Global | Dreamhost | Jabber | Menu"
end menu_JabberUsers

on menu_AddJabberUser
   /*
   username : the desired jabber username
   domain : the domain for the new user
   password : the password for the new user
   */
   
   put dreamhost_ApiKey() into apiKey
   put opn_Ask ("Jabber user name...", "fortyfoxes") into uName
   put opn_Ask ("Jabber password...", "xxxx") into pWord
   put opn_Ask ("Jabber domain...", "architex.tv") into jabberDomain
   put merge("https://api.dreamhost.com/?key=[[apiKey]]&cmd=jabber-add_user&username=[[uName]]&domain=[[jabberDomain]]&password=[[pWord]]") into someUrl
   put url someUrl into someResult
   
   put dreamHost_ParseResult (someResult) into tableArray
   display_Array tableArray, "jabber-add_user"
end menu_AddJabberUser

on menu_ServiceProgress
   put "gc-FzjbdAwYFR4kcvynK" into serviceToken
   put dreamhost_ApiKey() into apiKey
   put merge("https://api.dreamhost.com/?key=[[apiKey]]&cmd=services-progress&token=[[serviceToken]]") into someUrl
   put url someUrl into someResult
   
   put dreamHost_ParseResult (someResult) into tableArray
   display_Array tableArray, "services-progress"
end menu_ServiceProgress

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | DreamHost | Jabber | Menu | Props
-
--> Global | DreamHost | Jabber | Menu | Disabled
-
getprop disabled_Test [mTarget]
   return false
end disabled_Test


--> Global | DreamHost | Jabber | Menu | Deps
-
function dreamhost_ApiKey
   put "Q5JRGXMVCWKMATSZ" into apiKey
   return apiKey
end dreamhost_ApiKey

function dreamHost_ParseTableResult someResult
   local tableArray
   if line 1 of someResult is not "success" then
      display_Lines someResult, "dreamHost_ParseResult"
      return empty
   end if
   
   set the itemdelimiter to tab
   put line 2 of someResult into keyLine
   delete line 1 to 2 of of someResult
   
   repeat with lineNum = 1 to the number of lines of someResult
      put line lineNum of someResult into someLine
      repeat with itemNum = 1 to the number of items of someLine
         put item itemNum of keyLine into someKey
         put item itemNum of someLine into someValue
         put someValue into tableArray [lineNum][someKey]
      end repeat
   end repeat
   return tableArray
end dreamHost_ParseTableResult

function dreamHost_ParseResult someResult
   display_Lines someResult
   
   local tableArray
   if line 1 of someResult is not "success" then
      display_Lines someResult, "dreamHost_ParseResult"
      return empty
   end if
   
   set the itemdelimiter to tab
   put line 2 of someResult into keyLine
   delete line 1 to 2 of of someResult
   
   put someResult into someLine
   repeat with itemNum = 1 to the number of items of someLine
      put item itemNum of keyLine into someKey
      put item itemNum of someLine into someValue
      put someValue into resultArray [someKey]
   end repeat
   return resultArray
end dreamHost_ParseResult


--> Dev | Menu
-
