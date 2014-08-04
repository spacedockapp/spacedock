require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
8/1/2014 21:20:22	Unique	Mutli-adaptive Shields	Federation	This upgrade only functions while you have Active Shields. Each time you defend, roll +1 defense die. When defending, you roll your full defense dice in spite of the presence of an enemy ship's [SCAN] token. In addition, you roll your full defense against any Minefield Tokens. This Upgrade may only be purchased for a Federation ship.	Tech	5																			
8/1/2014 21:22:05	Unique	Reinforced Structural Integrity	Federation	Each time your ship takes damage, place 1 of the damage cards that your ship receives beneath this card. All excess damage affects the ship as normal. You cannot place critical damage cards beneath this card. Once there are 3 damage cards beneath this card, discard this Upgrade and all cards beneath it. This Upgrade costs +5 SP for any ship other than the U.S.S. Raven.	Tech	5																			
8/1/2014 21:22:55		Research Mission	Independent	During the Roll Defense Dice step of the Combat Phase, you may disable this card to roll +1 defense die.	Talent	2																			
8/1/2014 21:24:20	Unique	Erin Hansen	Independent	During the Planning Phase, after all ships have chosen their Maneuvers, you may discard this card to target one enemy ship at Range 1-3 and look at that ship's chosen Maneuver. You may then change your Maneuver. The target ship cannot change its Maneuver after you look at it.	Crew	3																			
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
8/1/2014 21:17:29	Unique	Magnus Hansen	3	Independent	During the Modify Defense Dice step of the combat phase, you may spend 1 [SCAN] token to add 1 additional [EVADE] result to your defense roll. You do not pay a faction penalty when assigning Magnus to a Federation ship.	1	2																		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
ADMIRALSTEXT

convert_terms(upgrade)
convert_terms(captains_text)
convert_terms(weapons_text)

new_upgrades = File.open("new_upgrades.xml", "w")
new_captains = File.open("new_captains.xml", "w")
new_admirals = File.open("new_admirals.xml", "w")

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
  # Timestamp		Captain Name	Skill	Faction	Ability	Talents	Cost
  parts = l.split "\t"
  parts.shift
  unique = parts.shift == "Unique" ? "Y" : "N"
  title = parts.shift
  skill = parts.shift
  faction = parts.shift
  ability = parts.shift
  upType = "Captain"
  talent = parts.shift
  cost = parts.shift
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

admirals_lines = admirals_text.split "\n"
admirals_lines.each do |l|
  l = convert_line(l)
  # Timestamp		Admiral Name	Faction	Fleet Action	Skill Modifier	Talents	Cost	Captain-side Cost	Captain-side Action	Captain-side Talents	Captain-side Skill
  parts = l.split "\t"
  parts.shift
  unique = parts.shift == "Unique" ? "Y" : "N"
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
  setId = set_id_from_faction(faction)
  externalId = make_external_id(setId, title)
  upgradeXml = <<-SHIPXML
  <Admiral>
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
    <AdmiralAbility>#{admiralAbility}</AdmiralAbility>
    <AdmiralCost>#{admiralCost}</AdmiralCost>
    <AdmiralTalent>#{admiralTalent}</AdmiralTalent>
    <SkillModifier>#{skillModifier}</SkillModifier>
  </Admiral>
  SHIPXML
  new_admirals.puts upgradeXml
end
