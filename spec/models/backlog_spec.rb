require 'spec_helper'

feature_active? :temp_lock_lists do
  describe Backlog do
    before :all do
      @backlog = Backlog.backlog
      @sprint_backlog = Backlog.sprint_backlog
      @finished_backlog = Backlog.finished_backlog
    end

    describe '#update' do
      it 'should move the third element to the second position within the backlog list' do 
        issue3 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue2 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue1 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id

        backlog_issue_array = [issue1.id, issue3.id, issue2.id]

        @sprint_backlog.update_with_list backlog_issue_array

        issue2.reload.predecessor_id.should == issue3.id
        issue3.reload.predecessor_id.should == issue1.id
        issue1.reload.predecessor_id.should be_nil
      end

      it 'should move the second element to the first position within the backlog list' do
        issue3 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue2 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue1 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id

        backlog_issue_array = [issue2.id, issue1.id, issue3.id]

        @sprint_backlog.update_with_list backlog_issue_array

        issue3.reload.predecessor_id.should == issue1.id
        issue1.reload.predecessor_id.should == issue2.id
        issue2.reload.predecessor_id.should be_nil
      end

      it 'should move the first element to the last position within the backlog list' do
        issue3 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue2 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue1 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id

        backlog_issue_array = [issue2.id, issue3.id, issue1.id]

        @sprint_backlog.update_with_list backlog_issue_array

        issue1.reload.predecessor_id.should == issue3.id
        issue3.reload.predecessor_id.should == issue2.id
        issue2.reload.predecessor_id.should be_nil
      end

      it 'should move the third element to the first position within the sprint backlog list' do 
        issue3 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id
        issue2 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id
        issue1 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id

        sprint_backlog_issue_array = [issue3.id, issue1.id, issue2.id]

        @sprint_backlog.update_with_list sprint_backlog_issue_array

        issue2.reload.predecessor_id.should == issue1.id
        issue1.reload.predecessor_id.should == issue3.id
        issue3.reload.predecessor_id.should be_nil
      end

      it 'should move the third element to the first position and change the second position with the third position within the sprint backlog list' do
        issue3 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id
        issue2 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id
        issue1 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id

        sprint_backlog_issue_array = [issue3.id, issue2.id, issue1.id]

        @sprint_backlog.update_with_list sprint_backlog_issue_array

        issue1.reload.predecessor_id.should == issue2.id
        issue2.reload.predecessor_id.should == issue3.id
        issue3.reload.predecessor_id.should be_nil
      end

      it 'should move the third element of the backlog list to the second position of the sprint backlog list' do
        issue5 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id
        issue4 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id

        issue3 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue2 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue1 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id

        # should move issue3 to the sprint backlog list
        issue3.backlog = @sprint_backlog
        issue3.predecessor_id = issue4.id
        issue3.save

        sprint_backlog_issue_array = [issue4.id, issue3.id, issue5.id]
        backlog_issue_array = [issue1.id, issue2.id]

        @sprint_backlog.update_with_list sprint_backlog_issue_array
        @backlog.update_with_list backlog_issue_array

        issue2.reload.predecessor_id.should == issue1.id
        issue1.reload.predecessor_id.should be_nil

        issue5.reload.predecessor_id.should == issue3.id
        issue3.reload.predecessor_id.should == issue4.id
        issue4.reload.predecessor_id.should be_nil
      end

      it 'should move the last element of the sprint backlog list to the first position of the backlog list' do
        issue5 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id
        issue4 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id

        issue3 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue2 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue1 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id

        # should move issue5 to the backlog list
        issue5.backlog = @backlog
        issue5.predecessor_id = nil
        issue5.save

        sprint_backlog_issue_array = [issue4.id]
        backlog_issue_array = [issue5.id, issue1.id, issue2.id, issue3.id]

        @sprint_backlog.update_with_list sprint_backlog_issue_array
        @backlog.update_with_list backlog_issue_array

        issue3.reload.predecessor_id.should == issue2.id
        issue2.reload.predecessor_id.should == issue1.id
        issue1.reload.predecessor_id.should == issue5.id
        issue5.reload.predecessor_id.should be_nil

        issue4.reload.predecessor_id.should be_nil
      end

      it 'should move the last element of the sprint backlog list to the second position of the backlog list and than the first' +
        'element of the sprint backlog list to the 4th position of the backlog list' do
        issue5 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id
        issue4 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id

        issue3 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue2 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue1 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id

        # should move issue5 on the second poition of the backlog list 
        issue5.backlog = @backlog
        issue5.predecessor_id = issue1.id
        issue5.save

        sprint_backlog_issue_array = [issue4.id]
        backlog_issue_array = [issue1.id, issue5.id, issue2.id, issue3.id]

        @sprint_backlog.update_with_list sprint_backlog_issue_array
        @backlog.update_with_list backlog_issue_array

        issue3.reload.predecessor_id.should == issue2.id
        issue2.reload.predecessor_id.should == issue5.id
        issue5.reload.predecessor_id.should == issue1.id
        issue1.reload.predecessor_id.should be_nil

        issue4.reload.predecessor_id.should be_nil

        # should move issue4 on the 4th poition of the backlog list => sprint backlog list should be empty
        issue4.backlog = @backlog
        issue4.predecessor_id = issue2.id
        issue4.save

        backlog_issue_array = [issue1.id, issue5.id, issue2.id, issue4.id, issue3.id]

        @backlog.update_with_list backlog_issue_array

        issue3.reload.predecessor_id.should == issue4.id
        issue4.reload.predecessor_id.should == issue2.id
        issue2.reload.predecessor_id.should == issue5.id
        issue5.reload.predecessor_id.should == issue1.id
        issue1.reload.predecessor_id.should be_nil

        Backlog.sprint_backlog.issues.count.should == 0
        end

      it 'should move the last element of the backlog list to the second position of the sprint backlog list and than the first' +
        'element of the backlog list to the last position of the sprint backlog list' do
        issue4 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id
        issue3 = FactoryGirl.create :issue, type: "Task", backlog_id: @sprint_backlog.id

        issue2 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id
        issue1 = FactoryGirl.create :issue, type: "Task", backlog_id: @backlog.id

        # should move issue2 on the second position of the sprint backlog list
        issue2.backlog = @sprint_backlog
        issue2.predecessor_id = issue3.id
        issue2.save

        sprint_backlog_issue_array = [issue3.id, issue2.id, issue4.id]
        backlog_issue_array = [issue1.id]

        @sprint_backlog.update_with_list sprint_backlog_issue_array
        @backlog.update_with_list backlog_issue_array

        issue1.reload.predecessor_id.should be_nil

        issue4.reload.predecessor_id.should == issue2.id
        issue2.reload.predecessor_id.should == issue3.id
        issue3.reload.predecessor_id.should be_nil

        # should move issue1 to the last position of the sprint backlog list => backlog list should be empty
        issue1.backlog = @sprint_backlog
        issue1.predecessor_id = issue4.id
        issue1.save

        sprint_backlog_issue_array = [issue3.id, issue2.id, issue4.id, issue1.id]

        @sprint_backlog.update_with_list sprint_backlog_issue_array

        issue1.reload.predecessor_id.should == issue4.id
        issue4.reload.predecessor_id.should == issue2.id
        issue2.reload.predecessor_id.should == issue3.id
        issue3.reload.predecessor_id.should be_nil

        if feature_active? :temp_lock_lists
          backlog_issue_array = Backlog.backlog.issues
        else
          backlog_issue_array = Issue.in_backlog
        end      
        backlog_issue_array.length.should == 0
        end
    end
  end
end
