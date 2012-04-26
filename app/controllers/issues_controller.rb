class IssuesController < ApplicationController
  def index
    if feature_active? :temp_lock_lists
      @backlog_issues = sorted_list Backlog.backlog.issues.first_in_list.first
      @sprint_issues = sorted_list Backlog.sprint_backlog.issues.first_in_list.first
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
    @issue = Issue.find(params[:id])
    prepare_form
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

    if feature_active? :temp_lock_lists
      old_first_issue = Backlog.backlog.issues.where(predecessor_id: nil).first
    else
      old_first_issue = Issue.in_backlog.find_by_predecessor_id(nil)
    end      
    @issue.predecessor_id = nil
    @issue.sprint_flag = false

    if @issue && @issue.save
      if old_first_issue
        old_first_issue.predecessor_id = @issue.id
        old_first_issue.save
      end
      redirect_to issues_path, notice: 'Eintrag erfolgreich erstellt.'
    else
      prepare_form
      render action: "new"
    end
  end

  def update
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
  end

  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy
    redirect_to issues_url
  end

  # moves backlog_item from one backlog to the other backlog
  #
  # @param [JSON-string] params[] moved item, backlog list, sprint backlog list
  # example:
  # {"moved_issue_id" => "3",
  # "backlog_list" => [[0] "4",[1] "1",[2] "2"],
  # "sprint_backlog_list" => [[0] "3"]}
  def change_list
    moved_issue = Issue.find params[:moved_issue_id]
    backlog_list = params[:backlog_list]
    sprint_backlog_list = params[:sprint_backlog_list]
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
    render :nothing => true
  end
  
  def finish_issue
    issue = Issue.find(params[:id])
    issue.finish
    if feature_active? :temp_lock_lists
      @backlog_issues = sorted_list Backlog.backlog.issues
    else
      @backlog_issues = sorted_list Issue.first.in_backlog[0]
    end    
    @sprint_issues = sorted_list Issue.first.in_sprint[0]
    render :index
  end

  def finished_issues_list 
    @finished_issues = sorted_list Issue.first.finished[0]
  end
  
  def activate_issue
    issue = Issue.find(params[:id])
    issue.activate
    @finished_issues = sorted_list Issue.first.finished[0]
    render :finished_issues_list
  end

  def lock_lists
    @lists_locked = false

    Backlog.transaction do
      backlog        = Backlog.backlog.lock(true)
      sprint_backlog = Backlog.sprint_backlog.lock(true)
      unless backlog.locked or sprint_backlog.locked
        sprint_backlog.locked = true
        backlog.locked        = true
        backlog.session_id        = session[:session_id]
        sprint_backlog.session_id = session[:session_id]
        backlog.save!
        sprint_backlog.save!
        @lists_locked = true
      end
    end
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
end
