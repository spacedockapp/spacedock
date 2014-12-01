require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
11/30/2014 17:46:29	71535 - Regent's Flagship	Unique	Intendant's Orders	Mirror Universe	During the Planning Phase, you may disable this card to remove up to 2 Disabled Upgrade Tokens from your [CREW] Upgrades.	Talent	2	
11/30/2014 17:47:34	71535 - Regent's Flagship	Unique	Make It So!	Mirror Universe	During the Activation Phase, after you move, you may discard this card and disable one of your [CREW] Upgrades to perform one additional Action this round as a free Action.	Talent	3	
11/30/2014 17:48:47	71535 - Regent's Flagship	Unique	I Will Deal With Them Myself	Mirror Universe	During the Roll Attack Dice step, you may discard this card to disable up to 2 of your [CREW] Upgrades.  If you do so, roll 1 additional attack die for that attack for each Upgrade you disabled with this card.	Talent	5	
11/30/2014 17:50:55	71535 - Regent's Flagship	Mirror Universe Unique	Elim Garak	Mirror Universe	While Elim Garak is assigned to a Mirror Universe ship, add 2 to that ship's Captain's Skill Number.  During the Roll Attack Dice step, you may disable your Captain Card to gain +1 additional die for that attack.	Crew	3	
11/30/2014 17:51:38	71535 - Regent's Flagship	Mirror Universe Unique	Brunt	Mirror Universe	At the start of the End Phase, you may discard this card to target an enemy ship at Range 1-3.  Place an Auxiliary Power Token beside the target ship.	Crew	1	
11/30/2014 17:56:05	71535 - Regent's Flagship	Mirror Universe Unique	Bareil Antos	Mirror Universe	ACTION: Disable this card to target a ship at Range 1-3.  Choose a [TECH] Upgrade and roll 1 attack die.  On a [HIT] or a [CRIT] result either discard that [TECH] Upgrade or steal it.  Your ship must have at least 1 [TECH] Upgrade slot in order to steal it.  If the stolen Upgrade exceeds your ship's restrictions, you must discard 1 of your [TECH] Upgrades to open a slot for it.	Crew	2	
11/30/2014 17:57:00	71535 - Regent's Flagship	Mirror Universe Unique	Odo	Mirror Universe	ACTION: Select one of your disabled [CREW] Upgrades and perform that Upgrade's Action as a free Action.  Then discard that [CREW] Upgrade.	Crew	3	
11/30/2014 17:58:24	71535 - Regent's Flagship	Non-unique	Cloaking Device	Mirror Universe	Instead of performing a normal Action, you may disable this card to perform the [CLOAK] Action.  While you have a [CLOAK] Token beside your ship, you may perform the [SENSOR ECHO] Action even if this card is disabled.  This Upgrade costs +5 Squadron Points for any ship other than the Regent's Flagship.	Tech	4	Yes
11/30/2014 17:59:17	71535 - Regent's Flagship	Non-unique	Tractor Beam	Mirror Universe	ACTION: Target a ship at Range 1 and roll 2 attack dice.  For every [HIT] or [CRIT] result, place 1 Auxiliary Power Token beside the target ship.	Tech	3	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
11/30/2014 17:44:33	71535 - Regent's Flagship	Mirror Universe Unique	Kira Nerys	4	Mirror Universe	When a [CREW] Upgrade on an enemy ship within Range 1-2 of your ship performs an Action that would affect your ship, you may disable this card to prevent that Action from taking effect.  If you do this, the enemy ship cannot take another Action that round.  If the enemy [CREW] Upgrade was disabled to perform the Action, it remains disabled.  If the enemy [CREW] Upgrade was discarded to perform the Action, disable it instead.	1	2		
11/30/2014 17:44:55	71535 - Regent's Flagship	Non-unique	Mirror Universe	1	Mirror Universe		0	0		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
11/30/2014 18:01:19	71535 - Regent's Flagship	Non-unique	Photon Torpedoes	Mirror Universe	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  If fired from a Negh'Var class ship, gain +1 attack die.  You may fire this weapon from your forward or rear firing arcs.	5	
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
11/30/2014 17:40:43	71535 - Regent's Flagship	Mirror Universe Unique	Worf	Mirror Universe	FLEET ACTION: Target a friendly ship at Range 1-2 with a Hull Value of 3 or less.  The target ship immediately makes one free attack with its Primary Weapon against an enemy ship in its forward firing arc.  Place an Auxiliarly Power Token beside the target ship.	0	1	2	3	ACTION: Target a friendly ship at Range 1-2 with a Hull Value of 3 or less.  The target ship immediately makes one free attack with its Primary Weapon against an enemy ship in its forward firing arc.  Place an Auxiliarly Power Token beside the target ship.	1	2	
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
