require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
9/15/2014 21:18:06	71646a - Bok's Marauder	Thought Maker	Ferengi	During the Planning Phase, after every ship has been assigned a Maneuver Dial, you may discard this card to target a ship within Range 1-2.  If you do so, look at that ship's Maneuver Dial and change it to any of its 1 or 2 Green Maneuvers (your choice).  That Maneuver Dial cannot be changed nor can its player look at it until it is that ship's turn to activate.  The target ship's player may place an Auxiliary Power Token beside the target ship to ignore the new Maneuver and not move that round.  This Upgrade may only be purchased for a Ferengi ship.	Tech	4	Unique																			
9/15/2014 21:19:20	71646a - Bok's Marauder	Vengeance	Ferengi	When attacking a ship at Range 1, during the Roll Attack Dice step of the Combat Phase, you may discard this card to roll up to +2 additional attack dice.  If you do so, when the attack is completed your ship suffers 1 normal damage for each die you rolled. This Upgrade may only be purchased for a Ferengi Captain assigned to a Ferengi ship.	Talent	2	Unique																			
9/15/2014 21:20:52	71646a - Bok's Marauder	Kazago	Ferengi	ACTION: Discard this card to place 1 [EVADE] Token and 1 [BATTLE STATIONS] Token beside your ship.  You cannot perform an [EVASIVE MANEUVERS] or a [BATTLE STATIONS] Action as a free Action this round. OR ACTION: Discard your current Captain Card and treat this card as your new Captain.  While Kazago is your Captain, your Skill Number is 4.	Crew	2	Unique																			
9/15/2014 21:25:55	71646b - Prakesh	Tasha Yar	Mirror Universe	If your ship was just destroyed, discard this card to target 1 enemy ship within Range 1-3, if possible. Immediately make 1 free attack against that ship with 4 attack dice. If the target ship is in your forward firing arc, that ship rolls -2 defense dice against this attack.	Crew	2	Mirror Universe Unique																			
9/15/2014 21:26:41	71646b - Prakesh	Cloaking Device	Mirror Universe	Instead of performing a normal Action, you may disable this card to perform the [CLOAK] Action. While you have a [CLOAK] token beside your ship, you may perform the [SENSOR ECHO] Action even if this card is disabled. This upgrade costs +5 Squadron Points for any non-Mirror Universe ship.	Tech	4	Non-unique																			
9/15/2014 21:37:29	71646c - Relora-Sankur	Tersa	Kazon	ACTION:  If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1 - 2 that is not Cloaked and has no Active Shields.  Discard Tersa and 1 [CREW] Upgrade of your choice on the target ship.  Place a [SCAN] Token beside your ship.	Crew	2	Unique																			
9/15/2014 21:38:31	71646c - Relora-Sankur	Tractor Beam	Kazon	During the Activation Phase, when a ship within Range 1 of your ship reveals a Maneuver with a number of 3 or higher, before that ship moves, you may discard this card to subtract 2 from that Maneuver's number. No ship may be equipped with more than 1 of this Upgrade.	Tech	2	Non-unique																			
9/15/2014 21:18:11	71646d - Scout 255	Access Terminal	Borg	When you are required to spend any number of Drone Tokens, you may disable this card to spend those Drone Tokens from your ship and/or any friendly ship(s) within Range 1-2 of your ship. You may divide spending those Drone Tokens between your ships however you like.	Tech	2	Non-unique																			
9/15/2014 21:18:32	71646d - Scout 255	One	Borg	ACTION: Discard this card to perform this Action. For each damage your ship suffers this round, disable 1 of your Active Shields instead of destroying it. If you have no Active Shields left, any excess damage is applied to your Hull as normal.	Crew	4	Unique																			
9/15/2014 21:19:01	71646d - Scout 255	Dispersion Field	Borg	While this card is deployed to your ship, none of your other Upgrades can be affected by your opponents. In addition, you may roll your full defense dice in spite of the presence of an opposing ship’s [SCAN] Token.	Borg	2	Unique																			
9/15/2014 21:40:03	71646e - Tal'Kir	Vulcan Logic	Vulcan	During the Roll Defense Dice step of the Combat Phase, you may discard this card to roll +2 defense dice. If you do so, during the Modify Defense Dice step, you may re-roll any number of your defense dice. This Upgrade may only be purchased for a Vulcan Captain on assigned to a Vulcan ship.	Talent	4	Unique																			
9/15/2014 21:41:08	71646e - Tal'Kir	Kov	Vulcan	ACTION: Discard this card to repair up to 2 damage to your ship’s Hull or Shields.	Crew	4	Unique																			
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
9/15/2014 21:14:53	71646a - Bok's Marauder	Bok's Marauder	6	Ferengi	ACTION: Gain +1 attack die to each of your attacks and roll -1 defense die each time you defend this round.	1	4	Unique																		
9/15/2014 21:23:55	71646b - Prakesh	Elim Garak	3	Mirror Universe	During the Roll Attack Dice step of the Combat Phase, you may discard 1 of your [CREW] Upgrades to roll +1 attack die.	0	2	Mirror Universe Unique																		
9/15/2014 21:34:06	71646c - Relora-Sankur	Haron	3	Kazon	Add 1 [WEAPON] Upgrade slot to your Upgrade Bar. All of your Kazon [WEAPON] Upgrades cost -1 SP.	0	2	Unique																		
9/15/2014 21:16:31	71646d - Scout 255	Tactical Drone	2	Borg	At the start of the game, place 2 Drone Tokens on this card. During the Activation Phase, before you move, you may spend 1 Drone Token to remove 1 Auxiliary Power Token from beside your ship.	0	2	Non-unique																		
9/15/2014 21:42:36	71646e - Tal'Kir	Solok	6	Vulcan	You may perform an [EVASIVE MANEUVERS] or a [SCAN] Action as a free Action each round.  If you do so, place an Auxiliary Power Token beside your ship.	1	4	Unique																		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
9/15/2014 21:16:09	71646a - Bok's Marauder	Photon Torpedoes	Ferengi	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack. You may fire this weapon from your forward or rear firing arcs.	4	Non-unique																		
9/15/2014 21:24:42	71646b - Prakesh	Forward Weapons Grid	Mirror Universe	6	1-2	ATTACK: Disable this card to perform this attack. You must divide this attack between 2 different ships in your forward firing arc. You may divide your attack dice however you like, but you must roll at least 2 attack dice against each ship. Place an Auxiliary Power Token beside your ship.	4	Non-unique																		
9/15/2014 21:25:18	71646b - Prakesh	Dorsal Weapons Array	Mirror Universe	3	1-2	ATTACK: Disable this card to perform this attack. You may fire this weapon in any direction.	2	Non-unique																		
9/15/2014 21:35:38	71646c - Relora-Sankur	Photonic Charges	Kazon	4	1	ATTACK: Disable this card to perform this attack. Place an Auxiliarly Power Token beside the target ship if there is at least 1 uncancelled [HIT] or [CRIT] result.This Upgrade costs +4 SP if purchased for a non-Predator class ship.	4	Non-unique																		
9/15/2014 21:36:16	71646c - Relora-Sankur	Particle Beam Weapon	Kazon	4	1-2	ATTACK: Disable this card to perform this attack. You may fire this weapon from your forward or rear firing arcs.	4	Non-unique																		
9/15/2014 21:17:36	71646d - Scout 255	Proton beam	Borg	3	1	ATTACK: Disable this card to perform this attack. All damage inflicted by this attack ignores the opposing ship’s Shields. This upgrade costs +5 SP for any non-Borg ship.	4	Non-unique																		
9/15/2014 21:43:55	71646e - Tal'Kir	Photonic Weapon	Vulcan	4	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack. You may re-roll all of your blank results one time. You may fire this weapon from your forward or rear firing arcs. 	4	Non-unique																		
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
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

upgrade_lines = upgrade.split "\n"

def no_quotes(a)
    a.gsub("\"", "")
end

def parse_set(setId)
  setId = no_quotes(setId)
  if setId =~ /\#(\d+).*/
    return $1
  end
  return setId.gsub(" ", "").gsub("\"", "")
end

upgrade_lines.each do |l|
    l = convert_line(l)
    parts = l.split "\t"
    parts.shift
    expansion = parts.shift
    title = parts.shift
    faction = parts.shift
    ability = parts.shift
    upType = parts.shift
    cost = parts.shift
    uniqueText = parts.shift
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
      <Special></Special>
    </Upgrade>
    SHIPXML
    new_upgrades.puts upgradeXml
end

weapons_lines = weapons_text.split "\n"

weapons_lines.each do |l|
    l = convert_line(l)
# Timestamp	Expansion Pack	Weapon Name	Faction	Attack	Range	Ability	Cost	Uniqueness																		
    parts = l.split "\t"
    parts.shift
    expansion = parts.shift
    title = parts.shift
    faction = parts.shift
    attack = parts.shift
    range = parts.shift
    ability = parts.shift
    upType = "Weapon"
    cost = parts.shift
    uniqueText = parts.shift
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
      <Special></Special>
    </Upgrade>
    SHIPXML
    new_upgrades.puts upgradeXml
end

captains_lines = captains_text.split "\n"
captains_lines.each do |l|
  l = convert_line(l)
#Timestamp	Expansion Pack	Captain Name	Skill	Faction	Ability	Talents	Cost	Uniqueness																		  
  parts = l.split "\t"
  parts.shift
  expansion = parts.shift
  title = parts.shift
  skill = parts.shift
  faction = parts.shift
  ability = parts.shift
  upType = "Captain"
  talent = parts.shift
  cost = parts.shift
  uniqueText = parts.shift
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
    <Special></Special>
  </Captain>
  SHIPXML
  new_captains.puts upgradeXml
end

admirals_lines = admirals_text.split "\n"
admirals_lines.each do |l|
  l = convert_line(l)
  # Timestamp		Admiral Name	Faction	Fleet Action	Skill Modifier	Talents	Cost	Captain-side Cost	Captain-side Action	Captain-side Talents	Captain-side Skill
  parts = l.split "\t"
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
  cost = parts.shift
  ability = parts.shift
  upType = "Captain"
  talent = parts.shift
  skill = parts.shift
  setId = set_id_from_expansion(expansion)
  externalId = make_external_id(setId, title)
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
    <Special></Special>
    <AdmiralAbility>#{admiralAbility}</AdmiralAbility>
    <AdmiralCost>#{admiralCost}</AdmiralCost>
    <AdmiralTalent>#{admiralTalent}</AdmiralTalent>
    <SkillModifier>#{skillModifier}</SkillModifier>
  </Admiral>
  SHIPXML
  new_admirals.puts upgradeXml
end


officers_lines = officers_text.split "\n"
officers_lines.each do |l|
  l = convert_line(l)
# Timestamp	Officer Name	Ability	Cost																						  parts = l.split "\t"
  parts = l.split "\t"
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
