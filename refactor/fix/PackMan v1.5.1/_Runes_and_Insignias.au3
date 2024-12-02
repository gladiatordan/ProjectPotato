#include-once

; Authors: Air.Fox/Logicdoor

; Valuable runes and insignias that should be salvaged have a '1' in col. 5 ↓


; Name, 									ModelID, Index, Modstruct, Salvage indicator
Global $ARRAY_RUNES[183][5] = [ _
	["Knight's Insignia [Warrior]",				19152,	0, "F9010824",		0], _
	["Lieutenant's Insignia [Warrior]",			19153,	0, "08020824",		0], _
	["Stonefist Insignia [Warrior]",			19154,	0, "09020824",		0], _
	["Dreadnought Insignia [Warrior]",			19155,	0, "FA010824",		0], _
	["Sentinel's Insignia [Warrior]",			19156,	0, "FB010824",		1], _
	["Minor Absorption [Warrior]",				903,	1, "EA02E827",		0], _
	["Minor Axe Mastery [Warrior]",				903,	1, "0112E821",		0], _
	["Minor Hammer Mastery [Warrior]",			903,	1, "0113E821",		0], _
	["Minor Strength [Warrior]",				903,	1, "0111E821",		0], _
	["Minor Swordsmanship [Warrior]",			903,	1, "0114E821",		1], _
	["Minor Tactics [Warrior]",					903,	1, "0115E821",		1], _
	["Major Absorption [Warrior]",				5558,	1, "EA02E927",		0], _
	["Major Axe Mastery [Warrior]",				5558,	1, "0212E8217301",	0], _
	["Major Hammer Mastery [Warrior]",			5558,	1, "0213E8217301",	0], _
	["Major Strength [Warrior]",				5558,	1, "0211E8217301",	0], _
	["Major Swordsmanship [Warrior]",			5558,	1, "0214E8217301",	0], _
	["Major Tactics [Warrior]",					5558,	1, "0215E8217301",	0], _
	["Superior Axe Mastery [Warrior]",			5559,	1, "0312E8217F01",	0], _
	["Superior Hammer Mastery [Warrior]",		5559,	1, "0313E8217F01",	0], _
	["Superior Strength [Warrior]",				5559,	1, "0311E8217F01",	0], _
	["Superior Swordsmanship [Warrior]",		5559,	1, "0314E8217F01",	0], _
	["Superior Tactics [Warrior]",				5559,	1, "0315E8217F01",	0], _
	["Superior Absorption [Warrior]",			5559,	1, "EA02EA27",		0], _
	["Frostbound Insignia [Ranger]",			19157,	0, "FC010824",		0], _
	["Pyrebound Insignia [Ranger]",				19159,	0, "FE010824",		0], _
	["Stormbound Insignia [Ranger]",			19160,	0, "FF010824",		0], _
	["Scout's Insignia [Ranger]",				19162,	0, "01020824",		0], _
	["Earthbound Insignia [Ranger]",			19158,	0, "FD010824",		0], _
	["Beastmaster's Insignia [Ranger]",			19161,	0, "00020824",		1], _
	["Minor Beast Mastery [Ranger]",			904,	1, "0116E821",		0], _
	["Minor Expertise [Ranger]",				904,	1, "0117E821",		1], _
	["Minor Marksmanship [Ranger]",				904,	1, "0119E821",		1], _
	["Minor Wilderness Survival [Ranger]",		904,	1, "0118E821",		0], _
	["Major Beast Mastery [Ranger]",			5560,	1, "0216E8217501",	0], _
	["Major Expertise [Ranger]",				5560,	1, "0217E8217501",	0], _
	["Major Marksmanship [Ranger]",				5560,	1, "0219E8217501",	0], _
	["Major Wilderness Survival [Ranger]",		5560,	1, "0218E8217501",	0], _
	["Superior Beast Mastery [Ranger]",			5561,	1, "0316E8218101",	0], _
	["Superior Expertise [Ranger]",				5561,	1, "0317E8218101",	0], _
	["Superior Marksmanship [Ranger]",			5561,	1, "0319E8218101",	0], _
	["Superior Wilderness Survival [Ranger]",	5561,	1, "0318E8218101",	0], _
	["Wanderer's Insignia [Monk]", 				19149,	0, "F6010824",		0], _
	["Disciple's Insignia [Monk]", 				19150,	0, "F7010824",		0], _
	["Anchorite's Insignia [Monk]", 			19151,	0, "F8010824",		1], _
	["Minor Divine Favor [Monk]", 				902,	1, "0110E821",		1], _
	["Minor Healing Prayers [Monk]", 			902,	1, "010DE821",		0], _
	["Minor Protection Prayers [Monk]", 		902,	1, "010FE821",		1], _
	["Minor Smiting Prayers [Monk]", 			902,	1, "010EE821",		0], _
	["Major Healing Prayers [Monk]", 			5556,	1, "020DE8217101",	0], _
	["Major Protection Prayers [Monk]", 		5556,	1, "020FE8217101",	0], _
	["Major Smiting Prayers [Monk]", 			5556,	1, "020EE8217101",	0], _
	["Major Divine Favor [Monk]", 				5556,	1, "0210E8217101",	0], _
	["Superior Divine Favor [Monk]", 			5557,	1, "0310E8217D01",	0], _
	["Superior Healing Prayers [Monk]", 		5557,	1, "030DE8217D01",	1], _
	["Superior Protection Prayers [Monk]", 		5557,	1, "030FE8217D01",	0], _
	["Superior Smiting Prayers [Monk]",			5557,	1, "030EE8217D01",	0], _
	["Bloodstained Insignia [Necromancer]",		19138,	0, "0A020824",		1], _
	["Tormentor's Insignia [Necromancer]",		19139,	0, "EC010824",		1], _
	["Bonelace Insignia [Necromancer]",			19141,	0, "EE010824",		0], _
	["Minion Master's Insignia [Necromancer]",	19142,	0, "EF010824",		0], _
	["Blighter's Insignia [Necromancer]",		19143,	0, "F0010824",		0], _
	["Undertaker's Insignia [Necromancer]",		19140,	0, "ED010824",		0], _
	["Minor Blood Magic [Necromancer]",			900,	1, "0104E821",		0], _
	["Minor Curses [Necromancer]", 				900,	1, "0107E821",		1], _
	["Minor Death Magic [Necromancer]", 		900,	1, "0105E821",		0], _
	["Minor Soul Reaping [Necromancer]", 		900,	1, "0106E821",		1], _
	["Major Blood Magic [Necromancer]",			5552,	1, "0204E8216D01",	0], _
	["Major Curses [Necromancer]",				5552,	1, "0207E8216D01",	0], _
	["Major Death Magic [Necromancer]",			5552,	1, "0205E8216D01",	0], _
	["Major Soul Reaping [Necromancer]", 		5552,	1, "0206E8216D01",	1], _
	["Superior Blood Magic [Necromancer]", 		5553,	1, "0304E8217901",	0], _
	["Superior Curses [Necromancer]",			5553,	1, "0307E8217901",	0], _
	["Superior Death Magic [Necromancer]",		5553,	1, "0305E8217901",	1], _
	["Superior Soul Reaping [Necromancer",		5553,	1, "0306E8217901",	1], _
	["Virtuoso's Insignia [Mesmer]", 			19130,	0, "E4010824",		0], _
	["Artificer's Insignia [Mesmer]", 			19128,	0, "E2010824",		0], _
	["Prodigy's Insignia [Mesmer]", 			19129,	0, "E3010824",		1], _
	["Minor Domination Magic [Mesmer]", 		899,	1, "0102E821",		0], _
	["Minor Fast Casting [Mesmer]", 			899,	1, "0100E821",		1], _
	["Minor Illusion Magic [Mesmer]", 			899,	1, "0101E821",		0], _
	["Minor Inspiration Magic [Mesmer]", 		899,	1, "0103E821",		1], _
	["Major Domination Magic [Mesmer]", 		3612,	1, "0202E8216B01",	0], _
	["Major Fast Casting [Mesmer]", 			3612,	1, "0200E8216B01",	0], _
	["Major Illusion Magic [Mesmer]", 			3612,	1, "0201E8216B01",	0], _
	["Major Inspiration Magic [Mesmer]", 		3612,	1, "0203E8216B01",	0], _
	["Superior Domination Magic [Mesmer]", 		5549,	1, "0302E8217701",	1], _
	["Superior Fast Casting [Mesmer]", 			5549,	1, "0300E8217701",	1], _
	["Superior Illusion Magic [Mesmer]", 		5549,	1, "0301E8217701",	0], _
	["Superior Inspiration Magic [Mesmer]", 	5549,	1, "0303E8217701",	0], _
	["Hydromancer Insignia [Elementalist]", 	19145,	0, "F2010824",		0], _
	["Geomancer Insignia [Elementalist]", 		19146,	0, "F3010824",		0], _
	["Pyromancer Insignia [Elementalist]", 		19147,	0, "F4010824",		0], _
	["Aeromancer Insignia [Elementalist]", 		19148,	0, "F5010824",		0], _
	["Prismatic Insignia [Elementalist]", 		19144,	0, "F1010824",		0], _
	["Minor Air Magic [Elementalist]", 			901,	1, "0108E821",		0], _
	["Minor Earth Magic [Elementalist]", 		901,	1, "0109E821",		0], _
	["Minor Energy Storage [Elementalist]", 	901,	1, "010CE821",		1], _
	["Minor Water Magic [Elementalist]", 		901,	1, "010BE821",		0], _
	["Minor Fire Magic [Elementalist]", 		901,	1, "010AE821",		1], _
	["Major Air Magic [Elementalist]", 			5554,	1, "0208E8216F01",	0], _
	["Major Earth Magic [Elementalist]", 		5554,	1, "0209E8216F01",	0], _
	["Major Energy Storage [Elementalist]", 	5554,	1, "020CE8216F01",	0], _
	["Major Fire Magic [Elementalist]", 		5554,	1, "020AE8216F01",	0], _
	["Major Water Magic [Elementalist]", 		5554,	1, "020BE8216F01",	0], _
	["Superior Air Magic [Elementalist]", 		5555,	1, "0308E8217B01",	1], _
	["Superior Earth Magic [Elementalist]", 	5555,	1, "0309E8217B01",	0], _
	["Superior Energy Storage [Elementalist]",	5555,	1, "030CE8217B01",	1], _
	["Superior Fire Magic [Elementalist]", 		5555,	1, "030AE8217B01",	0], _
	["Superior Water Magic [Elementalist]", 	5555,	1, "030BE8217B01",	0], _
	["Vanguard's Insignia [Assassin]", 			19124,	0, "DE010824",		0], _
	["Infiltrator's Insignia [Assassin]", 		19125,	0, "DF010824",		0], _
	["Saboteur's Insignia [Assassin]", 			19126,	0, "E0010824",		0], _
	["Nightstalker's Insignia [Assassin]", 		19127,	0, "E1010824",		1], _
	["Minor Critical Strikes [Assassin]", 		6324,	1, "0123E821",		1], _
	["Minor Dagger Mastery [Assassin]",			6324,	1, "011DE821",		0], _
	["Minor Deadly Arts [Assassin]", 			6324,	1, "011EE821",		0], _
	["Minor Shadow Arts [Assassin]", 			6324,	1, "011FE821",		0], _
	["Major Critical Strikes [Assassin]", 		6325,	1, "0223E8217902",	0], _
	["Major Dagger Mastery [Assassin]", 		6325,	1, "021DE8217902",	0], _
	["Major Deadly Arts [Assassin]", 			6325,	1, "021EE8217902",	0], _
	["Major Shadow Arts [Assassin]", 			6325,	1, "021FE8217902",	0], _
	["Superior Critical Strikes [Assassin]", 	6326,	1, "0323E8217B02",	0], _
	["Superior Dagger Mastery [Assassin]", 		6326,	1, "031DE8217B02",	0], _
	["Superior Deadly Arts [Assassin]", 		6326,	1, "031EE8217B02",	0], _
	["Superior Shadow Arts [Assassin]", 		6326,	1, "031FE8217B02",	0], _
	["Shaman's Insignia [Ritualist]",			19165,	0, "04020824",		1], _
	["Ghost Forge Insignia [Ritualist]",		19166,	0, "05020824",		0], _
	["Mystic's Insignia [Ritualist]",			19167,	0, "06020824",		0], _
	["Minor Channeling Magic [Ritualist]",		6327,	1, "0122E821",		0], _
	["Minor Communing [Ritualist]",				6327,	1, "0120E821",		1], _
	["Minor Restoration Magic [Ritualist]",		6327,	1, "0121E821",		0], _
	["Minor Spawning Power [Ritualist]",		6327,	1, "0124E821",		1], _
	["Major Channeling Magic [Ritualist]",		6328,	1, "0222E8217F02",	0], _
	["Major Communing [Ritualist]",				6328,	1, "0220E8217F02",	0], _
	["Major Restoration Magic [Ritualist]",		6328,	1, "0221E8217F02",	0], _
	["Major Spawning Power [Ritualist]",		6328,	1, "0224E8217F02",	0], _
	["Superior Channeling Magic [Ritualist]",	6329,	1, "0322E8218102",	1], _
	["Superior Communing [Ritualist]",			6329,	1, "0320E8218102",	1], _
	["Superior Restoration Magic [Ritualist]",	6329,	1, "0321E8218102",	0], _
	["Superior Spawning Power [Ritualist]",		6329,	1, "0324E8218102",	1], _
	["Windwalker Insignia [Dervish]", 			19163,	0, "02020824",		1], _
	["Forsaken Insignia [Dervish]", 			19164,	0, "03020824",		0], _
	["Minor Earth Prayers[Dervish]", 			15545,	1, "012BE821",		0], _
	["Minor Mysticism[Dervish]", 				15545,	1, "012CE821",		1], _
	["Minor Scythe Mastery[Dervish]", 			15545,	1, "0129E821",		1], _
	["Minor Wind Prayers[Dervish]", 			15545,	1, "012AE821",		0], _
	["Major Earth Prayers[Dervish]", 			15546,	1, "022BE8210703",	0], _
	["Major Mysticism[Dervish]", 				15546,	1, "022CE8210703",	0], _
	["Major Scythe Mastery[Dervish]", 			15546,	1, "0229E8210703",	0], _
	["Major Wind Prayers[Dervish]", 			15546,	1, "022AE8210703",	0], _
	["Superior Earth Prayers[Dervish]", 		15547,	1, "032BE8210903",	0], _
	["Superior Mysticism[Dervish]", 			15547,	1, "032CE8210903",	0], _
	["Superior Scythe Mastery[Dervish]", 		15547,	1, "0329E8210903",	0], _
	["Superior Wind Prayers[Dervish]", 			15547,	1, "032AE8210903",	0], _
	["Centurion's Insignia [Paragon]",			19168,	0, "07020824",		1], _
	["Minor Command [Paragon]",					15548,	1, "0126E821",		0], _
	["Minor Leadership [Paragon]",				15548,	1, "0128E821",		0], _
	["Minor Motivation [Paragon]",				15548,	1, "0127E821",		0], _
	["Minor Spear Mastery [Paragon]",			15548,	1, "0125E821",		1], _
	["Major Command [Paragon]",					15549,	1, "0226E8210D03",	0], _
	["Major Leadership [Paragon]",				15549,	1, "0228E8210D03",	0], _
	["Major Motivation [Paragon]",				15549,	1, "0227E8210D03",	0], _
	["Major Spear Mastery [Paragon]",			15549,	1, "0225E8210D03",	0], _
	["Superior Command [Paragon]",				15550,	1, "0326E8210F03",	0], _
	["Superior Leadership [Paragon]",			15550,	1, "0328E8210F03",	0], _
	["Superior Motivation [Paragon]",			15550,	1, "0327E8210F03",	0], _
	["Superior Spear Mastery [Paragon]",		15550,	1, "0325E8210F03",	0], _
	["Survivor Insignia", 						19132,	0, "E6010824",		0], _
	["Radiant Insignia",		 				19131,	0, "E5010824",		1], _
	["Stalwart Insignia", 						19133,	0, "E7010824",		0], _
	["Brawler's Insignia", 						19134,	0, "E8010824",		1], _
	["Blessed Insignia", 						19135,	0, "E9010824",		1], _
	["Herald's Insignia", 						19136,	0, "EA010824",		0], _
	["Sentry's Insignia", 						19137,	0, "EB010824",		0], _
	["Rune of Minor Vigor", 					898,	1, "C202E827",		1], _
	["Rune of Vitae", 							898,	1, "000A4823",		1], _
	["Rune of Attunement", 						898,	1, "0200D822",		1], _
	["Rune of Major Vigor", 					5550,	1, "C202E927",		1], _
	["Rune of Recovery", 						5550,	1, "07047827",		0], _
	["Rune of Restoration", 					5550,	1, "00037827",		0], _
	["Rune of Clarity", 						5550,	1, "01087827",		0], _
	["Rune of Purity", 							5550,	1, "05067827",		0], _
	["Rune of Superior Vigor", 					5551,	1, "C202EA27",		1]  _
]
