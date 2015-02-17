require "enumerator"
require "nokogiri"
require "pathname"
require "csv"

require_relative "common"

# Title	Type	Faction	Cost	Effect	Effect	Effect	Effect	Set
reference_text = <<-TOKENTEXT
2/16/2015 16:51:08	71997r - Peak Performance	Master Strategist Tokens (MST)	Resource	This card explains the rules for the Master Strategist Tokens Resource and serves as a reference to remind players of its effect.  At the start of the game, place the 6 MSTs beside your ship cards.  During the Activation Phase, instead of performing a  normal Action, any of the ships in your fleet may perform the following Action:  ACTION: Place 1 MST beside your ship.  While a Master Strategist Token is beside your ship:  1) Treat it as if it were an [EVASIVE MANEUVERS], a [SCAN], a [BATTLE STATIONS] or a [TARGET LOCK] Token.  You may use this Token as you would any of these Tokens (see pg. 10 of the Rules of Play).  Remove it from the game if it is spent.  2) During the End Phase, place any unused MSTs back beside your ship cards to use again on a later round.  3) When using an MST as a [TARGET LOCK] Token, you may only spend it to re-roll your attack dice (see pg. 14).  This does not count as having acquired a target lock with regards to Secondary Weapons (see pg. 20).  4) Only one Upgrade Card on each ship can trigger its ability from this Token during the same round (see pg. 22).  5) On a round a ship uses this Action, that ship may still use an [EVASIVE MANEUVERS], [SCAN], [BATTLE STATIONS] or [TARGET LOCK] Action as a free Action, if possible.	10
TOKENTEXT

convert_terms(reference_text)

reference_lines = parse_data(reference_text)

new_reference = File.open("new_reference.xml", "w")

reference_item_lines = reference_text.split "\n"

def no_quotes(a)
  a.gsub("\"", "")
end

def parse_set(setId)
  unless setId
    return ""
  end
  setId = no_quotes(setId)
  if setId =~ /\#(\d+).*/
    return $1
  end
  return setId.gsub(" ", "").gsub("\"", "")
end

#def parse_set(setId)
#  setId = no_quotes(setId)
#  if setId =~ /\#(\d+).*/
#    return $1
#  end
#  return setId.gsub(" ", "").gsub("\"", "")
#end


def make_reference_external_id(title)
  "#{sanitize_title(title)}_reference".downcase()
end

#reference_lines.shift

reference_lines.each do |parts|
#  ,Title,Type,Faction,Cost,Effect,Effect,Effect,Effect,Set,errata
    parts.shift
    setId = set_id_from_expansion(parts.shift)
    title = parts.shift
    type = parts.shift
    if type == "Resource"
      ability = parts.shift
      cost = parts.shift
      externalId = make_external_id(setId, title)
      upgradeXml = <<-SHIPXML
      <Resource>
        <Title>#{title}</Title>
        <Type>#{type}</Type>
        <Ability>#{ability}</Ability>
        <Cost>#{cost}</Cost>
        <Id>#{externalId}</Id>
        <Set>#{setId}</Set>
      </Resource>
      SHIPXML
      new_reference.puts upgradeXml
    else
      faction = parts.shift
      parts.shift
      effects = []
      effects.push(parts.shift())
      effects.push(parts.shift())
      effects.push(parts.shift())
      effects.push(parts.shift())
      externalId = make_reference_external_id(title)
      upgradeXml = <<-SHIPXML
      <Reference>
        <Title>#{title}</Title>
        <Ability>#{effects.join("\n").chomp}</Ability>
        <Type>#{type}</Type>
        <Id>#{externalId}</Id>
      </Reference>
      SHIPXML
      new_reference.puts upgradeXml
    end
end
