class CardAddon < ApplicationRecord
  belongs_to :cost_card

  TARGETS = { "emb" => "EMB Cost", "final" => "Final Rate" }.freeze

  def target_label
    TARGETS[target] || target
  end
end
