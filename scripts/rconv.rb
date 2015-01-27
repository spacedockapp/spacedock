require "enumerator"
require "nokogiri"
require "pathname"
require "csv"

require_relative "common"

# Title	Type	Faction	Cost	Effect	Effect	Effect	Effect	Set
reference_text = <<-TOKENTEXT
1/20/2015 11:27:05	Officer Exchange Program	This card explains the rules for the Officer Exchange Program Resource and serves as a reference to remind players of its effect.  1) Prior to building your fleet, choose two different Factions.  2) You do not pay a faction penalty when assigning a Captain, Admiral or [CREW] Upgrade of either of the chosen factions to a ship in your fleet of the other chosen faction.  3) In addition, when assigning a Captain or Admiral card of one of the chose factions to a ship in your fleet of the other chose faction, the cost of that card is reduced by 1 SP (min 0).  NOT: This applies to all of your Captain and Admiral cards.	0
TOKENTEXT

convert_terms(reference_text)

reference_lines = CSV.parse(reference_text)

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

def make_reference_external_id(title)
  "#{sanitize_title(title)}_reference".downcase()
end

reference_lines.shift

reference_lines.each do |parts|
#  ,Title,Type,Faction,Cost,Effect,Effect,Effect,Effect,Set,errata
    parts.shift
    title = parts.shift
    type = parts.shift
    unless type == "Resource"
      faction = parts.shift
      parts.shift
      effects = []
      effects.push(parts.shift())
      effects.push(parts.shift())
      effects.push(parts.shift())
      effects.push(parts.shift())
      setId = parts.shift
      setId = parse_set(setId)
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
