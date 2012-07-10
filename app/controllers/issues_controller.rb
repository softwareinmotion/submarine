class IssuesController < ApplicationController
  
  def index
    @backlog_issues = sorted_list(Backlog.backlog.first_issue)
    @sprint_issues = sorted_list(Backlog.sprint_backlog.first_issue)
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

    if @issue
      old_first_issue = Backlog.backlog.first_issue
      Backlog.backlog.issues << @issue
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
    moved_issue = Issue.find params[:moved_issue]
    predecessor = params[:predecessor] ? Issue.find(params[:predecessor]) : nil
    backlog = Backlog.find_by_name params[:backlog]
    lock_version = params[:issues]
    if predecessor
      moved_issue.move_to backlog, new_predecessor: predecessor
    else
      moved_issue.move_to backlog 
    end
    
    render :nothing => true
  end

  def finish_issue
    issue = Issue.find(params[:id])
    issue.finish
    @backlog_issues = sorted_list(Backlog.backlog.first_issue)
    @sprint_issues  = sorted_list(Backlog.sprint_backlog.first_issue)
    render :index
  end

  def finished_issues_list 
    @finished_issues = sorted_list Backlog.finished_backlog.first_issue
  end

  def activate_issue
    issue = Issue.find(params[:id])
    issue.activate
    @finished_issues = sorted_list Backlog.finished_backlog.first_issue
    redirect_to finished_issues_url
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
