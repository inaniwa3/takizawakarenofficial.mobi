#!/usr/bin/env ruby

require "json"

def y2s(n)
  n.to_s.tr("0123456789", "〇一二三四五六七八九")
end

def md2s(n)
  s = ""
  if n >= 20
    s += (n / 10).to_s.tr("23", "二三") + "十"
  elsif n >= 10
    s += "十"
  end
  if n % 10 > 0
    s += (n % 10).to_s.tr("123456789", "一二三四五六七八九")
  end
  s
end

j = JSON.load(File.read("./instagram-scraper/takizawakarenofficial/takizawakarenofficial.json"))

y = 0
m = 0
r = ""
rs = {}
j["GraphImages"].reverse.each do |h|
  t = Time.at(h["taken_at_timestamp"])
  if t.year != y
    rs[y] = r.chop unless r == ""
    r = "= #{y2s(t.year)}年\n\n"
    y = t.year
  end
  if t.month != m
    r << "== #{md2s(t.month)}月\n\n"
    m = t.month
  end
  r << "=== #{md2s(t.month)}月#{md2s(t.day)}日\n\n"

  s = ""
  # eliminate emoji sequence
  h["edge_media_to_caption"]["edges"].first["node"]["text"].each_grapheme_cluster do |c|
    s << c.chars.first
  end
  # \n -> \n\n
  # \n\n -> \n//blankline\n
  # \n\n\n -> \n//blankline\n//blankline\n
  # ...
  s.gsub!(/(?<!\n)\n(?!\n)/, "hogefugapiyo")
  s.gsub!(/(?<!\n)\n(\n+)/) { "\n" + $1.gsub(/\n/, "//blankline\n") }
  s.gsub!(/hogefugapiyo/, "\n\n")
  r << s + "\n\n"
end
rs[y] = r.chop

c = <<EOS
PREDEF:

CHAPS:
#{rs.keys.map{|k| "  - #{k}.re"}.join("\n")}

APPENDIX:

POSTDEF:

EOS
File.write("./review/catalog.yml", c)

rs.each do |k, v|
  File.write("./review/#{k}.re", v)
end
