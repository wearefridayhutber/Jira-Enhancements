`// ==UserScript==
// @name        JIRA Right-Click Menu
// @namespace   http://gm.delphae.net/
// @description Add a context menu to JIRA issues.
// @include     *.atlassian.net/secure/RapidBoard.jspa*
// @require     //ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js
// @grant       none
// @version     1
// ==/UserScript==

// By Jonathan Goodger`

main = ->
    $ = window.AJS.$
    bindings = {}

    buildMenu = (id, items) ->
        ###
        http://www.trendskitchens.co.nz/jquery/contextmenu/
        ###
        `(function($){var menu,shadow,trigger,content,hash,currentTarget;var defaults={menuStyle:{listStyle:'none',padding:'1px',margin:'0px',backgroundColor:'#fff',border:'1px solid #999',width:'100px'},itemStyle:{margin:'0px',color:'#000',display:'block',cursor:'default',padding:'3px',border:'1px solid #fff',backgroundColor:'transparent'},itemHoverStyle:{border:'1px solid #0a246a',backgroundColor:'#b6bdd2'},eventPosX:'pageX',eventPosY:'pageY',shadow:true,onContextMenu:null,onShowMenu:null};$.fn.contextMenu=function(id,options){if(!menu){menu=$('<div id="jqContextMenu"></div>').hide().css({position:'absolute',zIndex:'500'}).appendTo('body').bind('click',function(e){e.stopPropagation()})}if(!shadow){shadow=$('<div></div>').css({backgroundColor:'#000',position:'absolute',opacity:0.2,zIndex:499}).appendTo('body').hide()}hash=hash||[];hash.push({id:id,menuStyle:$.extend({},defaults.menuStyle,options.menuStyle||{}),itemStyle:$.extend({},defaults.itemStyle,options.itemStyle||{}),itemHoverStyle:$.extend({},defaults.itemHoverStyle,options.itemHoverStyle||{}),bindings:options.bindings||{},shadow:options.shadow||options.shadow===false?options.shadow:defaults.shadow,onContextMenu:options.onContextMenu||defaults.onContextMenu,onShowMenu:options.onShowMenu||defaults.onShowMenu,eventPosX:options.eventPosX||defaults.eventPosX,eventPosY:options.eventPosY||defaults.eventPosY});var index=hash.length-1;$(this).bind('contextmenu',function(e){var bShowContext=(!!hash[index].onContextMenu)?hash[index].onContextMenu(e):true;if(bShowContext)display(index,this,e,options);return false});return this};function display(index,trigger,e,options){var cur=hash[index];content=$('#'+cur.id).find('ul:first').clone(true);content.css(cur.menuStyle).find('li').css(cur.itemStyle).hover(function(){$(this).css(cur.itemHoverStyle)},function(){$(this).css(cur.itemStyle)}).find('img').css({verticalAlign:'middle',paddingRight:'2px'});menu.html(content);if(!!cur.onShowMenu)menu=cur.onShowMenu(e,menu);$.each(cur.bindings,function(id,func){$('#'+id,menu).bind('click',function(e){hide();func(trigger,currentTarget)})});menu.css({'left':e[cur.eventPosX],'top':e[cur.eventPosY]}).show();if(cur.shadow)shadow.css({width:menu.width(),height:menu.height(),left:e.pageX+2,top:e.pageY+2}).show();$(document).one('click',hide)}function hide(){menu.hide();shadow.hide()}$.contextMenu={defaults:function(userDefaults){$.each(userDefaults,function(i,val){if(typeof val=='object'&&defaults[i]){$.extend(defaults[i],val)}else defaults[i]=val})}}})($)`
        
        $ ->
            $('div.contextMenu').hide()

            elem = $('<div>').attr(
                'class': 'contextMenu'
                'id': id
            )

            ul = $ '<ul>'

            for id, config of items
                ul.append $("<li id='#{id}'>").text(config.name)

                bindings[id] = config.callback

            elem.append ul
            $('body').append elem

    initMenu = ->
        $('.ghx-issue').contextMenu 'issueContextMenu', {
            onContextMenu: (e) ->
                $(e.currentTarget).trigger 'click'

                return true

            menuStyle:
                'width': 'auto'

            itemHoverStyle:
                'background-color': 'rgb(217, 231, 243)'
                'border-color': 'rgb(180, 200, 210)'

            bindings: bindings
        }


    buildMenu 'issueContextMenu',
        'edit-issue':
            name: 'Edit Issue...'
            callback: GH.Shortcut.editIssue

        'edit-labels': 
            name: 'Edit Labels...'
            callback: GH.Shortcut.editIssueLabels

        'assign-to-me':
            name: 'Assign Issue to Me'
            callback: GH.Shortcut.assignIssueToMe

        'links':
            name: 'Set to Blocked...'
            callback: GH.IssueOperationShortcuts.linkSelectedIssue

    initMenu()

    $(document).bind "DOMNodeInserted", (e) =>
        # span#js-pool-end is added when 'work' is reloaded
        initMenu() if 'js-pool-end' == $(e.target).attr 'id'

# Shiv the JS in as a script tag to gain access to jQuery from AJS
script = document.createElement 'script'
script.textContent = "(#{main.toString()})();"
document.body.appendChild script