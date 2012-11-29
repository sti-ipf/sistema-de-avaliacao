class Dimension < ActiveRecord::Base
  belongs_to :service_level
  has_many :indicators
  has_many :practices
  has_many :dimension_statuses
  has_many :evaluation_answer_stats
  has_many :answer_log

  validates_presence_of :service_level_id, :name, :number

  begin
    ServiceLevel.all.each do |sl|
      scope sl.name, where(:service_level_id => sl.id)
    end
  rescue
  end

  def to_label
    "#{self.number} - #{self.name}"
  end
end

