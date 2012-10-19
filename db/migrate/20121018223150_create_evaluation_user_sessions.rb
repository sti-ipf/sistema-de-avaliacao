class CreateEvaluationUserSessions < ActiveRecord::Migration
  def self.up
    create_table :evaluation_user_sessions do |t|
      t.integer :school_id
      t.integer :segment_id
      t.string :session_cookie
      t.datetime :last_request
      t.timestamps
    end
  end

  def self.down
    drop_table :evaluation_user_sessions
  end
end
