require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
11/9/2017 13:55:27	72945 - Romulan Faction Pack	Non-unique	Tal Shiar Sub-Commander	Romulan	WHEN ATTACKING: If this ship has an [EVADE] Token beside it:  This ship may convert 1 of the defending ship's [EVADE] into a [BLANK].	Crew	2			
11/9/2017 13:57:03	72946 - Dominion Faction Pack	Unique	All Power to Weapons	Dominion	COMBAT PHASE: Place 3 [TIME] Tokens on this card and disable this ship's Shields.  Continuous Effect: This ship's Shields remain disabled.  This ship can only perform Green Maneuvers.  This ship rolls +3 attack dice.	Talent	5			Dominion Captain, 5+ Hull
11/10/2017 12:43:24	72946 - Dominion Faction Pack	Unique	Talak'Talan	Dominion	ACTION: Discard this card and target all friendly ships.  Place a [BATTLE STATIONS] Token beside this ship and all target ships.	Crew	2		1-2	
11/16/2017 16:55:26	72946 - Dominion Faction Pack	Unique	Lamat'Ukan	Dominion	WHEN ATTACKING: If this ship spent its [TARGET LOCK] Token to re-roll its attack dice:  This ship may convert1 [BLANK] into 1 [HIT].	Crew	2			
11/17/2017 21:13:51	72945 - Romulan Faction Pack	Non-unique	Romulan Medical Team	Romulan	ACTION: Discard this card and target a friendly ship.  Remove 1 [DISABLED] Token from all [CREW] Upgrades equipped to target ship.	Crew	3		1-2	
11/21/2017 14:45:40	72945 - Romulan Faction Pack	Non-unique	Strike From the Shadows	Romulan	WHEN ATTACKING: If this ship is Cloaked, discard this card.  Flip this ship's [CLOAK] Token to its green side.	Talent	3			
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
11/9/2017 13:52:19	72945 - Romulan Faction Pack	Unique	Alidar Jarok	6	Romulan	ACTIVATION PHASE: After an opposing ship moves but before its Perform Action Step, target that ship and place 2 [TIME] Tokens on this card.  Choose an Action on the target ship's Action Bar other than [REGENERATE].  The target ship must perform the chosen Action during its Perform Action Step.	1	5		1-2	
11/10/2017 12:42:11	72946 - Dominion Faction Pack	Unique	Deyos	6	Dominion	ACTION: Target a friendly ship.  Equip a [CREW] Upgrade that was discarded from the target ship to the target ship.  The target ship cannot attack this game round.	0	4		1-2	
11/13/2017 15:32:11	72945 - Romulan Faction Pack	Unique	Tomalak	8	Romulan	Add 1 [TECH] to this ship's Upgrade Bar.  WHEN ATTACKING:  This ship may re-roll 1 attack die for each [TECH] Upgrade equipped to it.	1	5	Yes		
11/15/2017 15:00:31	72946 - Dominion Faction Pack	Unique	Kilana	4	Dominion	WHEN A [TECH] UPGRADE EQUIPPED TO THIS SHIP WOULD BE DISABLED:  You may place 2 [TIME] Tokens on it instead.	1	2			
11/20/2017 14:42:18	72944 - Federation vs. Klingons Starter Set	Unique	Jean-Luc Picard	8	Federation	ACTION: Place 2 [TIME] Tokens on this card and target all friendly ships.  Place a [BATTLE STATIONS] Token beside this ship and all target ships.	2	6		1-2	
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
11/11/2017 12:23:06	72944 - Federation vs. Klingons Starter Set	Unique	Torpedo Fusillade	Klingon	*	2-3	The cost of this [WEAPON] is equal to this ship's Primary Weapon Value.  The Attack Value of this [WEAPON] is equal to this ship's Primary Weapon Value.  ATTACK: Remove this card from the game and target all opposing ships.	1	Yes		Forward
11/14/2017 14:32:52	72946 - Dominion Faction Pack	Unique	Disruptor Cannon	Dominion	6	1-2	ATTACK: Spend this ship's [TARGET LOCK] Token, discard this card, and target an opposing ship.  Perform this attack twice against the target ship.	3		Jem'Hadar Battleship	Secondary
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
    range = parts.shift
    if !range.nil?
	ability = "#{ability} [RANGE #{range}]"
    end
    restrictions = parts.shift
    unique = uniqueText == "Unique" ? "Y" : "N"
    if uniqueText == "One Per Ship"
	special = "#{special}NoMoreThanOnePerShip"
    end
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
      <Special>#{special}</Special>#{restrictions}
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
    restrictions = parts.shift
    unique = uniqueText == "Unique" ? "Y" : "N"
    if uniqueText == "One Per Ship"
	special = "#{special}NoMoreThanOnePerShip"
    end
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
      <Special>#{special}</Special>#{restrictions}
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
