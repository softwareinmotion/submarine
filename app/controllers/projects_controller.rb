# encoding: utf-8
class ProjectsController < ApplicationController
  before_action :set_project, only: [:edit, :update, :destroy, :project_icon]

  def index
    @projects = Project.all
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to projects_path, :notice => t('project.successful_added')
    else
      render :action => 'new'
    end
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to projects_path, :notice => t('project.successful_edited')
    else
      render :action => 'edit'
    end
  end

  def project_icon
    send_data @project.project_icon.read, filename: @project.project_icon.file.filename
  end

  def destroy
    if Issue.where('project_id = ?', @project.id).where('backlog_id != ?', Backlog.finished_backlog).count == 0
      @project.destroy
      redirect_to projects_path, :notice => t('project.successful_deleted')
    else
      redirect_to projects_path, :notice => t('project.not_destroyable')
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit("name", "project_icon_cache", "project_icon", "remove_project_icon")
  end
end