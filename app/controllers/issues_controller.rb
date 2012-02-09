class IssuesController < ApplicationController
  def index
    issue = Issue.find_by_predecessor_id nil
    @issues = []
    if issue
    @issues << issue
      while issue.descendant do
        issue = issue.descendant
        @issues << issue
      end
    end
  end

  def show
    @issue = Issue.find(params[:id])
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
          break
        end
      end
    end

    if @issue && @issue.save
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
      if params[@type.to_sym]
        @issue = Issue.find(params[:id])
        new_type = params[@type.to_sym].delete :type
        @issue[:type] = new_type
        break
      end
    end

    if @issue && @issue.update_attributes(params[@type.to_sym])
      redirect_to issues_path, notice: 'Eintrag erfolgreich bearbeitet.'
    else
      @issue = Issue.find(params[:id])
      prepare_form
      render action: "edit"
    end
  end

  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy
    redirect_to issues_url
  end

  def change_order
    moved_issue = Issue.find params[:moved_issue_id]
    moved_issue.reload.pin_after params[:predecessor_id]
    render :nothing => true
  end

  private

  def prepare_form
    @projects = Project.all(:order => 'name ASC').collect do |project|
      [project.name, project.id]
    end
    a_number = 0
    @types = Issue.children_type_names.map do |name|
      [name, name]
    end
  end
end
