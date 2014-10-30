# -*- coding: utf-8 -*-
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :startpage, 'Startseite', index_path, :if => Proc.new { feature_active? :presentation }
    if feature_active? :temp_changes_for_iso
      primary.item :new_issues_list, "Neue Einträge (#{@new_issues_count})", new_issues_path, :highlights_on => controller_action_matcher('issues', 'new_issues_list')
      primary.item :backlogs, "Backlogs (#{@backlog_count}/#{@sprintbacklog_count})", issues_path
    else
      primary.item :backlogs, "Backlogs (#{@backlog_count}/#{@sprintbacklog_count})", issues_path, :highlights_on => controller_action_matcher('issues', 'index')
    end

    primary.item :finished_issues, "Abgeschlossene Einträge (#{@finished_issues_count})", finished_issues_path
    primary.item :index, "Alle Projekte (#{Project.count})", projects_path
  end
end
