require 'spec_helper'

describe Issue do
  describe '#close_gap' do
    it 'should delete an issue and close the gap if the first issue of the list is deleted' do 
      issue3 = Factory.create :issue, type: "Task"
      issue2 = Factory.create :issue, type: "Task"
      issue1 = Factory.create :issue, type: "Task"
      
      issue1.reload.destroy
      
      issue3.reload.predecessor_id.should == issue2.id
      issue2.reload.predecessor_id.should be_nil
      Issue.exists?(issue1).should be_false
    end

    it 'should delete an issue and close the gap if the last issue of the list is deleted' do 
      issue3 = Factory.create :issue, type: "Task"
      issue2 = Factory.create :issue, type: "Task"
      issue1 = Factory.create :issue, type: "Task"
      
      issue3.reload.destroy
      
      issue1.reload.predecessor_id.should be_nil
      issue2.reload.predecessor_id.should == issue1.id
      Issue.exists?(issue3).should be_false
    end

    it 'should delete an issue and close the gap if an issue from the middle of the list is deleted' do 
      issue3 = Factory.create :issue, type: "Task"
      issue2 = Factory.create :issue, type: "Task"
      issue1 = Factory.create :issue, type: "Task"
      
      issue2.reload.destroy
      
      issue1.reload.predecessor_id.should be_nil
      issue3.reload.predecessor_id.should == issue1.id
      Issue.exists?(issue2).should be_false
    end
  end
  
  describe '#update_lists' do
    it 'should move an issue from the backlog to the sprint list' do 
      issue3 = Factory.create :issue, type: "Task"
      issue2 = Factory.create :issue, type: "Task", sprint_flag: "true"
      issue1 = Factory.create :issue, type: "Task"
      issue_array = Issue.in_sprint
      issue_array[0].sprint_flag.should be_true
    end
    
    it 'should move an issue from the sprint to the backlog list' do
      issue3 = Factory.create :issue, type: "Task"
      issue2 = Factory.create :issue, type: "Task", sprint_flag: "true"
      issue1 = Factory.create :issue, type: "Task", sprint_flag: "true"
      issue_array = Issue.in_backlog
      issue_array[0].sprint_flag.should be_false
    end
  end
end
