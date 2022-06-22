#Region Headers
;=QUEST=
Global Const $HEADER_QUEST_ACCEPT				= 0x3A	;Accepts a quest from the NPC
Global Const $HEADER_QUEST_REWARD				= 0x3A	;Retrieves Quest reward from NPC
Global Const $HEADER_QUEST_ABANDON				= 0x10	;Abandons the quest

;=HERO=
Global Const $HEADER_HERO_AGGRESSION			= 0x14	;Sets the heroes aggression level
Global Const $HEADER_HERO_LOCK					= 0x15	;Locks the heroes target
Global Const $HEADER_HERO_TOGGLE_SKILL			= 0x18	;Enables or disables the heroes skill
Global Const $HEADER_HERO_CLEAR_FLAG			= 0x19	;Clears the heroes position flag
Global Const $HEADER_HERO_PLACE_FLAG			= 0x19	;Sets the heroes position flag, hero runs to position
Global Const $HEADER_HERO_ADD					= 0x1D	;Adds hero to party
Global Const $HEADER_HERO_KICK					= 0x1E	;Kicks hero from party
Global Const $HEADER_HEROES_KICK				= 0x1E	;Kicks ALL heroes from party

;=PARTY=
Global Const $HEADER_PARTY_PLACE_FLAG			= 0x1A	;Sets the party position flag, all party-npcs runs to position
Global Const $HEADER_PARTY_CLEAR_FLAG			= 0x1A	;Clears the party position flag
Global Const $HEADER_HENCHMAN_ADD				= 0x9E	;Adds henchman to party
Global Const $HEADER_PARTY_LEAVE				= 0xA1	;Leaves the party
Global Const $HEADER_HENCHMAN_KICK				= 0xA7	;Kicks a henchman from party
Global Const $HEADER_INVITE_TARGET				= 0x9F	;Invite target player to party
Global Const $HEADER_INVITE_CANCEL				= 0x9C	;Cancel invitation of player
Global Const $HEADER_INVITE_ACCEPT				= 0x9B	;Accept invitation to party

;=TARGET (Enemies or NPC)=
Global Const $HEADER_CALL_TARGET				= 0x22	;Calls the target without attacking (Ctrl+Shift+Space)
Global Const $HEADER_ATTACK_AGENT				= 0x25	;Attacks agent (Space IIRC)
Global Const $HEADER_CANCEL_ACTION				= 0x27	;Cancels the current action
Global Const $HEADER_AGENT_FOLLOW				= 0x37	;Follows the agent/npc. Ctrl+Click triggers "I am following Person" in chat
Global Const $HEADER_NPC_TALK					= 0x38	;talks/goes to npc
Global Const $HEADER_SIGNPOST_RUN				= 0x50	;Runs to signpost

;=DROP=
Global Const $HEADER_ITEM_DROP					= 0x2B	;Drops item from inventory to ground
Global Const $HEADER_GOLD_DROP					= 0x2E	;Drops gold from inventory to ground

;=BUFFS=
Global Const $HEADER_STOP_MAINTAIN_ENCH			= 0x28	;Drops buff, cancel enchantmant, whatever you call it

;=ITEMS=
Global Const $HEADER_ITEM_EQUIP					= 0x2F	;Equips item from inventory/chest/no idea
Global Const $HEADER_ITEM_PICKUP				= 0x3E	;Picks up an item from ground
Global Const $HEADER_ITEM_DESTROY				= 0x68	 ;Destroys the item
Global Const $HEADER_ITEM_ID					= 0x6B	;Identifies item in inventory
Global Const $HEADER_ITEM_MOVE					= 0x71	;Moves item in inventory
Global Const $HEADER_ITEMS_ACCEPT_UNCLAIMED		= 0x72	;Accepts ITEMS not picked up in missions
;FIX Global Const $HEADER_ITEM_MOVE_EX				= 0x7A	;Moves an item, with amount to be moved.
Global Const $HEADER_SALVAGE_MATS				= 0x79	;Salvages materials from item
Global Const $HEADER_SALVAGE_MODS				= 0x7A	;Salvages mods from item
Global Const $HEADER_ITEM_USE					= 0x7D	;Uses item from inventory/chest
Global Const $HEADER_ITEM_UNEQUIP				= 0x4E	;Unequip item
;FIX Global Const $HEADER_UPGRADE					= 0x85	;used by gwapi. is it even useful? NOT TESTED
;FIX Global Const $HEADER_UPGRADE_ARMOR_1			= 0x85	;used by gwapi. is it even useful? NOT TESTED
;FIX Global Const $HEADER_UPGRADE_ARMOR_2			= 0x88	;used by gwapi. is it even useful? NOT TESTED

;=TRADE=
Global Const $HEADER_TRADE_PLAYER				= 0x48	;Send trade request to player
Global Const $HEADER_TRADE_OFFER_ITEM			= 0x02	;Add item to trade window
Global Const $HEADER_TRADE_SUBMIT_OFFER			= 0x03	;Submit offer
Global Const $HEADER_TRADE_CHANGE_OFFER			= 0x06	;Change offer
Global Const $HEADER_TRADE_CANCEL				= 0x01	;Cancel trade
Global Const $HEADER_TRADE_ACCEPT				= 0x07	;Accept trade

;=TRAVEL=
Global Const $HEADER_MAP_TRAVEL					= 0xB0	;Travels to outpost via worldmap
Global Const $HEADER_GUILDHALL_TRAVEL			= 0xAF	;Travels to guild hall
Global Const $HEADER_GUILDHALL_LEAVE			= 0xB1	;Leaves Guildhall

;=FACTION=
Global Const $HEADER_FACTION_DONATE				= 0x34	;Donates kurzick/luxon faction to ally

;=TITLE=
Global Const $HEADER_TITLE_DISPLAY				= 0x57	;Displays title (from Gigis Vaettir Bot)
Global Const $HEADER_TITLE_CLEAR				= 0x58	;Hides title (from Gigis Vaettir Bot)

;=DIALOG=
Global Const $HEADER_DIALOG						= 0x3A	;Sends a dialog to NPC
Global Const $HEADER_CINEMATIC_SKIP				= 0x62	;Skips the cinematic

;=SKILL / BUILD=
Global Const $HEADER_SET_SKILLBAR_SKILL			= 0x5B	;Changes a skill on the skillbar
Global Const $HEADER_LOAD_SKILLBAR				= 0x5C	;Loads a complete skillbar
Global Const $HEADER_CHANGE_SECONDARY			= 0x40	;Changes Secondary class (from Build window, not class changer)
;FIX Global Const $HEADER_SKILL_USE_ALLY				= 0x4D	;used by gwapi. appears to have changed
;FIX Global Const $HEADER_SKILL_USE_FOE				= 0x4D	;used by gwapi. appears to have changed
Global Const $HEADER_SKILL_USE_ID				= 0x4D	;
Global Const $HEADER_USE_SKILL					= 0x45
Global Const $HEADER_SET_ATTRIBUTES				= 0x0F	;hidden in init stuff like sendchat
;FIX Global Const $HEADER_OPEN_SKILLS				= 0x42

;=CHEST=
Global Const $HEADER_CHEST_OPEN					= 0x52	;Opens a chest (with key AFAIK)
Global Const $HEADER_CHANGE_GOLD				= 0x7B	;Moves Gold (from chest to inventory, and otherway around IIRC)

;=MISSION=
Global Const $HEADER_MODE_SWITCH				= 0x9A	;Toggles hard- and normal mode
Global Const $HEADER_MISSION_ENTER				= 0xA4	;Enter a mission/challenge
Global Const $HEADER_MISSION_FOREIGN_ENTER		= 0xA4	;Enters a foreign mission/challenge (no idea honestly)
Global Const $HEADER_OUTPOST_RETURN				= 0xA6	;Returns to outpost after /resign

;=CHAT=
Global Const $HEADER_SEND_CHAT					= 0x63	;Needed for sending messages in chat

;=OTHER CONSTANTS=
Global Const $HEADER_MAX_ATTRIBUTES_CONST_5		= 0x04	;constant at word 5 of max attrib packet. Changed from 3 to four in most recent update
Global Const $HEADER_MAX_ATTRIBUTES_CONST_22	= 0x04	;constant at word 22 of max attrib packet. Changed from 3 to four in most recent update
Global Const $HEADER_GO_PLAYER					= 0x32
; Global Const $HEADER_OPEN_GB_WINDOW				= 0xA0
; Global Const $HEADER_CLOSE_GB_WINDOW			= 0xA1
; Global Const $HEADER_START_RATING_GVG			= 0xAA
; Global Const $HEADER_EQUIP_BAG					= 0x37
; Global Const $HEADER_HOM_DIALOG					= 0x5A
; Global Const $HEADER_PROFESSION_ULOCK			= 0x42

#EndRegion Headers