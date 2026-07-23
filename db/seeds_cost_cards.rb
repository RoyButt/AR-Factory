# Cost Cards seed (design embroidery cost) — idempotent.
puts "Seeding cost cards..."
CARD_SEED = [
  { code: "AR-MT",  fabric_rate: 300, fabric_mult: 3.5, cmt: 350, cut_work: 0,  hand_made: 0,  cm: 165, lass: 0,   files: [["Panel",46633,2,1,1.5],["Kali",0,1,1,1.5],["Bazoo",43306,1.5,1,1.5],["Tr",34419,3,1,1.5],["Back",0,1,1,1.5]] },
  { code: "AR-299", fabric_rate: 300, fabric_mult: 4.0, cmt: 300, cut_work: 0,  hand_made: 0,  cm: 153, lass: 30,  files: [["Panel",46633,2,1,1.5],["Kali",0,1,1,1.5],["Bazoo",43306,1.5,1,1.5],["Tr",34419,3,1,1.5],["Back",0,1,1,1.5]] },
  { code: "AR-282", fabric_rate: 310, fabric_mult: 3.5, cmt: 300, cut_work: 15, hand_made: 70, cm: 138, lass: 65,  files: [["Panel",149560,1,1,1.5],["Kali",91975,1,1,1.55],["Pati",156924,1,1,1.5],["Tr",0,4,1,1.5],["Back",0,1,1,1.5]] },
  { code: "AR-272", fabric_rate: 300, fabric_mult: 3.5, cmt: 300, cut_work: 15, hand_made: 70, cm: 146, lass: 0,   files: [["Panel",87446,2,1,1.5],["Kali",0,1,1,1.5],["Bazoo",58782,2,1,1.5],["Tr",17588,4,1,1.5],["Back",0,1,1,1.5]] },
  { code: "AR-255", fabric_rate: 300, fabric_mult: 3.5, cmt: 300, cut_work: 10, hand_made: 70, cm: 145, lass: 0,   files: [["Panel",42034,1,1,1.5],["Kali",64388,1,1,1.5],["Bazoo",47206,1.5,1,1.5],["Tr",22382,4,1,1.5],["Back",0,1,1,1.5]] },
  { code: "AR-253", fabric_rate: 300, fabric_mult: 3.5, cmt: 300, cut_work: 10, hand_made: 70, cm: 129, lass: 0,   files: [["Panel",67031,1,1,1.5],["Kali",84880,1,1,1.5],["Bazoo",45304,1.5,1,1.5],["Tr",22718,4,1,1.5],["Back",0,1,1,1.5]] },
  { code: "AR-251", fabric_rate: 300, fabric_mult: 3.5, cmt: 300, cut_work: 15, hand_made: 70, cm: 152, lass: 0,   files: [["Panel",96104,1,1,1.5],["Kali",44422,1,1,1.5],["Bazoo",51869,1.5,1,1.5],["Tr",26600,4,1,1.5],["Back",0,1,1,1.5]] },
  { code: "AR-247", fabric_rate: 300, fabric_mult: 3.5, cmt: 300, cut_work: 0,  hand_made: 50, cm: 134, lass: 0,   files: [["Panel",121803,1,1,1.5],["Kali",35577,1,1,1.5],["Bazoo",51362,1.5,1,1.5],["Tr",14780,4,1,1.5],["Back",0,1,1,1.5]] },
  { code: "AR-244", fabric_rate: 300, fabric_mult: 3.5, cmt: 300, cut_work: 8,  hand_made: 20, cm: 156, lass: 0,   files: [["Panel",80188,1,1,1.5],["Kali",57702,1,1,1.5],["Bazoo",87168,1.5,1,1.5],["Tr",18863,4,1,1.5],["Back",0,1,1,1.5]] },
  { code: "AR-238", fabric_rate: 300, fabric_mult: 3.5, cmt: 300, cut_work: 15, hand_made: 50, cm: 127, lass: 0,   files: [["Panel",62338,1,1,1.5],["Kali",49074,1,1,1.5],["Bazoo",56802,2,1,1.5],["Tr",28399,4,1,1.5]] },
  { code: "AR-233", fabric_rate: 300, fabric_mult: 3.5, cmt: 300, cut_work: 0,  hand_made: 40, cm: 146, lass: 0,   files: [["Panel",105560,1,1,1.5],["Back",40960,1,1,1.5],["Tr",17320,4,1,1.5],["Bazo Paties",188288,0.5,1,1.5]] },
  { code: "AR-232", fabric_rate: 300, fabric_mult: 3.5, cmt: 300, cut_work: 15, hand_made: 45, cm: 135, lass: 10,  files: [["Panel",60196,1,1,1.5],["Kali",65195,1,1,1.5],["Bazoo",68402,1.5,1,1.5],["Tr",17246,4,1,1.5]] },
  { code: "AR-223", fabric_rate: 300, fabric_mult: 3.5, cmt: 300, cut_work: 0,  hand_made: 40, cm: 134, lass: 10,  files: [["Panel",74479,1,1,1.5],["Kali",76628,1,1,1.5],["Bazoo",65718,1,1,1.5],["Tr",15068,4,1,1.5]] },
  { code: "AR-218", fabric_rate: 300, fabric_mult: 3.7, cmt: 300, cut_work: 20, hand_made: 0,  cm: 145, lass: 0,   files: [["Panel",114356,2,1,1.55],["Bazoo",39112,2,1,1.55],["Tr",14021,4,1,1.55],["Gala Jaal",24413,1,1,1.5]] },
  { code: "AR-213", fabric_rate: 300, fabric_mult: 3.5, cmt: 300, cut_work: 20, hand_made: 60, cm: 133, lass: 0,   files: [["Panel",83131,1,1,1.55],["Kali",91973,1,1,1.55],["Bazoo",63739,2,1,1.55],["Tr",18907,4,1,1.55]] },
  { code: "AR-211", fabric_rate: 300, fabric_mult: 4.0, cmt: 300, cut_work: 10, hand_made: 60, cm: 141, lass: 35,  files: [["Panel",65785,3,1,1.5],["Paties",138870,1,1,1.5],["Tr",0,4,1,1.5]] },
  { code: "AR-208", fabric_rate: 300, fabric_mult: 3.3, cmt: 350, cut_work: 26, hand_made: 70, cm: 121, lass: 125, files: [["Fornt",101286,2,1,1.5],["Front Tissue",188044,1,1,1.55],["Bazoo",44355,1,1,1.5],["Bazoo Tissue",165409,1,1,1.55],["Patties",0,4,1,1.5]] }
]
CARD_SEED.each do |c|
  card = CostCard.find_or_initialize_by(code: c[:code])
  card.assign_attributes(fabric_rate: c[:fabric_rate], fabric_multiplier: c[:fabric_mult],
    cmt: c[:cmt], cut_work: c[:cut_work], hand_made: c[:hand_made], cm: c[:cm], lass: c[:lass], card_date: Date.new(2026, 1, 6))
  card.save!
  card.emb_files.destroy_all
  c[:files].each_with_index do |(name, stitch, heads, reapts, rate), i|
    card.emb_files.create!(sr: i + 1, file_name: name, stitch: stitch, heads: heads, reapts: reapts, rate: rate)
  end
end
puts "  #{CostCard.count} cost cards, #{EmbFile.count} embroidery files."

# Example party-specific pricing on AR-299 (same design, different rate per party).
if (c299 = CostCard.find_by(code: "AR-299"))
  c299.party_prices.destroy_all
  c299.party_prices.create!(party_name: "Baby Jan",   pricing_mode: "markup_pct",    value: 10,   note: "Regular wholesale +10%")
  c299.party_prices.create!(party_name: "Al-Karam",   pricing_mode: "fixed",         value: 2500, note: "Contract fixed price")
  c299.party_prices.create!(party_name: "Local Shop", pricing_mode: "markup_amount", value: 150,  note: "Retail +150")
end
puts "  #{PartyPrice.count} party prices."

# Sample product images (solid PNG swatches) so cards show thumbnails out of the box.
require "stringio"; require "zlib"
solid_png = lambda do |w, h, r, g, b|
  raw = "".b; h.times { raw << 0; w.times { raw << r << g << b } }
  chunk = ->(t, d) { [d.bytesize].pack("N") + t + d + [Zlib.crc32(t + d)].pack("N") }
  png = "\x89PNG\r\n\x1a\n".b
  png << chunk.("IHDR", [w, h].pack("NN") + [8, 2, 0, 0, 0].pack("C5"))
  png << chunk.("IDAT", Zlib::Deflate.deflate(raw)) << chunk.("IEND", "")
  png
end
{ "AR-299" => [74, 163, 223], "AR-282" => [123, 79, 181], "AR-208" => [29, 138, 78] }.each do |code, (r, g, b)|
  card = CostCard.find_by(code: code) or next
  card.picture.purge if card.picture.attached?
  card.picture.attach(io: StringIO.new(solid_png.(260, 150, r, g, b)), filename: "#{code}.png", content_type: "image/png")
end
puts "  sample product images attached."
