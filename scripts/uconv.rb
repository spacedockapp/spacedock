require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
9/8/2015 17:18:29	72002p - USS Intrepid	Unique	Flag Officer	Federation	After you move, you may discard this card to target 1 friendly ship within Range 1-2 of your ship. The target ship may immediately perform 1 free Action.	Talent	4	
9/8/2015 17:19:17	72002p - USS Intrepid	Non-unique	Vulcan Engineer	Federation	ACTION: If there are no enemy ships within Range 1-3 of your ship, repair 1 of your Shield Tokens.  You do not pay a faction penalty when assigning this card to a Vulcan ship.	Crew	3	
9/8/2015 18:31:11	72002p - USS Intrepid	Non-unique	Astrogator	Federation	ACTION: Discard this card to perform an additional non-red maneuver on your maneuver dial with a speed of 1 or 2.  This  Upgrade may only be purchased for a Constitution-class ship and you may fill a [CREW] or [WEAPON] slot on your Upgrade Bar with this Upgrade.  No ship may be equipped with more than 1 Astrogator Upgrade.	?	3	Yes
9/10/2015 10:42:06	72221a - IRW Belak	Unique	Tal Shiar	Romulan	During the Planning Phase, after all ships have chosen their maneuvers, you may discard this card to target a ship at Range 1-3 and look at that ship's maneuver dial.  Then place a [BATTLE STATIONS] Token beside your ship.  You cannot perform a [BATTLE STATIONS] Action (even as a free Action) this round.  This Upgrade may only be purchased for a Romulan Captain.	Talent	5	Yes
9/10/2015 10:43:42	72221a - IRW Belak	Unique	Tellera	Romulan	ACTION: Target a ship at Range 1-2 and roll 1 attack die.  If you roll a [HIT] or [CRIT] result, discard this card and 1 [CREW] Upgrade on the target ship.	Crew	3	
9/10/2015 10:47:46	72221a - IRW Belak	Non-unique	Modified Cloaking Device	Romulan	On the round you perform a [CLOAK] Action, your ship can only be target locked by a ship that is within Range 1 of your ship.  In addition, you may roll your full defense dice in spite of the presence of an opposing ship's [SCAN] Token while you are cloaked.	Tech	5	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
9/8/2015 17:17:18	72002p - USS Intrepid	Non-unique	Federation	1	Federation		0	0		
9/10/2015 10:37:20	72221a - IRW Belak	Non-unique	Romulan	1	Romulan		0	0		
9/10/2015 10:40:04	72221a - IRW Belak	Unique	Lovok	3	Romulan	During the Modify Attack Dice step, you may re-roll all of your blank results.  If you do so, place an Auxiliary Power Token beside your ship.  Lovok may field the "Tal Shiar" [ELITE TALENT] Upgrade.	0	2	Yes	
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
9/8/2015 17:21:12	72002p - USS Intrepid	Non-unique	Dual Phaser Banks	Federation			When attacking with your Primary Weapon, during the Roll Attack Dice step, you may disable this card to gain +1 attack die.   This Upgrade may only be purchased for a Federation ship and costs +3 SP for any ship other than a Constitution-class ship. No ship may be equipped with more than 1 Dual Phaser Banks Upgrade. 	3	Yes
9/10/2015 10:44:59	72221a - IRW Belak	Non-unique	Aft Disruptor Emitters	Romulan	3	1-3	ATTACK: Disable this card to perform this attack.  You may only fire this weapon at a ship that is not in your forward firing arc.	2	
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
9/8/2015 17:39:56	72002p - USS Intrepid	Unique	Matt Decker	Federation	FLEET ACTION: Target a ship within Range 1 of your ship (including your ship). Target ship gains +1 attack die this round and suffers 1 damage to its Hull.	-1	1	1	2	ACTION: Target a ship within Range 1 of your ship (including your ship). Target ship gains +1 attack die this round and suffers 1 damage to its Hull.	1	1	
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
