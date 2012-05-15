class IssuesController < ApplicationController
  before_filter :check_locks

  def index
    if feature_active? :temp_lock_lists
      # if lists are locked show newly created issues only to other users
      if @lists_locked_by_current_user
        @backlog_issues = sorted_list(Backlog.backlog.first_issue)
      else
        @backlog_issues = sorted_list(Backlog.new_issues.first_issue) + sorted_list(Backlog.backlog.first_issue)
      end
      @sprint_issues = sorted_list Backlog.sprint_backlog.first_issue
    else
      @backlog_issues = sorted_list Issue.first.in_backlog[0]
      @sprint_issues = sorted_list Issue.first.in_sprint[0]
    end      
  end

  def new
    @issue = Issue.new
    prepare_form
  end

  def edit
    if @lists_locked_by_current_user
      @issue = Issue.find(params[:id])
      prepare_form
    else
      redirect_to issues_path, notice: I18n.t("backlog.errors.lists_not_locked")
    end
  end

  def create
    if params[:issue]
      type = params[:issue][:type]
      if Issue.children_type_names.include? type
        model_class = Kernel.const_get type
        params[:issue][:story_points] = nil if params[:issue][:story_points] == 'unknown'
        @issue = model_class.new(params[:issue])
      end
    else
      types = Issue.children_type_names
      @issue = nil
      types.each do |t|
        @type = t.gsub(/(.)([A-Z])/,'\1_\2').downcase
        if params[@type.to_sym]
          model_class = Kernel.const_get t
          @issue = model_class.new(params[@type.to_sym])
          params[@type.to_sym][:story_points] = nil if params[@type.to_sym][:story_points] == 'unknown'
          break
        end
      end
    end

    if @issue
      if feature_active? :temp_lock_lists
        if @lists_locked_by_current_user
          old_first_issue = Backlog.backlog.first_issue
          Backlog.backlog.issues << @issue
        else
          old_first_issue = Backlog.new_issues.first_issue
          Backlog.new_issues.issues << @issue
        end
      else
        old_first_issue = Issue.in_backlog.find_by_predecessor_id(nil)
        @issue.sprint_flag = false
      end      
      @issue.predecessor_id = nil
    end

    if @issue && @issue.save
      if old_first_issue
        old_first_issue.predecessor_id = @issue.id
        old_first_issue.save!
      end
      redirect_to issues_path, notice: 'Eintrag erfolgreich erstellt.'
    else
      prepare_form
      render action: "new"
    end
  end

  def update
    if @lists_locked_by_current_user
      types = Issue.children_type_names
      @issue = nil

      types.each do |t|
        @type = t.gsub(/(.)([A-Z])/,'\1_\2').downcase
        if params[@type]
          @issue = Issue.find(params[:id])
          new_type = params[@type].delete :type
          @issue[:type] = new_type
          break
        end
      end

      params[@type][:story_points] = nil if params[@type][:story_points] == 'unknown'

      if @issue && @issue.update_attributes(params[@type])
        redirect_to issues_path, notice: 'Eintrag erfolgreich bearbeitet.'
      else
        prepare_form
        render action: "edit"
      end
    else
      redirect_to issues_path, notice: I18n.t("backlog.errors.lists_not_locked")
    end
  end

  def destroy
    if @lists_locked_by_current_user
      @issue = Issue.find(params[:id])
      @issue.destroy
      redirect_to issues_url
    else
      redirect_to issues_path, notice: I18n.t("backlog.errors.lists_not_locked")
    end
  end

  # moves backlog_item from one backlog to the other backlog
  #
  # @param [JSON-string] params[] moved item, backlog list, sprint backlog list
  # example:
  # {"moved_issue_id" => "3",
  # "backlog_list" => [[0] "4",[1] "1",[2] "2"],
  # "sprint_backlog_list" => [[0] "3"]}
  def change_list
    feature_active? :temp_lock_lists do
      extend_lock_time_in_db
    end

    if @lists_locked_by_current_user
      moved_issue = Issue.find params[:moved_issue_id]
      backlog_list = params[:backlog_list]
      sprint_backlog_list = params[:sprint_backlog_list]

      if feature_active? :temp_lock_lists
        if sprint_backlog_list and sprint_backlog_list.include?(moved_issue.id)
          Backlog.sprint_backlog.issues << moved_issue
        else
          Backlog.backlog.issues << moved_issue
        end
        moved_issue.save!
        Backlog.backlog.update_with_list backlog_list
        Backlog.sprint_backlog.update_with_list sprint_backlog_list
      else
        if backlog_list == nil 
          backlog_list = Array.new   
        end
        if sprint_backlog_list 
          if sprint_backlog_list.include?(moved_issue.id)
            moved_issue.sprint_flag = true;
            moved_issue.save
          else
            moved_issue.sprint_flag = false;
            moved_issue.save
          end 
        else
          sprint_backlog_list = Array.new
        end
        moved_issue.reload.update_lists backlog_list, sprint_backlog_list
      end    
    end

    render :nothing => true
  end

  def finish_issue
    if @lists_locked_by_current_user
      issue = Issue.find(params[:id])
      issue.finish
      if feature_active? :temp_lock_lists
        @backlog_issues = sorted_list Backlog.backlog.first_issue
        @sprint_issues  = sorted_list Backlog.sprint_backlog.first_issue
      else
        @backlog_issues = sorted_list Issue.first.in_backlog[0]
        @sprint_issues  = sorted_list Issue.first.in_sprint[0]
      end    
      render :index
    else
      redirect_to issues_path, notice: I18n.t("backlog.errors.lists_not_locked")
    end
  end

  def finished_issues_list 
    if feature_active? :temp_lock_lists
      @finished_issues = sorted_list Backlog.finished_backlog.first_issue
    else
      @finished_issues = sorted_list Issue.first.finished[0]
    end 
  end

  def activate_issue
    issue = Issue.find(params[:id])
    issue.activate
    if feature_active? :temp_lock_lists
      @finished_issues = sorted_list Backlog.finished_backlog.first_issue
    else
      @finished_issues = sorted_list Issue.first.finished[0]
    end    
    render :finished_issues_list
  end

  def toggle_list_locks
    session_id = session[:session_id]
    @lists_locked_by_another_user = false
    @lists_locked_by_current_user = false

    # variable shows if this method shall lock or unlock lists
    lock_mode = true

    Backlog.transaction do
      # lock backlogs for this action with activerecord techniques
      backlog = Backlog.backlog_with_lock
      sprint_backlog = Backlog.sprint_backlog_with_lock

      # unlock backlogs
      [backlog, sprint_backlog].each do |bl|
        if bl.locked_by_another_session? session_id
          @lists_locked_by_another_user = true
        elsif bl.locked_by_session? session_id
          bl.unlock
          bl.save!
        else
          # lock backlogs for the duration of several actions through lock flags in the DB table 
          bl.lock_for_session session_id
          @lists_locked_by_current_user = true
          bl.changed? ? bl.save! : bl.touch
        end
      end

      if @lists_locked_by_current_user
        @backlog_issues = sorted_list backlog.first_issue
        @sprint_issues = sorted_list sprint_backlog.first_issue
      end
    end
  end

  def extend_lock_time
    extend_lock_time_in_db
  end

  private

  def prepare_form
    @projects = Project.all(:order => 'name ASC').collect do |project|
      [project.name, project.id]
    end
    a_number = 0
    @types = Issue.children_type_names.map do |name|
      name
    end
    @story_points = ['unknown', 0, 0.5, 1, 2, 3, 5, 8, 13, 20]
  end

  def sorted_list element
    issues = []
    if element
      issues << element
      while element.descendant do
        element = element.descendant
        issues << element
      end
    end
    issues
  end

  def check_locks
    if feature_active? :temp_lock_lists
      session_id = session[:session_id]
      now = Time.zone.now

      Backlog.transaction do
        # lock backlogs for this action with activerecord techniques
        backlog = Backlog.backlog_with_lock
        sprint_backlog = Backlog.sprint_backlog_with_lock

        [backlog, sprint_backlog].each do |bl|
          elapsed_with_delay = (now - bl.updated_at - Configurable.max_lock_time_delay) > Configurable.max_lock_time
          if bl.locked && elapsed_with_delay
            bl.unlock
            bl.save!
          else
            @lists_locked_by_current_user |= bl.locked_by_session?(session_id)
            @lists_locked_by_another_user |= bl.locked_by_another_session?(session_id)
          end
        end
        clip_new_issues
      end
    else
      @lists_locked_by_current_user = true
    end
  end

  # Clip new issues to the backlog list
  def clip_new_issues
    unless Backlog.backlog.locked or Backlog.new_issues.issues.empty?
      Backlog.backlog.first_issue.update_attributes(predecessor_id: Backlog.new_issues.last_issue.id) if Backlog.backlog.first_issue
      Backlog.backlog.issues << Backlog.new_issues.issues
    end
  end

  def extend_lock_time_in_db
    if @lists_locked_by_current_user
      Backlog.transaction do
        # lock backlogs for this action with activerecord techniques
        backlog = Backlog.backlog_with_lock
        sprint_backlog = Backlog.sprint_backlog_with_lock

        [backlog, sprint_backlog].each do |bl|
          bl.touch
        end
      end
    end
  end
end
