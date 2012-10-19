class Survey < ActiveRecord::Base
  belongs_to :service_level
  belongs_to :school
  belongs_to :segment
end
