# encoding: utf-8
class ProjectsController < ApplicationController
  def index
    @projects = Project.all
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to projects_path, :notice => 'Projekt erfolgreich angelegt!'
    else
      render :action => "new"
    end
  end

  def new
    @project = Project.new
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(project_params)
      redirect_to projects_path, :notice => 'Erfolgreich Editiert'
    else
      render :action => 'edit'
    end
  end

  def project_icon
    project = Project.find(params[:id])
    send_data project.project_icon.read, filename: project.project_icon.file.filename
  end

  def destroy
    @project = Project.find(params[:id])
    if Issue.where('project_id = ?',@project.id).where('backlog_id != ?', Backlog.finished_backlog).count == 0
      @project.destroy
      redirect_to projects_path, :notice => 'Erfolgreich Gelöscht'
    else
      redirect_to projects_path, :notice => 'Projekte können nur Gelöscht werden wenn alle Issues abgeschlossen sind!'
    end
  end

  private

  def project_params
    params.require(:project).permit("name", "project_icon_cache", "project_icon", "remove_project_icon")
  end
end