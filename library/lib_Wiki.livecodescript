script "lib_Wiki"
--> MetaData
-
license: GPLv3
name: lib_Wiki
type: library
version: 0.1

/*
This is a library for working with Fedwiki.
*/



--> Wiki
-
function wiki_GetSiteFolder
   put $HOME & "/.wiki/" into wikiSiteFolder
   return wikiSiteFolder
end wiki_GetSiteFolder

function wiki_GetWikiClientFolder
   put wiki_GetModulesFolder() & "wiki-client/" into wikiClientFolder
   return wikiClientFolder
end wiki_GetWikiClientFolder

function wiki_GetModulesFolder
   return "/usr/local/lib/node_modules/wiki"
end wiki_GetModulesFolder


--> Javascript
-
function javascript_ConstructInternalLink pageTitle
   put merge ("wiki.doInternalLink('[[pageTitle]]')") into someJavascript
   return someJavascript
end javascript_ConstructInternalLink

function javascript_ConstructFooterHeight pSomeHeight
   -- if pSomeHeight is empty then put 18 into pSomeHeight
   if pSomeHeight is empty then put 60 into pSomeHeight
   put merge ("document.querySelector('section.main').style.bottom='[[pSomeHeight]]px'") into someJavascript
   return someJavascript
end javascript_ConstructFooterHeight

function javascript_ConstructHideSiteOwner
   put "document.getElementById('site-owner').style.visibility = 'hidden'" into someJavascript
   return someJavascript
end javascript_ConstructHideSiteOwner

function javascript_ConstructFooterVisibility someBoolean
   -- put "document.getElementById('site-owner').style.visibility = 'hidden'" into someJavascript
   -- put "var myElement = document.querySelector('footer');myElement.style.visibility = 'hidden'" into someJavascript
   -- put "var myElement = document.querySelector('footer');myElement.style.visibility = 'visible'" into someJavascript
   
   if someBoolean is true then
      put "document.querySelector('footer').style.visibility = 'hidden'" into someJavascript
   else
      put "document.querySelector('footer').style.visibility = 'visible'" into someJavascript
   end if
   return someJavascript
end javascript_ConstructFooterVisibility
