{include file='documentHeader'}

<head>
	<title>{$room} - {lang}wcf.chat.title{/lang} - {PAGE_TITLE|language}</title>
	
	{include file='headInclude' sandbox=false}
	
	<style type="text/css">
		#chatBox {
			padding: 0;
		}
		
		#chatBox > div {
			text-align: center;
		}
		
		#chatBox aside, #chatRoomContent {
			text-align: left;
		}
		
		aside {
			overflow: auto;
			padding: 0 1px 0 0;
			width: 190px;
		}
		
		aside h2 {
			margin: auto;
			text-align: center;
			font-size: 130%;
			color: #336699;
			cursor: default;
			font-weight: bold;
			margin-top: 5px;			
		}

		aside ul li a {
			color: #6699CC;
			display: block;
			padding: 5px 25px 7px 35px;
			text-shadow: 0 1px 0 #FFFFFF;
		}
		
		#topic, #smileyList, #chatOptions {
			padding: 5px;
		}	
		
		.chatMessageContainer {
			height: 200px;
			overflow-y: scroll;
		}
		
		#smileyList .smilies li, .smallButtons li {
			display: inline;
			margin-right: 5px;
			margin-top: 5px;
		}
		
		#chatForm {
			margin-top: 15px;
			white-space: nowrap;
			margin-top: 10px;
			/* Fix to align chatInput in center */
			text-align: center;
		}
		
		#chatInput {
			background-position: right center;
			background-repeat: no-repeat;
		}
		
		#chatOptions {
			display: inline-block;
		}

		#chatUserList > li > .bgFix a {
			background-image: url({icon size='S'}arrowRight{/icon});
			background-position: 15px center;
			background-repeat: no-repeat;
			background-size: 16px auto;
		}
		
		#chatUserList > li.activeMenuItem > .bgFix a {
			background-image: url({icon size='S'}arrowDown{/icon});
		}
		
		#chatUserList .chatUserMenu li a {
			margin-left: 30px !important;
		}
		
		#chatUserList .chatUserMenu {
			display: none;
		}
		
		#chatUserList > li a {
			margin-left: 20px;
		}
		
		.chatMessage time, .chatMessage time::before, .chatMessage time::after {
			font-size: .8em;
		}
		.chatMessage time::before {
			content: "[";
		}
		
		.chatMessage time::after {
			content: "]";
		}
		
		.chatMessage {
			padding-left: 16px;
			min-height: 16px;
		}
		{assign var='type' value='\wcf\data\chat\message\ChatMessage::TYPE_'}
		.chatMessage{$type|concat:'JOIN'|constant}, .chatMessage{$type|concat:'LEAVE'|constant} {
			background-position: left top;
			background-repeat: no-repeat;
			
		}
		
		.chatMessage{$type|concat:'JOIN'|constant} {
			background-image: url({icon size='S'}toRight1{/icon});
		}
		
		.chatMessage{$type|concat:'LEAVE'|constant} {
			background-image: url({icon size='S'}toLeft1{/icon});
		}
		
		.ajaxLoad {
			background-position: right center;
			background-repeat: no-repeat;
			background-image: url({icon size='S'}spinner1{/icon});
		}
		
		.bgFix {
			display: block;
		}
	</style>
</head>

<body id="tpl{$templateName|ucfirst}">
{capture assign='sidebar'}<aside class="sidebar">
	<div id="sidebar">
		<h2>{lang}wcf.chat.users{/lang}</h2>
			<ul id="chatUserList">
			{section name=user start=1 loop=11}
				<li id="user-{$user}" class="chatUser">
					<span class="bgFix"><a class="chatUserLink" href="javascript:;">User {$user}</a></span>
					<ul class="chatUserMenu">
						<li>
							<a href="javascript:;">Query</a>
							<a href="javascript:;">Kick</a>
							<a href="javascript:;">Ban</a>
							<a href="{link controller="User" id=$user}{/link}">Profile</a>
						</li>
					</ul>
				</li>
			{/section}
			</ul>
		<h2>{lang}wcf.chat.rooms{/lang}</h2>
		<nav class="sidebarMenu">
			<div>
				<ul>
				{foreach from=$rooms item='roomListRoom'}
					<li{if $roomListRoom->roomID == $room->roomID} class="activeMenuItem"{/if}>
						<a href="{link controller='Chat' object=$roomListRoom}{/link}" class="chatRoom">{$roomListRoom}</a>
					</li>
				{/foreach}
				</ul>
			</div>
		</nav>
	</div>
</aside>
<!-- CONTENT -->{/capture}
{capture assign='header'}{include file='header' sandbox=false}{/capture}
{assign var='header' value='class="main"'|str_replace:'class="main right"':$header}
{assign var='header' value='<!-- CONTENT -->'|str_replace:$sidebar:$header}
{@$header}

<div id="chatRoomContent">
	<div id="topic" class="border"{if $room->topic|language === ''} style="display: none;"{/if}>{$room->topic|language}</div>
	<div class="chatMessageContainer border content">
		<ul></ul>
	</div>
	
	<form id="chatForm" action="{link controller="Chat" action="Send"}{/link}" method="post">
		<input type="text" id="chatInput" class="inputText long" name="text" autocomplete="off" required="required" placeholder="Submit with enter" />
	</form>
	
	<div id="chatControls">
		<div id="smileyList" class="border">
			<ul class="smilies">
				{foreach from=$smilies item='smiley'}
					<li>
						<img src="{$smiley->getURL()}" alt="{$smiley->smileyCode}" title="{$smiley->smileyCode}" class="smiley" />
					</li>
				{/foreach}
			</ul>
		</div>
		<div id="chatOptions" class="border">
			<div class="smallButtons">
				<ul>
					<li>
						<a id="chatAutoscroll" href="javascript:;" class="chatToggle balloonTooltip" title="{lang}wcf.global.button.disable{/lang}" data-disable-message="{lang}wcf.global.button.disable{/lang}" data-enable-message="{lang}wcf.global.button.enable{/lang}" data-status="1">
							<img alt="" src="{icon}enabled1{/icon}" /> <span>Scroll</span>
						</a>
					</li>
					<li>
						<a id="chatNotify" href="javascript:;" class="chatToggle balloonTooltip" title="{lang}wcf.global.button.enable{/lang}" data-disable-message="{lang}wcf.global.button.disable{/lang}" data-enable-message="{lang}wcf.global.button.enable{/lang}" data-status="0">
							<img alt="" src="{icon}disabled1{/icon}" /> <span>Notify</span>
						</a>
					</li>
					<li>
						<a id="chatClear" href="javascript:;" class="balloonTooltip" title="Clear the chat">
							<img alt="" src="{icon}delete1{/icon}" /> <span>Clear</span>
						</a>
					</li>
					<li>
						<a id="chatMark" href="javascript:;" class="balloonTooltip" title="Show checkboxes">
							<img alt="" src="{icon}check1{/icon}" /> <span>Mark</span>
						</a>
					</li>											
				</ul>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">
	//<![CDATA[
		TimWolla.WCF.Chat.titleTemplate = new WCF.Template('{ldelim}$title} - {'wcf.chat.title'|language|encodeJS} - {PAGE_TITLE|language|encodeJS}');
		{capture assign='chatMessageTemplate'}{include file='chatMessage'}{/capture}
		TimWolla.WCF.Chat.messageTemplate = new WCF.Template('{@$chatMessageTemplate|encodeJS}');
		TimWolla.WCF.Chat.init({$room->roomID}, 1);
		TimWolla.WCF.Chat.handleMessages([
			{implode from=$newestMessages item='message'}
				{@$message->jsonify()}
			{/implode}
		]);
	//]]>
</script>

{include file='footer' sandbox=false}
</body>
</html>