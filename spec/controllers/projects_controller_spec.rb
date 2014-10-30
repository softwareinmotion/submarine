require 'spec_helper'

describe ProjectsController do
  let(:project) { create :project }

  describe '#index' do
    it 'assigns all projects as @projects' do
      get :index

      expect(assigns(:projects)).to eq([project])
    end

    it 'renders the index view' do
      get :index

      expect(response).to render_template(:index)
    end
  end

  describe '#create' do
    context 'given valid params' do
      let(:valid_params) {{ project: attributes_for(:project, name: 'Testprojekt') }}

      it 'creates a new project' do
        expect { post :create, valid_params }.to change(Project, :count).by(1)
      end

      it 'assigns the new project as @project' do
        post :create, valid_params

        expect(assigns(:project)).to eq(Project.first)
      end

      it 'displays a success message' do
        post :create, valid_params

        expect(flash[:notice]).to eq('Projekt erfolgreich angelegt!')
      end

      it 'redirects to projects_path' do
        post :create, valid_params

        expect(response).to redirect_to(projects_path)
      end
    end

    context 'given invalid params' do
      let(:invalid_params) {{ project: attributes_for(:project, name: nil) }}

      it 'does not save the project' do
        expect { post :create, invalid_params }.to_not change(Project, :count)
      end

      it 'stores the errors to @issue' do
        post :create, invalid_params

        expect(assigns(:project)).to have(1).error_on :name
      end

      it 're-renders the new view' do
        post :create, invalid_params

        expect(response).to render_template(:new)
      end
    end
  end

  describe '#new' do
    before :each do
      get :new
    end

    it 'assigns a new project to @project' do
      expect(assigns(:project)).to be_a_new(Project)
    end

    it 'renders the new view' do
      expect(response).to render_template(:new)
    end
  end

  describe '#edit' do
    before :each do
      get :edit, id: project.id
    end

    it 'assigns the requested project to @project' do
      expect(assigns(:project)).to eq(project)
    end

    it 'renders the edit view' do
      expect(response).to render_template(:edit)
    end
  end

  describe '#update' do
    context 'given valid params' do
      let(:valid_params) {{ :id => project.id, project: attributes_for(:project, name: 'Testprojekt') }}

      it 'assigns the requested project as @project' do
        put :update, valid_params

        expect(assigns(:project)).to eq(project)
      end

      it 'updates the requested project' do
        pro = Project.new
        Project.stub(:find).and_return(pro)

        expect(pro).to receive(:update).with('name' => 'IssueX')

        put :update, id: 42, project: { 'name' => 'IssueX' }
      end

      it 'displays a success message' do
        put :update, valid_params

        expect(flash[:notice]).to eq('Erfolgreich editiert.')
      end

      it 'redirects to projects_path' do
        put :update, valid_params

        expect(response).to redirect_to(projects_path)
      end
    end

    context 'given invalid params' do
      let(:invalid_params) {{ :id => project.id, project: attributes_for(:project, name: nil) }}

      it 're-renders the edit view' do
        put :update, invalid_params

        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    before :each do
      Project.stub(:find => project)
    end

    it 'calls destroy on the project' do
      expect(project).to receive(:destroy)

      delete :destroy, id: 42
    end

    it 'redirects to projects_path' do
      delete :destroy, id: project.id

      expect(response).to redirect_to(projects_path)
    end

    context 'given a destroyable project' do
      let(:backlog) { create :backlog }
      let(:issue) { create :issue, backlog: backlog, project: project }

      it 'displays a success message' do
        delete :destroy, id: project.id

        expect(flash[:notice]).to eq('Erfolgreich gelöscht.')
      end
    end

    context 'given an undestroyable project' do
      let(:finished_backlog) { create :backlog, name: 'finished_backlog' }
      let!(:issue) { create :issue, backlog: finished_backlog, project: project }

      it 'displays an error message' do
        delete :destroy, id: project.id

        expect(flash[:notice]).to eq('Projekte können nur gelöscht werden, wenn alle Issues abgeschlossen sind!')
      end
    end
  end
end