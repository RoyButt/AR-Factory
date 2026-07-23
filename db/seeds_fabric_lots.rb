# Fabric Lot seed (Laat 3093) — idempotent. Connects to Master Data designs.
puts "Seeding fabric lot 3093..."
def dv(code, size)
  DesignVariant.joins(:design).find_by(designs: { code: code }, size: size)
end

lot = FabricLot.find_or_initialize_by(laat_number: "3093")
lot.assign_attributes(line_type: "6Line", lot_date: Date.new(2025, 10, 28), total_suit: 2748)
lot.save!
lot.fabric_lot_lines.destroy_all
lot.fabric_lot_colors.destroy_all

colors = {
  "Zinic"  => [1576, 0],
  "Gajari" => [1607, 0],
  "Black"  => [1643, 9.5],
  "Red"    => [1621, 9.5],
  "Pista"  => [1597, 0],
  "Due"    => [1512, 14.5]
}
col = {}
colors.each { |name, (recv, w)| col[name] = lot.fabric_lot_colors.create!(name: name, received_gazana: recv, wastage: w) }

lines = [
  ["Khawaja", "AR-178", "28", "Zinic",  168],
  ["Rizwan",  "AR-06",  "28", "Gajari", 144],
  ["Nabeel",  "AR-206", "28", "Black",  168],
  ["Nabeel",  "AR-212", "28", "Red",    168],
  ["Nabeel",  "AR-205", "28", "Pista",  168],
  ["Nabeel",  "AR-35",  "28", "Due",    168]
]
lines.each do |contractor, code, size, color, suits|
  v = dv(code, size)
  next unless v
  lot.fabric_lot_lines.create!(contractor: contractor, design_variant: v, fabric_lot_color: col[color], suits: suits)
end

puts "  Lot 3093: #{lot.fabric_lot_colors.count} colors, #{lot.fabric_lot_lines.count} lines, total_received=#{lot.total_received}, used_suit=#{lot.used_suit}, remain_suit=#{lot.remain_suit}"
