class IssuesController < ApplicationController
  before_filter :check_locks, :except => :timeout_elapsed
  @@reset_timeout = false

  def index
    # if lists are locked show newly created issues only to other users
    if @lists_locked_by_current_user
      @backlog_issues = with_old_flag(sorted_list(Backlog.backlog.first_issue))
    else
      @backlog_issues = with_new_flag(sorted_list(Backlog.new_issues.first_issue)) + with_old_flag(sorted_list(Backlog.backlog.first_issue))
    end
    if @@reset_timeout
      @reset_timeout = true
      @@reset_timeout = false
    end

    @sprint_issues = with_old_flag(sorted_list(Backlog.sprint_backlog.first_issue))
  end

  def new
    set_max_lock_time Configurable.max_edit_lock_time if @lists_locked_by_current_user
    extend_lock_time_in_db
    @issue = Issue.new
    prepare_form
  end

  def edit
    if @lists_locked_by_current_user
      set_max_lock_time Configurable.max_edit_lock_time
      extend_lock_time_in_db
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
      if @lists_locked_by_current_user
        old_first_issue = Backlog.backlog.first_issue
        Backlog.backlog.issues << @issue
        set_max_lock_time Configurable.default_max_lock_time
        @@reset_timeout = true
      else
        old_first_issue = Backlog.new_issues.first_issue
        Backlog.new_issues.issues << @issue
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
      set_max_lock_time Configurable.default_max_lock_time
      @@reset_timeout = true

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
    extend_lock_time_in_db

    if @lists_locked_by_current_user
      moved_issue = Issue.find params[:moved_issue_id]
      backlog_list = params[:backlog_list]
      sprint_backlog_list = params[:sprint_backlog_list]

      if sprint_backlog_list and sprint_backlog_list.include?(moved_issue.id)
        Backlog.sprint_backlog.issues << moved_issue
      else
        Backlog.backlog.issues << moved_issue
      end
      moved_issue.save!
      Backlog.backlog.update_with_list backlog_list
      Backlog.sprint_backlog.update_with_list sprint_backlog_list
    end

    render :nothing => true
  end

  def finish_issue
    if @lists_locked_by_current_user
      issue = Issue.find(params[:id])
      issue.finish
      @backlog_issues = with_old_flag(sorted_list(Backlog.backlog.first_issue))
      @sprint_issues  = with_old_flag(sorted_list(Backlog.sprint_backlog.first_issue))
      render :index
    else
      redirect_to issues_path, notice: I18n.t("backlog.errors.lists_not_locked")
    end
  end

  def finished_issues_list 
    @finished_issues = with_old_flag sorted_list Backlog.finished_backlog.first_issue
  end

  def activate_issue
    issue = Issue.find(params[:id])
    issue.activate
    @finished_issues = sorted_list Backlog.finished_backlog.first_issue
    render :finished_issues_list
  end

  def toggle_list_locks
    set_max_lock_time Configurable.default_max_lock_time if @lists_locked_by_current_user

    session_id = session[:session_id]
    @lists_locked_by_another_user = false
    @lists_locked_by_current_user = false

    # variable shows if this method shall lock or unlock lists
    lock_mode = true
    sprint_backlog = Backlog.sprint_backlog
    backlog = Backlog.backlog

    backlog.with_lock do
      if backlog.locked_by_another_session? session_id
        @lists_locked_by_another_user = true
      elsif backlog.locked_by_session? session_id
        backlog.unlock
        backlog.save!
      else
        # set locking duration to default before start locking 
        set_max_lock_time Configurable.default_max_lock_time 
        
        # lock backlogs for the duration of several actions through lock flags in the DB table 
        backlog.lock_for_session session_id
        @lists_locked_by_current_user = true
        backlog.changed? ? backlog.save! : backlog.touch
      end
    end

    @backlog_issues = with_new_flag(sorted_list(Backlog.new_issues.first_issue)) + with_old_flag(sorted_list(Backlog.backlog.first_issue))
    @sprint_issues = with_old_flag(sorted_list(sprint_backlog.first_issue))
  end

  def extend_lock_time
    extend_lock_time_in_db
  end

  def timeout_elapsed
    backlog = Backlog.backlog
    backlog.with_lock do
      backlog.unlock
      backlog.save!
      @lists_locked_by_current_user = false
    end

    @backlog_issues = with_new_flag(sorted_list(Backlog.new_issues.first_issue)) + with_old_flag(sorted_list(Backlog.backlog.first_issue))
    @sprint_issues = with_old_flag(sorted_list(Backlog.sprint_backlog.first_issue))
    
    respond_to do |format|
      format.json{render :partial => "issues/timeout_elapsed.json"}
    end
  end

  def set_timeout_to_default
    if @lists_locked_by_current_user
      set_max_lock_time Configurable.default_max_lock_time
      @@reset_timeout = true
      extend_lock_time_in_db
    end

    render :nothing => true
  end
  
  def get_start_time
    render :text => Backlog.backlog.updated_at.to_i
  end
  
  def get_max_lock_time
    render :text => Configurable.max_lock_time
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
    session_id = session[:session_id]
    now = Time.zone.now

    sprint_backlog = Backlog.sprint_backlog
    backlog = Backlog.backlog

    backlog.with_lock do
      elapsed_with_delay = (now - backlog.updated_at - Configurable.max_lock_time_delay) > Configurable.max_lock_time
      if backlog.locked && elapsed_with_delay
        backlog.unlock
        backlog.save!
      else
        @lists_locked_by_current_user |= backlog.locked_by_session?(session_id)
        @lists_locked_by_another_user |= backlog.locked_by_another_session?(session_id)
      end
    end

    clip_new_issues
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
      backlog = Backlog.backlog
      backlog.with_lock do
        backlog.touch
      end
    end
  end

  def with_old_flag issue_list
    issue_list.collect do |issue|
      [issue, :old]
    end
  end

  def with_new_flag issue_list
    issue_list.collect do |issue|
      [issue, :new]
    end
  end

  def set_max_lock_time max
    max_lock_time = Configurable.find_or_create_by_name 'max_lock_time'
    max_lock_time.value = max
    max_lock_time.save
    extend_lock_time_in_db
  end
end
