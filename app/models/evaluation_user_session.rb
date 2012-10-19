class EvaluationUserSession < ActiveRecord::Base

  def self.update school_id, segment_id, session_cookie
    session = EvaluationUserSession.where(:school_id => school_id, :segment_id => segment_id, :session_cookie => session_cookie).first
    return false if session.nil?
    return session.update_attribute(:last_request,  Time.now)
  end

  def self.erase_old_sessions
    sessions = EvaluationUserSession.all
    sessions.each do |session|
      if(session.last_request - Time.now > 10.minutes)
        session.destroy
      end
    end
  end

end
