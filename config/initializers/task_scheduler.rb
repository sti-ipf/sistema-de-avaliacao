require 'rubygems'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every("10m") do
  EvaluationUserSession.erase_old_sessions
end
