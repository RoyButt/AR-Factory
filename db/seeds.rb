# Seeds for AR-Unit Factory Management System.
# Run with:  bin/rails db:seed   (idempotent — safe to re-run)

puts "Seeding users..."

ALL = User::SECTIONS.keys                       # every sidebar section
OPS = %w[dashboard records inventory production payroll] # restricted set for Operator

users = [
  { name: "Super Admin",  email: "superadmin@arunit.com", password: "super123",
    role: "superadmin", view_only: false, allowed_sections: ALL },

  { name: "Administrator", email: "admin@arunit.com", password: "admin123",
    role: "admin", view_only: false, allowed_sections: ALL },

  # Third person — view-only Operator with a restricted set of sidebar sections.
  { name: "Imran Operator", email: "operator@arunit.com", password: "operator123",
    role: "operator", view_only: true, allowed_sections: OPS }
]

users.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])
  user.assign_attributes(
    name: attrs[:name],
    password: attrs[:password],
    password_confirmation: attrs[:password],
    role: attrs[:role],
    view_only: attrs[:view_only],
    allowed_sections: attrs[:allowed_sections]
  )
  user.save!
  puts "  ✓ #{user.email.ljust(26)} role=#{user.role.ljust(10)} view_only=#{user.view_only} sections=#{user.sections.size}"
end

# Remove old demo accounts from earlier seeding, if present.
User.where(email: %w[costing@arunit.com store@arunit.com accounts@arunit.com]).destroy_all

puts "Done. #{User.count} users in database."

# --- Production lots (Laat progress pipeline) ---
puts "Seeding production lots..."
LotAttachment.destroy_all
ProductionLot.delete_all
require "date"
d = ->(s) { Date.parse(s) }

lots = [
  # Fully completed, no issues.
  { emb_name: "Nabeel", design: "AR-206", laat_number: "3093", total_suit: 168,
    emb_sent_date: d.("2025-11-01"), emb_sent_qty: 168, emb_received_date: d.("2025-11-09"), emb_received_qty: 168,
    emb_paid: true, emb_paid_date: d.("2025-11-12"),
    production_date: d.("2025-11-09"),
    cutwork_sent_date: d.("2025-11-12"), cutwork_sent_qty: 168, cutwork_received_qty: 168,
    cutwork_paid: true, cutwork_paid_date: d.("2025-11-15"),
    overlock_sent_date: d.("2025-11-18"), overlock_sent_qty: 168, overlock_received_qty: 168,
    overlock_paid: true, overlock_paid_date: d.("2025-11-22"),
    handmade_sent_qty: 168, handmade_received_qty: 168,
    handmade_paid: true, handmade_paid_date: d.("2025-11-26"), handmade_return_date: d.("2025-11-28"),
    press_date: d.("2025-11-30"), out_date: d.("2025-12-02") },

  # SHORT DELIVERY at overlock (sent 168, only 165 back) + overlock payment pending.
  { emb_name: "Khawaja", design: "AR-178", laat_number: "3077", total_suit: 168,
    emb_sent_date: d.("2025-11-03"), emb_sent_qty: 168, emb_received_date: d.("2025-11-11"), emb_received_qty: 168,
    emb_paid: true, emb_paid_date: d.("2025-11-14"),
    production_date: d.("2025-11-11"),
    cutwork_sent_date: d.("2025-11-14"), cutwork_sent_qty: 168, cutwork_received_qty: 168,
    cutwork_paid: true, cutwork_paid_date: d.("2025-11-17"),
    overlock_sent_date: d.("2025-11-20"), overlock_sent_qty: 168, overlock_received_qty: 165,
    overlock_paid: false,
    handmade_paid: false, handmade_return_date: nil, press_date: nil, out_date: nil },

  # Small lot, classic "5 sent, 3 back" short delivery at cutwork + cutwork payment pending.
  { emb_name: "Rizwan", design: "AR-06", laat_number: "2963", total_suit: 5,
    emb_sent_date: d.("2025-11-10"), emb_sent_qty: 5, emb_received_date: d.("2025-11-15"), emb_received_qty: 5,
    emb_paid: true, emb_paid_date: d.("2025-11-16"),
    production_date: d.("2025-11-15"),
    cutwork_sent_date: d.("2025-11-19"), cutwork_sent_qty: 5, cutwork_received_qty: 3,
    cutwork_paid: false,
    overlock_paid: false, handmade_paid: false, press_date: nil, out_date: nil },

  # Early stage — sent to cutwork, awaiting return.
  { emb_name: "Sohail", design: "AR-205", laat_number: "2997", total_suit: 168,
    emb_sent_date: d.("2025-11-14"), emb_sent_qty: 168, emb_received_date: d.("2025-11-20"), emb_received_qty: 168,
    emb_paid: true, emb_paid_date: d.("2025-11-21"),
    production_date: d.("2025-11-20"),
    cutwork_sent_date: d.("2025-11-22"), cutwork_sent_qty: 168, cutwork_received_qty: nil,
    cutwork_paid: false, overlock_paid: false, handmade_paid: false },

  # Mid pipeline, handmade payment pending.
  { emb_name: "Safdar", design: "AR-235", laat_number: "3536", total_suit: 168,
    emb_sent_date: d.("2025-11-24"), emb_sent_qty: 168, emb_received_date: d.("2025-12-01"), emb_received_qty: 168,
    emb_paid: true, emb_paid_date: d.("2025-12-02"),
    production_date: d.("2025-12-01"),
    cutwork_sent_date: d.("2025-12-04"), cutwork_sent_qty: 168, cutwork_received_qty: 168,
    cutwork_paid: true, cutwork_paid_date: d.("2025-12-06"),
    overlock_sent_date: d.("2025-12-08"), overlock_sent_qty: 168, overlock_received_qty: 168,
    overlock_paid: true, overlock_paid_date: d.("2025-12-10"),
    handmade_sent_qty: 168, handmade_received_qty: 168, handmade_return_date: d.("2025-12-14"),
    handmade_paid: false, press_date: nil, out_date: nil }
]
lots.each { |attrs| ProductionLot.create!(attrs) }
puts "  #{ProductionLot.count} production lots seeded."

# Sample image attachments (solid-color PNG swatches) so the Tracking table shows
# real, inline-rendering thumbnails. Real uploads will be actual cloth photos.
require "stringio"
require "zlib"
solid_png = lambda do |w, h, r, g, b|
  raw = "".b
  h.times { raw << 0; w.times { raw << r << g << b } } # filter byte + RGB pixels
  chunk = ->(type, data) { [data.bytesize].pack("N") + type + data + [Zlib.crc32(type + data)].pack("N") }
  png = "\x89PNG\r\n\x1a\n".b
  png << chunk.("IHDR", [w, h].pack("NN") + [8, 2, 0, 0, 0].pack("C5"))
  png << chunk.("IDAT", Zlib::Deflate.deflate(raw))
  png << chunk.("IEND", "")
  png
end

samples = [
  ["AR-06",  "cutwork",  [74, 163, 223]],
  ["AR-06",  "emb_out",  [123, 79, 181]],
  ["AR-178", "overlock", [29, 138, 78]]
]
samples.each do |design, stage, (r, g, b)|
  lot = ProductionLot.find_by(design: design)
  next unless lot
  lot.lot_attachments.create!(stage: stage,
    file: { io: StringIO.new(solid_png.(200, 130, r, g, b)), filename: "#{design}-#{stage}.png", content_type: "image/png" })
end
puts "  #{LotAttachment.count} sample attachments seeded."

# Master data (designs, fabric types, workers, settings) — idempotent
load Rails.root.join("db/seeds_master.rb").to_s
load Rails.root.join("db/seeds_cost_cards.rb").to_s
load Rails.root.join("db/seeds_fabric_lots.rb").to_s

puts "------------------------------------------------------------"
puts "Logins:"
puts "  Super Admin : superadmin@arunit.com / super123   (all access)"
puts "  Admin       : admin@arunit.com      / admin123   (all access)"
puts "  Operator    : operator@arunit.com   / operator123 (view-only, limited menu)"
puts "------------------------------------------------------------"
