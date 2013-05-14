# -*- coding: utf-8 -*-
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :startpage, 'Startseite', index_path, :if => Proc.new { feature_active? :presentation }
    primary.item :backlogs, "Backlogs (#{@backlog_count}/#{@sprintbacklog_count})", issues_path, :highlights_on => controller_action_matcher('issues', 'index') 
    primary.item :finished_issues, "Abgeschlossene Einträge (#{@finished_issues_count})", finished_issues_path
  end
end
