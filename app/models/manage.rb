class Manage < ActiveRecord::Base

  def self.columns 
    @columns ||= []
  end

  def self.search_without_dimension(school, service_level, segment)
    [
      "delete from answer_logs where school_id = (select id from schools where name = '#{school}') AND segment_id = (select id from segments where name = '#{segment}' AND service_level_id = (select id from service_levels where name like '#{service_level}'));",
      "delete from answers where school_id = (select id from schools where name = '#{school}') AND segment_id = (select id from segments where name = '#{segment}' AND service_level_id = (select id from service_levels where name like '#{service_level}'));",
      "delete from dimension_statuses where school_id = (select id from schools where name = '#{school}') AND segment_id = (select id from segments where name = '#{segment}' AND service_level_id = (select id from service_levels where name like '#{service_level}'));",
      "update evaluation_answer_stats set started_to_answer = null where school_id = (select id from schools where name = '#{school}') AND segment_id = (select id from segments where name = '#{segment}' AND service_level_id = (select id from service_levels where name like '#{service_level}'));",
      "delete from practices where school_id = (select id from schools where name = '#{school}') AND segment_id = (select id from segments where name = '#{segment}' AND service_level_id = (select id from service_levels where name like '#{service_level}'));"
    ]
  end

  def self.full_search(school, service_level, segment, dimension)
    ["DELETE FROM answer_logs 
      WHERE  dimension_id = (SELECT id 
                             FROM   dimensions 
                             WHERE  number = #{dimension} 
                                    AND service_level_id = (SELECT id 
                                                            FROM   service_levels 
                                                            WHERE  name = '#{service_level}')) 
             AND school_id = (SELECT id 
                              FROM   schools 
                              WHERE  name = '#{school}') 
             AND segment_id = (SELECT id 
                               FROM   segments 
                               WHERE  name = '#{segment}' 
                                      AND service_level_id = (SELECT id 
                                                              FROM   service_levels 
                                                              WHERE 
                                          name LIKE '#{service_level}')); ", "DELETE FROM answers 
      WHERE  question_text_id IN (SELECT id 
                                  FROM   question_texts 
                                  WHERE  question_id IN (SELECT id 
                                                         FROM   questions 
                                                         WHERE  indicator_id IN 
                                                                (SELECT id 
                                                                 FROM 
                                                                indicators 
                                                                                 WHERE 
                                                                dimension_id = 
                                         (SELECT id 
                                          FROM   dimensions 
                                          WHERE  number = #{dimension} 
                                                 AND service_level_id 
                                                     = ( 
                                                     SELECT id 
                                                     FROM 
                                                     service_levels 
                                                     WHERE 
                                                     name = '#{service_level}')) 
                                         ) 
                                                        )) 
             AND school_id = (SELECT id 
                              FROM   schools 
                              WHERE  name = '#{school}') 
             AND segment_id = (SELECT id 
                               FROM   segments 
                               WHERE  name = '#{segment}' 
                                      AND service_level_id = (SELECT id 
                                                              FROM   service_levels 
                                                              WHERE 
                                          name LIKE '#{service_level}')); ", "DELETE FROM dimension_statuses 
      WHERE  dimension_id = (SELECT id 
                             FROM   dimensions 
                             WHERE  number = #{dimension} 
                                    AND service_level_id = (SELECT id 
                                                            FROM   service_levels 
                                                            WHERE  name = '#{service_level}')) 
             AND school_id = (SELECT id 
                              FROM   schools 
                              WHERE  name = '#{school}') 
             AND segment_id = (SELECT id 
                               FROM   segments 
                               WHERE  name = '#{segment}' 
                                      AND service_level_id = (SELECT id 
                                                              FROM   service_levels 
                                                              WHERE 
                                          name LIKE '#{service_level}')); ", "UPDATE evaluation_answer_stats 
      SET    started_to_answer = NULL 
      WHERE  dimension_id = (SELECT id 
                             FROM   dimensions 
                             WHERE  number = #{dimension} 
                                    AND service_level_id = (SELECT id 
                                                            FROM   service_levels 
                                                            WHERE  name = '#{service_level}')) 
             AND school_id = (SELECT id 
                              FROM   schools 
                              WHERE  name = '#{school}') 
             AND segment_id = (SELECT id 
                               FROM   segments 
                               WHERE  name = '#{segment}' 
                                      AND service_level_id = (SELECT id 
                                                              FROM   service_levels 
                                                              WHERE 
                                          name LIKE '#{service_level}')); ", "DELETE FROM practices 
      WHERE  dimension_id = (SELECT id 
                             FROM   dimensions 
                             WHERE  number = #{dimension} 
                                    AND service_level_id = (SELECT id 
                                                            FROM   service_levels 
                                                            WHERE  name = '#{service_level}')) 
             AND school_id = (SELECT id 
                              FROM   schools 
                              WHERE  name = '#{school}') 
             AND segment_id = (SELECT id 
                               FROM   segments 
                               WHERE  name = '#{segment}' 
                                      AND service_level_id = (SELECT id 
                                                              FROM   service_levels 
                                                              WHERE 
                                          name LIKE '#{service_level}')); "
          ]
  end
  
end
