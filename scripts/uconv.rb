require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
2/18/2015 17:22:06	71794 - I.R.W. Haakona	Non-unique	Romulan Helmsman	Romulan	During the Activation Phase, if you reveal a Red Maneuver, you may disable this card to treat that maneuver as if it were a White Maneuver.  No ship may be equipped with more than one Romulan Helmsman.	Crew	2	Yes
2/18/2015 17:26:39	71794 - I.R.W. Haakona	Non-unique	Romulan Security Officer	Romulan	For each Romulan Security Officer equipped to your ship (including this one), your Captain's Skill is +1 (max +3).  When defending, you may disable this card to re-roll one of your blank results.	Crew	2	
2/18/2015 17:31:52	71794 - I.R.W. Haakona	Unique	Make Them See Us!	Romulan	While cloaked, during the Activation Phase, before revealing your dial you may discard this card to target a ship that you already have Target Locked.  Remove your target lock from that ship.  If you do t his and your ship's base or maneuver template overlaps the target ship's base during the Execute Maneuver step, inflict an amount of damage equal to the current speed on your maneuver dial to both ships (max 4).  The ship whose Captain has the higher Skill Number rolls a number of defense dice against this damage equal to the difference in your Skill Numbers.  This  Upgrade may only be purchased for a Romulan Captain on a Romulan ship.	Talent	5	Yes
2/18/2015 17:35:01	71794 - I.R.W. Haakona	Non-unique	Romulan Sub Lieutenant	Romulan	ACTION: Discard t his card to target a ship at Range 1-2.  If the target ship has a Hull value of 6 or greater, that ship must disable 2 of its Active Shields, if possible.  Otherwise, that ship must disable 1 of its Active Shields, if possible.  This Upgrade may only be purchased for a Romulan ship.	Crew	4	Yes
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
2/18/2015 17:20:41	71794 - I.R.W. Haakona	Unique	Taris	5	Romulan	When attacking with your Primary Weapon, during the Declare Target step, you may discard one of your [CREW] Upgrades to target a ship that is not in your forward firing arc.	1	4		
2/18/2015 17:21:01	71794 - I.R.W. Haakona	Non-unique	Romulan	1	Romulan		0	0		
2/18/2015 17:35:53	71794 - I.R.W. Haakona	Unique	Centurion	2	Romulan	When attacking, you may re-roll one of your [BATTLE STATIONS] results.	0	1		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
2/18/2015 17:23:40	71795 - Tholia One	Non-unique	Tricobalt Warhead	Independent	6	3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  This Upgrade costs +5 SP for any non-Tholian ship.	4	Yes
2/18/2015 17:25:00	71794 - I.R.W. Haakona	Non-unique	Disruptor Pulse	Romulan	3	1-2	ATTACK: Disable this card to perform this attack.  During the Declare Target step, target every enemy ship that is in your forward firing arc and within range and perform a separate attack against each of the target ships with this attack.  This Upgrade costs +5 SP for any non-Romulan ship.	5	Yes
2/18/2015 17:37:24	71794 - I.R.W. Haakona	Non-unique	Disruptor Beams	Romulan	5	1-3	ATTACK: Disable this card to perform this attack.  For every damage the defending ship suffers from this attack, roll 1 attack die.  If you roll at least one [HIT] or [CRIT] result, add +1 damage.	5	
2/18/2015 17:38:35	71794 - I.R.W. Haakona	Non-unique	Plasma Torpedoes	Romulan	5	1-2	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  You may re-roll all of your blank results one time.  You may fire this weapon from your forward or rear firing arcs.	5	
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
2/18/2015 17:29:00	71794 - I.R.W. Haakona	Unique	Mendak	Romulan	FLEET ACTION: Target a friendly ship at Range 1-2 (including your own) that has no [BATTLE STATIONS] Token(s) beside it and place a [BATTLE STATIONS] Token beside that ship.  The target ship cannot perform a [BATTLE STATIONS] Action this round.  This card may only be purchased for a Romulan ship.	2	1	4	6	ACTION: Target a friendly ship at Range 1-2 (including your own) that has no [BATTLE STATIONS] Token(s) beside it and place a [BATTLE STATIONS] Token beside that ship.  The target ship cannot perform a [BATTLE STATIONS] Action this round.  This card may only be purchased for a Romulan ship.	1	4	Yes
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
