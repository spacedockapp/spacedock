require "set"
require "csv"

def convert_terms(upgrade)
  upgrade.gsub! /\[Regenerate\]/i, "[REGENERATE]"
  upgrade.gsub! /\[evade\]/i, "[EVADE]"
  upgrade.gsub! /\[cloak\]/i, "[CLOAK]"
  upgrade.gsub! /\[forward\]/i, "[STRAIGHT]"
  upgrade.gsub! /\[left straight\]/i, "[LEFT SPIN]"
  upgrade.gsub! /\[right straight\]/i, "[RIGHT SPIN]"
  upgrade.gsub! /\[1 straight\]/i, "[1 STRAIGHT]"
  upgrade.gsub! /\[Sensor Echo\]/i, "[SENSOR ECHO]"
  upgrade.gsub! /\[scan\]/i, "[SCAN]"
  upgrade.gsub! /\[tech\]/i, "[TECH]"
  upgrade.gsub! /\[critical\]/i, "[CRITICAL]"
  upgrade.gsub! /\[Hit\]/i, "[HIT]"
  upgrade.gsub! /\[crew\]/i, "[CREW]"
  upgrade.gsub! /\[Battle *Stations*\]/i, "[BATTLESTATIONS]"
  upgrade.gsub! /\(Battle *Stations*\)/i, "[BATTLESTATIONS]"
  upgrade.gsub! /\(Target Lock\)/i, "[TARGET LOCK]"
  upgrade.gsub! /\(Critical Hit\)/i, "[CRITICAL]"
  upgrade.gsub! /\(talent\)/i, "[TALENT]"
  upgrade.gsub! /\(tech\)/i, "[TECH]"
  upgrade.gsub! /\(weapon\)/i, "[WEAPON]"
  upgrade.gsub! /\(scan\)/i, "[SCAN]"
  upgrade.gsub! /\(cloaked\)/i, "[CLOAK]"
  upgrade.gsub! /\(cloak\)/i, "[CLOAK]"
  upgrade.gsub! /\(crit\)/i, "[CRITICAL]"
  upgrade.gsub! /\(hit\)/i, "[HIT]"
  upgrade.gsub! /\(hits\)/i, "[HIT]"
  upgrade.gsub! /\(crew\)/i, "[CREW]"
  upgrade.gsub! /\(sensor echo\)/i, "[SENSOR ECHO]"
  upgrade.gsub! /[\[(]straight[)\]]/i, "[STRAIGHT]"
  upgrade
end

def no_quotes(a)
    a.gsub("\"", "")
end

def convert_line(a)
  if a != nil
    a.gsub!(/\n+/, " ")
    a.gsub!(/ +/, " ")
    a = no_quotes(a)
  end
  a
end

def sanitize_title(title)
  title.gsub(/\W+/, "_")
end

$external_ids = Set.new()

def make_external_id(setId, title)
  sanitized_title = sanitize_title(title)
  external_id = "#{sanitize_title(title)}_#{setId}".downcase()
  if $external_ids.member?(external_id)
    letters = 'b'..'z'
    letters.each do |letter|
      external_id = "#{sanitize_title(title)}_#{letter}_#{setId}".downcase()
      unless $external_ids.member?(external_id)
        break
      end
    end
  end
  $external_ids.add(external_id)
  external_id
end

def set_id_from_expansion(expansion)
  parts = expansion.split (/\s+-\s+/)
  parts[0]
end

def parse_data(data)
  rows = []
  csv = CSV.new(data, {:col_sep => "\t"})
  csv.each do |row|
    rows.push(row)
  end
  rows
end