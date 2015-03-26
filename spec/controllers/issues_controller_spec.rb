require 'spec_helper'

describe IssuesController do
  let(:project) { create :project }
  let(:backlog) { create :backlog }
  let(:sprint_backlog) { create :backlog, name: 'sprint_backlog' }
  let(:finished_backlog) { create :backlog, name: 'finished_backlog' }
  feature_active? :temp_changes_for_iso do
    let(:new_issues) { create :backlog, name: 'new_issues' }
  end

  describe '#index' do
    it 'assigns all backlog issues (sorted) to @backlog_issues' do
      issue = create :user_story, backlog: backlog
      controller.stub(:sorted_list).and_return([issue])

      get :index

      expect(assigns(:backlog_issues)).to eq([issue])
    end

    it 'assigns all sprint backlog issues (sorted) to @sprint_issues' do
      issue = create :user_story, backlog: sprint_backlog
      controller.stub(:sorted_list).and_return([issue])

      get :index

      expect(assigns(:sprint_issues)).to eq([issue])
    end

    it 'calls extension_whitelist' do
      expect(controller).to receive(:extension_whitelist)

      get :index
    end

    it 'renders the index view' do
      get :index

      expect(response).to render_template(:index)
    end
  end

  describe '#new' do
    it 'assigns a new issue to @issue' do
      get :new

      expect(assigns(:issue)).to be_a_new(Issue)
    end

    it 'calls extension_whitelist' do
      expect(controller).to receive(:extension_whitelist)

      get :new
    end

    it 'calls prepare_form' do
      expect(controller).to receive(:prepare_form)

      get :new
    end

    it 'renders the new view' do
      get :new

      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
    context 'given valid params' do
      let(:valid_params) {{ :issue => { name: 'Issue1', description: 'Toller Issue', story_points: '1', type: 'UserStory', project_id: project.id } }}

      it 'creates a new issue' do
        expect{post :create, valid_params}.to change(Issue, :count).by(1)
      end

      it 'assigns the new issue to @issue' do
        post :create, valid_params

        expect(assigns(:issue)).to eq(Issue.first)
      end

      it 'displays a success message' do
        post :create, valid_params

        expect(flash[:notice]).to eq(I18n.t('issue.successful_added'))
      end

      if feature_active? :temp_changes_for_iso
        it 'adds the new issue to the new_issues list' do
          post :create, valid_params

          expect(Backlog.new_issues_list.issues).to include(Issue.first)
        end

        it 'redirects to the new_issues_path' do
          post :create, valid_params

          expect(response).to redirect_to(new_issues_path)
        end

        it 'does not change examined_at' do
          post :create, valid_params

          expect(Issue.first.examined_at).to eq(nil)
        end

        it 'does not change planned_at' do
          post :create, valid_params

          expect(Issue.first.planned_at).to eq(nil)
        end

        it 'does not change done_at' do
          post :create, valid_params

          expect(Issue.first.done_at).to eq(nil)
        end

        it 'does not change finished_at' do
          post :create, valid_params

          expect(Issue.first.finished_at).to eq(nil)
        end

        it 'does not change ready_to_finish' do
          post :create, valid_params

          expect(Issue.first.ready_to_finish).to eq(false)
        end
      else
        it 'adds the new issue to the backlog list' do
          post :create, valid_params

          expect(Backlog.backlog.issues).to include(Issue.first)
        end

        it 'redirects to the issues_path' do
          post :create, valid_params

          expect(response).to redirect_to(issues_path)
        end
      end
    end

    context 'given invalid params' do
      let(:invalid_params) {{ :issue => { name: nil, description: 'Toller Issue', story_points: '1', type: 'UserStory', project_id: project.id } }}

      it 'does not save the issue' do
        expect { post :create, invalid_params }.to_not change(Issue, :count)
      end

      it 'stores the errors to @issue' do
        post :create, invalid_params

        expect(assigns(:issue)).to have(1).error_on :name
      end

      it 're-renders the new view' do
        post :create, invalid_params

        expect(response).to render_template(:new)
      end

      it 'calls extension_whitelist' do
        controller.should_receive(:extension_whitelist)

        post :create, invalid_params
      end

      it 'calls prepare_form' do
        expect(controller).to receive(:prepare_form)

        post :create, invalid_params
      end
    end
  end

  describe '#edit' do
    let!(:issue) { create :user_story }

    it 'assigns the requested issue as @issue' do
      get :edit, id: issue.id

      expect(assigns(:issue)).to eq(issue)
    end

    it 'calls extension_whitelist' do
      expect(controller).to receive(:extension_whitelist)

      get :edit, id: issue.id
    end

    it 'calls prepare_form' do
      expect(controller).to receive(:prepare_form)

      get :edit, id: issue.id
    end

    it 'renders the edit view' do
      get :edit, id: issue.id

      expect(response).to render_template(:edit)
    end
  end

  describe '#update' do
    let!(:issue) { create :user_story, backlog: Backlog.sprint_backlog }

    context 'given valid params' do
      let(:valid_params) {{ :id => issue.id, :user_story => { name: 'Issue1', description: 'Toller Issue', story_points: '1', type: 'UserStory', project_id: project.id } }}

      before :each do
        Issue.stub(:children_type_names).and_return(['UserStory', 'Task', 'Bug', 'Document'])
      end

      it 'assigns the requested issue as @issue' do
        put :update, valid_params

        expect(assigns(:issue)).to eq(issue)
      end

      it 'updates the requested issue' do
        is = Issue.new
        Issue.stub(:find).and_return(is)

        expect(is).to receive(:update).with('name' => 'IssueX')

        put :update, id: 42, user_story: { 'name' => 'IssueX' }
      end

      it 'displays a success message' do
        put :update, valid_params

        expect(flash[:notice]).to eq(I18n.t('issue.successful_edited'))
      end

      if feature_active? :temp_changes_for_iso
        context 'given the current page is new_issues view' do
          it 'redirects to the new_issues_path' do
            issue.backlog = Backlog.new_issues_list
            issue.save!

            put :update, valid_params

            expect(response).to redirect_to(new_issues_path)
          end
        end

        context 'given the current page is issues view' do
          it 'redirects to the issues_path' do
            put :update, valid_params

            expect(response).to redirect_to(issues_path)
          end
        end
      else
        it 'redirects to the issues_path' do
          put :update, valid_params

          expect(response).to redirect_to(issues_path)
        end
      end
    end

    context 'given invalid params' do
      let(:invalid_params) {{ :id => issue.id, :user_story => { name: nil } }}

      it 'calls prepare_form' do
        expect(controller).to receive(:prepare_form)

        put :update, invalid_params
      end

      it 're-renders the edit view' do
        put :update, invalid_params

        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    let(:issue) { create :user_story, backlog: Backlog.sprint_backlog }

    before :each do
      Issue.stub(:find => issue)
    end

    it 'calls destroy on the issue' do
      expect(issue).to receive(:destroy)

      delete :destroy, id: 42
    end

    if feature_active? :temp_changes_for_iso
      it 'displays a success message' do
        delete :destroy, id: issue.id

        expect(flash[:notice]).to eq(I18n.t('issue.successful_deleted'))
      end

      context 'given the current page is new_issues view' do
        it 'redirects to the new_issues_path' do
          issue.backlog = Backlog.new_issues_list
          issue.save!

          delete :destroy, id: issue.id

          expect(response).to redirect_to(new_issues_path)
        end
      end

      context 'given the current page is issues view' do
        it 'redirects to the issues_path' do
          delete :destroy, id: issue.id

          expect(response).to redirect_to(issues_path)
        end
      end
    else
      it 'redirects to the issues_path' do
        delete :destroy, id: issue.id

        expect(response).to redirect_to(issues_path)
      end
    end
  end

  describe '#change_list' do
    let(:issue) { create :user_story, backlog: backlog }
    # move to sprint backlog
    let(:params) {{ :moved_issue => issue.id, :lock_versions => { '2' => '3' }, :issue => {} , :backlog => 'sprint_backlog' }}

    before :each do
      Issue.stub(:find => issue)
      Backlog.stub(:find_by => sprint_backlog)
    end

    context 'given no predecssor' do
      it 'calls move to on the requested issue with backlog as parameter' do
        expect(issue).to receive(:move_to).with(sprint_backlog)

        post :change_list, params
      end
    end

    it 'sets ready_to_finish to false' do
      post :change_list, params

      expect(issue.ready_to_finish).to be_false
    end

    it 'calls save on the issue' do
      expect(issue).to receive(:save)

      post :change_list, params
    end
  end

  describe '#finish_issue' do
    let(:issue) { create :task, backlog: sprint_backlog }

    before :each do
      Issue.stub(:find => issue)
    end

    it 'assigns the requested issue as @issue' do
      post :finish_issue, id: issue.id

      expect(assigns(:issue)).to eq(issue)
    end

    it 'calls finish on the issue' do
      expect(issue).to receive(:finish)

      post :finish_issue, id: issue.id
    end

    it 'calls save on the issue' do
      expect(issue).to receive(:save)

      post :finish_issue, id: issue.id
    end

    it 'redirects to issues_path' do
      post :finish_issue, id: issue.id

      expect(response).to redirect_to(issues_path)
    end
  end

  describe '#finished_issues_list' do
    it 'assigns all finished issues (sorted) to @finish_issues' do
      issue = create :user_story, backlog: finished_backlog
      controller.stub(:sorted_list).and_return([issue])

      get :finished_issues_list

      expect(assigns(:finished_issues)).to eq([issue])
    end
  end

  feature_active? :temp_changes_for_iso do
    describe '#new_issues_list' do
      it 'assigns all new issues (sorted) to @new_issues' do
        issue = create :user_story, backlog: new_issues
        controller.stub(:sorted_list).and_return([issue])

        get :new_issues_list

        expect(assigns(:new_issues)).to eq([issue])
      end

      it 'assigns all backlog issues (sorted) to @backlog_issues' do
        issue = create :user_story, backlog: backlog
        controller.stub(:sorted_list).and_return([issue])

        get :new_issues_list

        expect(assigns(:backlog_issues)).to eq([issue])
      end

      it 'calls extension_whitelist' do
        issue = create :user_story, backlog: backlog
        controller.stub(:sorted_list).and_return([issue])

        expect(controller).to receive(:extension_whitelist)

        get :new_issues_list
      end
    end

    describe '#show' do
      let(:issue) { create :task, backlog: sprint_backlog }

      it 'assigns the requested issue as @issue' do
        get :show, id: issue.id

        expect(assigns(:issue)).to eq(issue)
      end

      it 'renders the show view' do
        get :show, id: issue.id

        expect(response).to render_template(:show)
      end
    end
  end

  describe '#activate_issue' do
    let(:issue) { create :task, backlog: finished_backlog }

    before :each do
      Issue.stub(:find => issue)
    end

    it 'assigns the requested issues as @issue' do
      post :activate_issue, id: issue.id

      expect(assigns(:issue)).to eq(issue)
    end

    it 'calls activate on the issue' do
      expect(issue).to receive(:activate)

      post :activate_issue, id: issue.id
    end

    it 'redirects to the finished_issues_path' do
      post :activate_issue, id: issue.id

      expect(response).to redirect_to(finished_issues_path)
    end

    context 'given only one issue finished' do
      it 'redirects to finished_issues_path' do
        post :activate_issue, id: issue.id

        expect(response).to redirect_to(finished_issues_path)
      end
    end

    context 'given there are two finished issues' do
      let(:issue1) { create :task, backlog: finished_backlog }

      it 'redirect to finished_issues_path when activating the first' do
        post :activate_issue, id: issue

        expect(response).to redirect_to(finished_issues_path)
      end

      it 'redirect to finished_issues_path when activating the second' do
        post :activate_issue, id: issue1

        expect(response).to redirect_to(finished_issues_path)
      end
    end
  end

  describe '#status_handler' do
    let(:issue) { create :task, backlog: sprint_backlog }

    before :each do
      Issue.stub(:find => issue)
    end

    it 'calls done? on the issue' do
      expect(issue).to receive(:done?)

      put :status_handler, id: issue.id
    end

    it 'redirects to issues_path' do
      put :status_handler, id: issue.id

      expect(response).to redirect_to(issues_path)
    end

    context 'given an issue with ready_to_finish = true' do
      it 'calls doing! on the issue' do
        issue.stub(:done? => true)

        expect(issue).to receive(:doing!)

        put :status_handler, id: issue.id
      end
    end

    context 'given an issue with ready_to_finish = false' do
      it 'calls done! on the issue' do
        issue.stub(:done? => false)

        expect(issue).to receive(:done!)

        put :status_handler, id: issue.id
      end
    end
  end
end