# Master Data seed — idempotent. Run via: bin/rails runner 'load Rails.root.join("db/seeds_master.rb").to_s'
puts "Seeding settings (formula constants)..."
SETTINGS = [
  ["emb_factor",            "EMB factor (× heads × repeats)",      0.337, "Embroidery"],
  ["backup_divisor",        "Backup divisor (components ÷ this)",  39,    "Embroidery"],
  ["rounding_step",         "Rounding step (CEILING to)",          0.5,   "Embroidery"],
  ["stitch_divisor",        "Stitch divisor (embroidery file)",    1000,  "Embroidery"],
  ["fabric_multiplier",     "Fabric: gaz per suit (× rate)",       4,     "Costing"],
  ["emb_addon",             "EMB cost add-on (+)",                 25,    "Costing"],
  ["final_addon",           "Final rate add-on (+)",               100,   "Costing"],
  ["gaz_per_suit_consumed", "Gaz consumed per suit",               3.4,   "Fabric"],
  ["gaz_per_suit_issued",   "Gaz issued per suit",                 3.5,   "Fabric"],
  ["reorder_cover_days",    "Reorder cover (days)",                20,    "Inventory"],
  ["reorder_buffer_factor", "Reorder buffer (× avg ÷ 2)",          0.5,   "Inventory"]
]
SETTINGS.each do |key, label, value, grouping|
  s = Setting.find_or_initialize_by(key: key)
  s.update!(label: label, grouping: grouping, value: (s.persisted? ? s.value : value))
end

puts "Seeding fabric types..."
[["B-Cotton", 2026, 286.22], ["M-Cotton", 2025, 320.45], ["Khadi", 2025, 194.50]].each do |name, year, rate|
  ft = FabricType.find_or_initialize_by(name: name, year: year)
  ft.update!(rate: (ft.persisted? ? ft.rate : rate))
end

puts "Seeding workers..."
%w[Bilal Aqsa Yaseen Kashif Zulifqar Dildar Maqsood Akbar Afzal Hassan Javaid Aziz Zahid Raiz Naeem Majid Nadir].each do |name|
  w = Worker.find_or_initialize_by(name: name)
  w.update!(piece_rate: (w.persisted? ? w.piece_rate : 120), active: true)
end

puts "Seeding designs + variants..."
DESIGN_SEED = [
  { code: "AR-105B", variants: [{ size: "24", repeats: 4.0, tr: 56, back: 25, bazoo: 0, kali: 0, falas: 0 }] },
  { code: "AR-66",   variants: [{ size: "24", repeats: 3.5, tr: 56, back: 25, bazoo: 7, kali: 0, falas: 0 }] },
  { code: "AR-70",   variants: [{ size: "24", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 0 }] },
  { code: "AR-35",   variants: [{ size: "24", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 1.5 }, { size: "28", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 1.5 }, { size: "32", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 1.5 }] },
  { code: "AR-35-L", variants: [{ size: "28", repeats: 7.5, tr: 8.5, back: 25, bazoo: 0, kali: 0, falas: 1.5 }] },
  { code: "AR-06",   variants: [{ size: "24", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 1.5 }, { size: "28", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 1.5 }] },
  { code: "AR-06-L", variants: [{ size: "24", repeats: 7.5, tr: 8.5, back: 25, bazoo: 0, kali: 0, falas: 1.5 }] },
  { code: "AR-127",  variants: [{ size: "24", repeats: 9.5, tr: 0, back: 3.5, bazoo: 0, kali: 0, falas: 0 }] },
  { code: "AR-178",  variants: [{ size: "28", repeats: 8.0, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 4.5 }, { size: "24", repeats: 8.0, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 4.5 }] },
  { code: "AR-175",  variants: [{ size: "28", repeats: 8.0, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 1.5 }] },
  { code: "AR-152",  variants: [{ size: "28", repeats: 7.0, tr: 0, back: 25, bazoo: 7.5, kali: 0, falas: 6 }] },
  { code: "AR-183-P", variants: [{ size: "", repeats: 0, tr: 60, back: 86, bazoo: 0, kali: 0, falas: 0 }] },
  { code: "AR-192-P", variants: [{ size: "", repeats: 0, tr: 60, back: 115, bazoo: 0, kali: 0, falas: 0 }] },
  { code: "AR-185-P", variants: [{ size: "", repeats: 0, tr: 60, back: 86, bazoo: 0, kali: 0, falas: 0 }] },
  { code: "AR-193-P", variants: [{ size: "", repeats: 0, tr: 80, back: 52, bazoo: 20, kali: 0, falas: 0 }] },
  { code: "AR-187",  variants: [{ size: "28", repeats: 9.0, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 6 }] },
  { code: "AR-189",  variants: [{ size: "28", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 1.5 }] },
  { code: "AR-205",  variants: [{ size: "28", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 6 }] },
  { code: "AR-206",  variants: [{ size: "28", repeats: 8.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 6 }, { size: "24", repeats: 8.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 6 }, { size: "32", repeats: 8.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 6 }] },
  { code: "AR-208",  variants: [{ size: "28", repeats: 3.0, tr: 54, back: 25, bazoo: 0, kali: 0, falas: 4 }] },
  { code: "AR-209",  variants: [{ size: "28", repeats: 5.0, tr: 36, back: 25, bazoo: 0, kali: 0, falas: 4 }] },
  { code: "AR-210",  variants: [{ size: "28", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 4 }] },
  { code: "AR-211",  variants: [{ size: "28", repeats: 3.0, tr: 54, back: 33, bazoo: 16, kali: 0, falas: 0 }] },
  { code: "AR-212",  variants: [{ size: "28", repeats: 6.5, tr: 0, back: 40, bazoo: 0, kali: 21, falas: 0 }, { size: "32", repeats: 6.5, tr: 0, back: 40, bazoo: 0, kali: 21, falas: 0 }] },
  { code: "AR-213",  variants: [{ size: "28", repeats: 8.0, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 1.5 }] },
  { code: "AR-214",  variants: [{ size: "28", repeats: 7.5, tr: 0, back: 25, bazoo: 6, kali: 0, falas: 1.5 }] },
  { code: "AR-215",  variants: [{ size: "28", repeats: 7.5, tr: 0, back: 25, bazoo: 6, kali: 3.5, falas: 1.5 }] },
  { code: "AR-220",  variants: [{ size: "24", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 1.5 }, { size: "28", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 1.5 }] },
  { code: "AR-777",  variants: [{ size: "24", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 6 }, { size: "28", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 6 }, { size: "32", repeats: 7.5, tr: 0, back: 25, bazoo: 0, kali: 0, falas: 6 }] }
]
DESIGN_SEED.each do |d|
  design = Design.find_or_create_by!(code: d[:code]) do |x|
    x.category = d[:code].end_with?("-P") ? "Printed" : "Embroidered"
  end
  d[:variants].each do |v|
    dv = design.design_variants.find_or_initialize_by(size: v[:size])
    dv.update!(repeats_per_color: v[:repeats], trousers: v[:tr], back: v[:back],
               bazoo: v[:bazoo], kali: v[:kali], falas: v[:falas])
  end
end

puts "Master data: #{Design.count} designs, #{DesignVariant.count} variants, #{FabricType.count} fabrics, #{Worker.count} workers, #{Setting.count} settings."
