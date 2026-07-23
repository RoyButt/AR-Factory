class ProductionParty < ApplicationRecord
  has_many :stitching_jobs, dependent: :nullify
  has_many :stitching_earnings, dependent: :destroy
  has_many :stitching_payments, dependent: :destroy
  has_many :production_claims, dependent: :destroy
  has_one_attached :photo
  has_one_attached :cnic_front
  has_one_attached :cnic_back
  validates :name, presence: true
  default_scope { order(:position, :name) }

  # Khata: earned (we owe for stitching) − paid = balance outstanding.
  # Payments include the onboarding advance, so it's automatically deducted from their work.
  def earned;  stitching_earnings.sum { |e| e.amount.to_f }.round(2); end
  def paid;    stitching_payments.sum { |p| p.amount.to_f }.round(2); end
  # Claims (ruined suits charged back at the handmade/final step) also reduce what we owe them.
  def claims;  production_claims.sum { |c| c.amount.to_f }.round(2); end
  def balance; (earned - paid - claims).round(2); end

  # The onboarding advance (a flagged payment), if any.
  def advance_payment; stitching_payments.detect(&:advance?); end
  def advance_amount;  advance_payment&.amount.to_f; end

  DEFAULTS = ["Bilal 3", "Aqsa", "Yaseen grup", "kashif", "Zulfqar", "Dildar", "Maqsod", "Akbar 2",
              "Afzal", "Hassan", "Jawaid 3", "Aziz", "Zahid 4", "RAIZ", "Naeem", "Majid", "Nadir"].freeze

  # Seed the default production persons once (idempotent).
  def self.seed_defaults!
    DEFAULTS.each_with_index do |n, i|
      find_or_create_by!(name: n) { |p| p.position = i }
    end
  end
end
