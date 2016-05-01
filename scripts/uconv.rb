require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
3/29/2016 16:05:26	72317p - USS Reliant (prize)	Unique	Joachim	Independent	ACTION: Discard this card to add +3 to your Captain Skill Number until the End Phase of this round.  If you attack first in the Combat Phase as a result of this, during the Compare Results step, you may convert 1 of your [HIT] results into a [CRIT] result.	Crew	5	
3/29/2016 16:07:20	72317p - USS Reliant (prize)	Unique	Fire!	Independent	When attacking with your Primary Weapon, during the Roll Attack Dice step, you may discard this card to gain +2 attack dice.  If you do so, during the Modify Attack Dice step, you may re-roll up to 2 of your attack dice and then place an Auxiliary Power Token beside your ship.	Talent	6	
3/29/2016 16:08:56	72317p - USS Reliant (prize)	Unique	Ceti Eel	Independent	During the Combat Phase, you may discard this card to target a ship within Range 1-3 when it is that ship's turn to attack and force that ship to either: 1) attack any ship of your choice in its firing arc and within range, if possible, 2) not perform its attack and disable its Captain Card, or 3) perform its attack as normal and discard its Captain Card.  The target ship must choose one of these options.	Talent	6	
4/11/2016 19:51:06	72334 - IKS Drovana	Non-unique	Security Sensors	Klingon	If an enemy Upgrade or Captain targets your ship, immediately place an [EVADE] Token beside your ship, even if there is already one there.	Tech	5	
4/11/2016 19:52:45	72334 - IKS Drovana	Non-unique	Cloaked Mines	Klingon	During the Planning Phase, you may discard this card to place a Minefield Token within Range 1 of your ship (in any direction), but not within Range 3 of an enemy ship.  If an enemy ship passed within Range 1 of the token, roll 3 attack dice (-1 if the target ship immediately performs a [SCAN] Action).  Any [HIT] or [CRIT] damages the target ship as normal.  The affected ship does not roll any defense dice.	Tech	3	
4/11/2016 19:53:46	72334 - IKS Drovana	Non-unique	Emergency Power	Klingon	During the Activation Phase, if there is an Auxiliary Power Token beside your ship, you may disable this card to either perform a Red Maneuver or perform an Action.  No ship may be equipped with more than 1 "Emergency Power" Upgrade.	Tech	4	Yes
4/11/2016 19:55:14	72334 - IKS Drovana	Unique	Detonation Codes	Klingon	ACTION: Discard this card to target a Minefield Token with Range 1-3.  Roll the number of attack dice listed on the mine's Upgrade Card minus 1.  All ship within Range 1 of that Minefield Token suffer damage as normal from any [HIT] or [CRIT] results.  The affected ships do not roll any defense dice.  Remove the Minefield Token after it is detonated.	Talent	4	
4/11/2016 19:56:27	72334 - IKS Drovana	Unique	Bo'rak	Klingon	When attacking, during the Modify Defense Dice step, you may disable this card to force the defending ship to re-roll 1 of its defense dice of your choice.  When defending, you may roll your full defense dice in spite of the presence of an opposing ship's [SCAN] Token.	Crew	5	
4/19/2016 14:35:09	72333 - IRW Algeron	Unique	Command Pod	Romulan	When defending, during the Compare Results step, you may discard this card to cancel any 1 die result.  This Upgrade may only be fielded by a Captain assigned to a D7-class ship.	Talent	4	Yes
4/19/2016 14:35:52	72333 - IRW Algeron	Unique	Cloaked Attack	Romulan	When attacking with your Primary Weapon, during the Roll Attack Dice step, you may discard this card and spend your [CLOAK] Token to gain +2 attack dice.	Talent	5	
4/19/2016 14:37:06	72333 - IRW Algeron	Non-unique	Romulan Technical Officer	Romulan	ACTION: Disable this card to place a [SCAN] Token beside your ship.  You cannot perform the [SCAN] Action as a free Action this round.  This Upgrade may only be purchased for a Romulan ship and no ship may be equipped with more than 1 "Romulan Technical Officer" Upgrade.	Crew	2	Yes
4/19/2016 14:38:15	72333 - IRW Algeron	Non-unique	Impulse Drive	Romulan	You may disable this card to perform a white maneuver if there is an Auxiliary Power Token beside your ship.  If you do so, you must still skip your Perform Action step.  No ship may be equipped with more than 1 "Impulse Drive" Upgrade.	Tech	2	Yes
4/26/2016 14:01:23	72318p - Kruge's Bird-of-Prey	Unique	Retaliatory Strike	Klingon	If your ship was just damaged and the attacking ship is in your forward firing arc and within Range 2-3 of your ship, you may discard this card to immediately perform an attack against the attacking ship with one of your Photon Torpedoes Upgrades.  You must discard the Photon Torpedoes Upgrade when your attack is completed.  This attack is in addition to your normal attack for the round.	Talent	5	
4/26/2016 14:03:43	72318p - Kruge's Bird-of-Prey	Unique	Valkris	Klingon	ACTION: Target a ship at Range 1-3.  Discard this card and disable 1 Upgrade on the target ship ([CREW], [WEAPON], or [TECH]).  You may immediately use the Action listed on the Upgrade you disabled with this Action as if it were assigned to your ship.	Crew	5	
4/26/2016 14:05:21	72318p - Kruge's Bird-of-Prey	Unique	Torg	Klingon	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Discard this card and disable all Upgrades on the target ship.  The target ship rolls -1 attack die and -1 defense die while any of its Upgrades remain disabled.  Once there are no disabled Upgrades on the target ship, remove Torg's Continuous Effect TOken from beside the target ship.	Crew	6	
4/26/2016 14:06:46	72318p - Kruge's Bird-of-Prey	Unique	Maltz	Klingon	ACTION: If your ship is not Cloaked, discard this card to target a friendly ship within Range 1-2 of your ship.  Take up to 3 [CREW] Upgrades from that ship and deploy them to your ship, even if it exceeds your ship's restrictions, OR take up to 3 [CREW] Upgrades from your ship and deploy them to the target ship, even if it exceeds that ship's restrictions.	Crew	5	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
3/29/2016 16:01:59	72317p - USS Reliant (prize)	Unique	Khan Singh	7	Independent	You may use any Upgrades without paying a Faction penalty.   Up to 3 of the Upgrades you purchase for you ship cost exactly 4 SP each and are placed face down beside your Ship Card.  Each Upgrade remains face down until you decide to use it, and then it is turned face up for the rest of the game.  The printed cost on these Upgrades cannot be greater than 6.	1	4		
4/11/2016 19:46:43	72334 - IKS Drovana	Non-unique	Klingon	1	Klingon		0	0		
4/11/2016 19:48:01	72334 - IKS Drovana	Unique	Kurn	5	Klingon	During the Combat Phase, each time you defend, you may re-roll 1 of your [BATTLE STATIONS] results.  If this card is assigned to a Klingon ship, you may re-roll up to 2 of your [BATTLE STATIONS] results.  Kurn may field 1 Klingon [ELITE TALENT] Upgrade.	0	3	Yes	
4/19/2016 14:27:19	72333 - IRW Algeron	Non-unique	Romulan	1	Romulan		0	0		
4/19/2016 14:28:32	72333 - IRW Algeron	Unique	Tal	3	Romulan	If your ship is not Cloaked, you may perform a [BATTLE STATIONS] Action as your Standard Action, even if the [BATTLE STATIONS] Action is not on your ship's Action Bar.  You cannot perform any free Actions during the round in which you use this ability.	0	2		
4/26/2016 13:58:50	72318p - Kruge's Bird-of-Prey	Non-unique	Klingon	1	Klingon		0	0		
4/26/2016 13:59:44	72318p - Kruge's Bird-of-Prey	Unique	Kruge	7	Klingon	Add 1 [CREW] Upgrade slot to your Upgrade Bar.  When attacking with your Primary Weapon, during the Deal Damage step, you may discard one of your [CREW] Upgrades to inflict 1 additional damage to the defending ship.	1	4		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
3/29/2016 16:03:53	72317p - USS Reliant (prize)	Non-unique	All Power to Phasers	Independent			When attacking with your Primary Weapon, during the Roll Attack Dice step, you may discard this card to gain +2 attack dice.  If you do this you must disable all of your remaining Shields.	5	
4/11/2016 19:57:37	72334 - IKS Drovana	Non-unique	Photon Torpedoes	Klingon	5	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  If fired from a Vor'cha Class ship, add +1 attack die.	5	
4/19/2016 14:33:32	72333 - IRW Algeron	Non-unique	Plasma Torpedoes	Romulan	4	1-2	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may re-roll all of your blank results one time.  You may fire this weapon from your forward or rear firing arcs.	3	
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
4/11/2016 19:49:57	72334 - IKS Drovana	Unique	Gowron	Klingon	FLEET ACTION: If there is not already a [BATTLE STATIONS] Token beside your ship, place 1 [BATTLE STATIONS] Token beside your ship.  In addition, if your ship is a Klingon ship with a Klingon Captain assigned to it, you may immediately perform an additional Action from your Action Bar as a free Action.	0	1	3	5	ACTION: If there is not already a [BATTLE STATIONS] Token beside your ship, place 1 [BATTLE STATIONS] Token beside your ship.  In addition, if your ship is a Klingon ship with a Klingon Captain assigned to it, you may immediately perform an additional Action from your Action Bar as a free Action.	1	3	
4/19/2016 14:26:38	72333 - IRW Algeron	Unique	Liviana Charvanek	Romulan	FLEET ACTION: If your ship has the [CLOAK] ACTION on its Action Bar, place a [CLOAK] Token beside your ship then immediately perform an additional Action from your Action Bar as a free Action.	1	1	3	5	ACTION: If your ship has the [CLOAK] ACTION on its Action Bar, place a [CLOAK] Token beside your ship then immediately perform an additional Action from your Action Bar as a free Action.	1	3	
ADMIRALSTEXT

officers_text = <<-OFFICERSTEXT
OFFICERSTEXT

convert_terms(upgrade)
convert_terms(captains_text)
convert_terms(weapons_text)
convert_terms(admirals_text)
convert_terms(officers_text)

new_upgrades = File.open("new_upgrades.xml", "w")
new_captains = File.open("new_captains.xml", "w")
new_admirals = File.open("new_admirals.xml", "w")
new_officers = File.open("new_officers.xml", "w")

upgrade_lines = parse_data(upgrade)

def no_quotes(a)
  a
end

def parse_set(setId)
  setId = no_quotes(setId)
  if setId =~ /\#(\d+).*/
    return $1
  end
  return setId.gsub(" ", "").gsub("\"", "")
end

upgrade_lines.each do |raw_parts|
    parts = raw_parts.collect { |one_part| convert_line(one_part) }
    parts.shift
    expansion = parts.shift
    uniqueText = parts.shift
    title = parts.shift
    faction = parts.shift
    ability = parts.shift
    upType = parts.shift
    cost = parts.shift
    special = parts.shift
    unique = uniqueText == "Unique" ? "Y" : "N"
    mirrorUniverseUnique = uniqueText == "Mirror Universe Unique" ? "Y" : "N"
    setId = set_id_from_expansion(expansion)
    externalId = make_external_id(setId, title)
    upgradeXml = <<-SHIPXML
    <Upgrade>
      <Title>#{title}</Title>
      <Ability>#{ability}</Ability>
      <Unique>#{unique}</Unique>
      <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
      <Skill></Skill>
      <Talent></Talent>
      <Attack></Attack>
      <Range></Range>
      <Type>#{upType}</Type>
      <Faction>#{faction}</Faction>
      <Cost>#{cost}</Cost>
      <Id>#{externalId}</Id>
      <Set>#{setId}</Set>
      <Special>#{special}</Special>
    </Upgrade>
    SHIPXML
    new_upgrades.puts upgradeXml
end

weapons_lines = parse_data(weapons_text)

weapons_lines.each do |raw_parts|
    parts = raw_parts.collect { |one_part| convert_line(one_part) }
    parts.shift
    expansion = parts.shift
    uniqueText = parts.shift
    title = parts.shift
    faction = parts.shift
    attack = parts.shift
    range = parts.shift
    ability = parts.shift
    upType = "Weapon"
    cost = parts.shift
    special = parts.shift
    unique = uniqueText == "Unique" ? "Y" : "N"
    mirrorUniverseUnique = uniqueText == "Mirror Universe Unique" ? "Y" : "N"
    setId = set_id_from_expansion(expansion)
    externalId = make_external_id(setId, title)
    upgradeXml = <<-SHIPXML
    <Upgrade>
      <Title>#{title}</Title>
      <Ability>#{ability}</Ability>
      <Unique>#{unique}</Unique>
      <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
      <Skill></Skill>
      <Talent></Talent>
      <Attack>#{attack}</Attack>
      <Range>#{range}</Range>
      <Type>#{upType}</Type>
      <Faction>#{faction}</Faction>
      <Cost>#{cost}</Cost>
      <Id>#{externalId}</Id>
      <Set>#{setId}</Set>
      <Special>#{special}</Special>
    </Upgrade>
    SHIPXML
    new_upgrades.puts upgradeXml
end

captains_lines = parse_data(captains_text)

captains_lines.each do |raw_parts|
  parts = raw_parts.collect { |one_part| convert_line(one_part) }
  parts.shift
  expansion = parts.shift
  uniqueText = parts.shift
  title = parts.shift
  skill = parts.shift
  faction = parts.shift
  ability = parts.shift
  upType = "Captain"
  talent = parts.shift
  cost = parts.shift
  special = parts.shift
  unique = uniqueText == "Unique" ? "Y" : "N"
  mirrorUniverseUnique = uniqueText == "Mirror Universe Unique" ? "Y" : "N"
  setId = set_id_from_expansion(expansion)
  externalId = make_external_id(setId, title)
  upgradeXml = <<-SHIPXML
  <Captain>
    <Title>#{title}</Title>
    <Ability>#{ability}</Ability>
    <Unique>#{unique}</Unique>
    <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
    <Skill>#{skill}</Skill>
    <Talent>#{talent}</Talent>
    <Attack></Attack>
    <Range></Range>
    <Type>#{upType}</Type>
    <Faction>#{faction}</Faction>
    <Cost>#{cost}</Cost>
    <Id>#{externalId}</Id>
    <Set>#{setId}</Set>
    <Special>#{special}</Special>
  </Captain>
  SHIPXML
  new_captains.puts upgradeXml
end

admirals_lines = parse_data(admirals_text)
admirals_lines.each do |raw_parts|
  parts = raw_parts.collect { |one_part| convert_line(one_part) }
  parts.shift
  expansion = parts.shift
  uniqueText = parts.shift
  unique = uniqueText == "Unique" ? "Y" : "N"
  mirrorUniverseUnique = uniqueText == "Mirror Universe Unique" ? "Y" : "N"
  title = parts.shift
  faction = parts.shift
  admiralAbility = parts.shift
  skillModifier = parts.shift
  admiralTalent = parts.shift
  admiralCost = parts.shift
  skill = parts.shift
  ability = parts.shift
  upType = "Admiral"
  talent = parts.shift
  cost = parts.shift
  special = parts.shift
  setId = set_id_from_expansion(expansion)
  externalId = make_external_id(setId, title)
  externalId2 = make_external_id(setId, title + " cap")
  upgradeXml = <<-SHIPXML
  <Admiral>
    <Title>#{title}</Title>
    <Ability>#{ability}</Ability>
    <Unique>#{unique}</Unique>
    <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
    <Skill>#{skill}</Skill>
    <Talent>#{talent}</Talent>
    <Attack></Attack>
    <Range></Range>
    <Type>#{upType}</Type>
    <Faction>#{faction}</Faction>
    <Cost>#{cost}</Cost>
    <Id>#{externalId}</Id>
    <Set>#{setId}</Set>
    <Special>#{special}</Special>
    <AdmiralAbility>#{admiralAbility}</AdmiralAbility>
    <AdmiralCost>#{admiralCost}</AdmiralCost>
    <AdmiralTalent>#{admiralTalent}</AdmiralTalent>
    <SkillModifier>#{skillModifier}</SkillModifier>
  </Admiral>
  SHIPXML
  new_admirals.puts upgradeXml
  upgradeXml = <<-SHIPXML
  <Captain>
    <Title>#{title}</Title>
    <Ability>#{ability}</Ability>
    <Unique>#{unique}</Unique>
    <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
    <Skill>#{skill}</Skill>
    <Talent>#{talent}</Talent>
    <Attack></Attack>
    <Range></Range>
    <Type>Captain</Type>
    <Faction>#{faction}</Faction>
    <Cost>#{cost}</Cost>
    <Id>#{externalId2}</Id>
    <Set>#{setId}</Set>
    <Special>#{special}</Special>
    <AdmiralAbility>#{admiralAbility}</AdmiralAbility>
    <AdmiralCost>#{admiralCost}</AdmiralCost>
    <AdmiralTalent>#{admiralTalent}</AdmiralTalent>
    <SkillModifier>#{skillModifier}</SkillModifier>
  </Captain>
  SHIPXML
  new_captains.puts upgradeXml

end


officers_lines = parse_data(officers_text)
officers_lines.each do |raw_parts|
  parts = raw_parts.collect { |one_part| convert_line(one_part) }
  parts.shift
  expansion = "CollectiveOP3"
  unique = "Y"
  title = parts.shift
  faction = "Independent"
  officerAbility = parts.shift
  cost = parts.shift
  ability = parts.shift
  upType = "Captain"
  talent = parts.shift
  skill = parts.shift
  setId = set_id_from_expansion(expansion)
  externalId = make_external_id(setId, title)
  upgradeXml = <<-SHIPXML
  <Officer>
    <Title>#{title}</Title>
    <Ability>#{officerAbility}</Ability>
    <Unique>#{unique}</Unique>
    <Attack></Attack>
    <Range></Range>
    <Type>Officer</Type>
    <Faction>#{faction}</Faction>
    <Cost>#{cost}</Cost>
    <Id>#{externalId}</Id>
    <Set>#{setId}</Set>
    <Special></Special>
  </Officer>
  SHIPXML
  new_officers.puts upgradeXml
end
