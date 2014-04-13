require "enumerator"
require "nokogiri"
require "pathname"

require_relative "common"

script_path = Pathname.new(File.dirname(__FILE__))
root_path = script_path.parent()
src_path =  root_path.join("src")
xml_path = src_path.join("Data.xml").to_s
xml_text = File.read(xml_path)
doc = Nokogiri::XML(xml_text)

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
4/9/2014 13:11:21		Ablative Generator	Federation	ACTION: Place or remove the Ablative Generator Token beside your ship. This Upgrade may only be purchased for the U.S.S. Voyager.	Tech	10
4/9/2014 13:00:43	Unique	B'elanna Torres	Federation	Add 1 additional (weapon) icon and 1 additional (tech) icon to your ship's Upgrade Bar.	Crew	4
4/11/2014 6:13:27		Bio-Electric Interference	Species 8472	ACTION: Discard this card to target all other ships within range 1-3 of your ship. Target ships must discard all Tokens that are placed beside their ships except for Auxiliary Power Tokens. A ship that discards a (cloaked) Token may immediately raise its Shields. In addition your ship cannot be target locked this round. This Upgrade may only be purchased for a Species 8472 ship.	Tech	6
4/9/2014 13:14:33		Bio-Neural Circuitry	Federation	After your roll the dice for any reason, you may disable this Upgrade to re-roll the dice. You must re-roll all of the dice and keep the results of the second roll.	Tech	5
4/9/2014 12:34:17		Borg Ablative Hull Armor	Borg	When Defending, convert all of your opponents (crit) results info (hits) and place all the damage cards that your ship receives beneath this card. Once there are 4 damage cards beneath this card, discard this Upgrade and all damage cards beneath it. All excess damage affects the ship as normal.	Borg	10
4/9/2014 12:29:47		Borg Assimilation Tubules	Borg	ACTION: disable this card and discard 1 Drone Token to target a ship at Range 1-2 Steal 1 (Crew, Tech, or Weapon). Upgrade form the target ship, even if it exceeds your ship's restrictions. Place a Disabled Upgrade Token on the assimilated Upgrade. You cannot steal a Species 8472 Upgrade with this Action.	Borg	8
4/9/2014 12:26:18		Borg Tractor Beam	Borg	Action: Target a ship at Range 1. Place one white Borg Tractor Beam Token beside that ship and the corresponding green Borg Tractor Beam Token (the one that matches the white token's letter) beside your ship.	Borg	7
4/11/2014 6:09:52		Extraordinary Immune Response	Species 8472	When you defend, you may discard this card to roll 1 extra defense die for every damage card that is by your Ship Card. This Upgrade may only be purchased for a Species 8472 ship.	Tech	5
4/9/2014 12:40:37		Feedback Pulse	Borg	When defending, before any dice are rolled, you may discard this card to declare that half of the damage from this attack will be cancelled and the other half will be assigned to the attacker (round down); your receive no damage. the attacking ship connote receive critical damage from this effect. Place an Auxiliary Power Token decide your ship.	Tech	8
4/9/2014 12:59:41	Unique	Harry Kim	Federation	ACTION: Disable Harry to repair 1 Shield Token.	Crew	4
4/11/2014 5:57:53		Kazon Raiding Party	Kazon	When attacking, if you inflict at least 2 damage you may discard this card to reduce the damage to exactly 1 critical damage that ignores the opposing ship's Shields. Disable 1 (tech) Upgrade of your choice on the target ship and then steal that Upgrade, even if it exceeds your ship's requirements. This Upgrade may only be purchased for a Kazon ship.	Crew	5
4/11/2014 6:24:01		Masking Circuitry	Kazon	Instead of performing a normal Action, you may disable this card to perform the (cloak) Action. Place an Auxiliary Power Token beside your ship. While you have a (cloak) Token beside your ship, you may perform the (sensor echo) Action even if this card is disabled. This Upgrade cost +5 Squadron Points for any ship other than a Kazon ship.	Tech	3
4/11/2014 6:18:06		Quantum Singularity	Species 8472	ACTION: Discard this card to remove your ship from the play area and discard all Tokens that are beside your ship except for Auxiliary Power Tokens. During the End Phase, place your ship back in the play area. You cannot place your ship within Range 1-3 of any other ship. This Upgrade may only be purchased for a Species 8472 ship.	Tech	6
4/9/2014 13:16:14	Unique	Sacrifice	Federation	Before rolling the dice during an attack or defense, you may discard this Upgrade and disable your Captain in order to choose the results of two dice. These dice cannot be re-rolled for the remainder of this attack.	Talent	5
4/11/2014 5:48:48	Unique	Seska	Kazon	Actions: Target a ship at Range 2-3 Disable Seska and 1 (crew) Upgrade of your choice on the target ship. This ability can be used against a ship that is Cloaked.	Crew	4
4/9/2014 12:23:47	Unique	Seven of Nine	Borg	Action: Disable this card to add up to 2 Drone Tokens yo your Captain Card. You may not exceed your starting number of Drone Tokens.	Borg	4
4/9/2014 12:57:25	Unique	Seven of Nine	Federation	Action: Disable Seven of Nine to place 1 Adaptation Token on any (tech) Upgrade on an enemy ship within Range 1-2. You cannot use this Action against a Species 8472 (tech) Upgrade.	Crew	5
4/9/2014 12:22:27		Tactical Drone	Borg	"At the start of the game, place 4 Drone Tokens on the card.
When attacking, you may spend 1 Drone Token to close any number of your attack dice and re-roll them once."	Crew	3
4/9/2014 13:02:25	Unique	The Doctor	Federation	The Doctor counts as either a (crew) Upgrade or a (tech) Upgrade (your choice). ACTION: Remove all Disabled Upgrade tokens from your (crew) Upgrades.	Crew	3
4/11/2014 6:02:05	Unique	The Weak Will Perish	Species 8472	When attacking with your Primary Weapon, after rolling your attack dice, you may discard this card and disable your Captain Card to choose any number of your attack dice and re-roll them up to 2 times. This Upgrade cost +5 Squadron Points for any ship other than a Species 8472 ship.	Talent	5
4/11/2014 5:51:35	Unique	Tierna	Kazon	Action: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields. Discard Tierna and roll 2 attack dice. The target ship takes normal damage to its Hull for each (hit) or (crit) result. The target ship does not roll any defense dice against this attack.	Crew	3
4/9/2014 12:58:10	Unique	Tom Paris	Federation	When defending, your ship rolls 1 extra defense die.	Crew	4
4/9/2014 12:58:54	Unique	Tuvok	Federation	When firing a Secondary Weapon, you may disable Tuvok to toll 1 extra attack die.	Crew	5
UPGRADETEXT

convert_terms(upgrade)

new_upgrades = File.open("new_upgrades.xml", "w")
new_captains = File.open("new_captains.xml", "w")

upgradeLines = upgrade.split "\n"
FACTION_LOOKUP = {
  "Fed" => "Federation",
  "Kli" => "Klingon",
  "Rom" => "Romulan",
  "Dom" => "Dominion",
}

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

upgradeLines.each do |l|
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
    element_name = "Upgrade"
    setId = set_id_from_faction(faction)
    externalId = make_external_id(setId, title)
    upgradeXml = <<-SHIPXML
    <#{element_name}>
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
    </#{element_name}>
    SHIPXML
    if upType == "Captain"
      new_captains.puts upgradeXml
    else
      new_upgrades.puts upgradeXml
    end
end

