require "enumerator"
require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
5/27/2014 20:17:51		Jammed Communications	Independent	ACTION: All ships within Range 1-3 of your ship (including your own) cannot provide or benefit from any text abilities that affect other friendly ships this round.  Place an Auxiliary Power Token beside your ship.	Tech	5
5/27/2014 20:20:03	Unique	Gorn Pilot	Independent	ACTION: If you performed a straight Maneuver this round, you may disable this card to immediately perform an additional 1 [STRAIGHT] Maneuver.	Crew	3
5/27/2014 20:21:54		Impulse Overload	Independent	ACTION: Discard this card to target a ship at Range 1 of your ship and roll 3 attack dice.  If you roll at least 1 [HIT] or [CRIT] result, the target ship must discard 1 [TECH] Upgrade (of its choice).	Tech	2
5/27/2014 20:25:57	Unique	Faked Messages	Independent	During the planning phase, after every ship's maneuver has been chosen, you may discard this card to target 1 enemy ship that is not within Range 1-3 of your ship.  Force that ship to change its chosen maneuver to a 1 [STRAIGHT] Maneuver.	Talent	5
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
5/27/2014 20:15:17	Unique	Gorn Commander	4	Independent	When attacking, you may convert 1 blank result into 1 [HIT] result.	1	3
5/27/2014 20:16:18		Gorn	1	Independent		0	0
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
WEAPONSTEXT

convert_terms(upgrade)
convert_terms(captains_text)
convert_terms(weapons_text)

new_upgrades = File.open("new_upgrades.xml", "w")
new_captains = File.open("new_captains.xml", "w")

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
    # Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
    parts = l.split "\t"
    parts.shift
    unique = parts.shift == "Unique" ? "Y" : "N"
    title = parts.shift
    faction = parts.shift
    ability = parts.shift
    upType = parts.shift
    cost = parts.shift
    setId = set_id_from_faction(faction)
    externalId = make_external_id(setId, title)
    upgradeXml = <<-SHIPXML
    <Upgrade>
      <Title>#{title}</Title>
      <Ability>#{ability}</Ability>
      <Unique>#{unique}</Unique>
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
    # Timestamp		Weapon Name	Faction	Attack	Range	Ability	Cost
    parts = l.split "\t"
    parts.shift
    unique = parts.shift == "Unique" ? "Y" : "N"
    title = parts.shift
    faction = parts.shift
    attack = parts.shift
    range = parts.shift
    ability = parts.shift
    upType = "Weapon"
    cost = parts.shift
    setId = set_id_from_faction(faction)
    externalId = make_external_id(setId, title)
    upgradeXml = <<-SHIPXML
    <Upgrade>
      <Title>#{title}</Title>
      <Ability>#{ability}</Ability>
      <Unique>#{unique}</Unique>
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
  # Timestamp		Captain Name	Skill	Faction	Ability	Cost	Talents
  parts = l.split "\t"
  parts.shift
  unique = parts.shift == "Unique" ? "Y" : "N"
  title = parts.shift
  skill = parts.shift
  faction = parts.shift
  ability = parts.shift
  upType = "Captain"
  cost = parts.shift
  talent = parts.shift
  setId = set_id_from_faction(faction)
  externalId = make_external_id(setId, title)
  upgradeXml = <<-SHIPXML
  <Captain>
    <Title>#{title}</Title>
    <Ability>#{ability}</Ability>
    <Unique>#{unique}</Unique>
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
