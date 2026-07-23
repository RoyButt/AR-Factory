class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  # Cached lookup of a formula constant by key (used by DesignVariant, cost cards…).
  def self.value_for(key, default = 0)
    cache.fetch(key.to_s, default).to_f
  end

  def self.cache
    @cache ||= pluck(:key, :value).to_h
  end

  def self.reset_cache!
    @cache = nil
  end

  after_commit { Setting.reset_cache! }
end
