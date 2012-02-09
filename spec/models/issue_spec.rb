require 'spec_helper'

describe Issue do
  describe '#pin_after' do

    it 'should move the first element to the third position if id of the third element is given'  do
      issue4 = Factory.create :issue, type: "UserStory"
      issue3 = Factory.create :issue, type: "Task"
      issue2 = Factory.create :issue, type: "Task"
      issue1 = Factory.create :issue, type: "Bug"

      issue1.reload.pin_after issue3.id

      issue2.reload.predecessor_id.should be_nil
      issue3.reload.predecessor_id.should == issue2.id
      issue1.reload.predecessor_id.should == issue3.id
      issue4.reload.predecessor_id.should == issue1.id
    end

    it 'should move the last element to the third position if id of the third element is given'  do
      issue4 = Factory.create :issue, type: "UserStory"
      issue3 = Factory.create :issue, type: "Task"
      issue2 = Factory.create :issue, type: "Task"
      issue1 = Factory.create :issue, type: "Bug"

      issue4.reload.pin_after issue2.id

      issue1.reload.predecessor_id.should be_nil
      issue2.reload.predecessor_id.should == issue1.id
      issue4.reload.predecessor_id.should == issue2.id
      issue3.reload.predecessor_id.should == issue4.id
    end

    it 'should move the third element to the second position if id of the second element is given'  do
      issue4 = Factory.create :issue, type: "UserStory"
      issue3 = Factory.create :issue, type: "Task"
      issue2 = Factory.create :issue, type: "Task"
      issue1 = Factory.create :issue, type: "Bug"

      issue3.reload.pin_after issue1.id

      issue1.reload.predecessor_id.should be_nil
      issue3.reload.predecessor_id.should == issue1.id
      issue2.reload.predecessor_id.should == issue3.id
      issue4.reload.predecessor_id.should == issue2.id
    end

    it 'should move the first element to the last position if id of the last element is given' do
      issue4 = Factory.create :issue, type: "UserStory"
      issue3 = Factory.create :issue, type: "Task"
      issue2 = Factory.create :issue, type: "Task"
      issue1 = Factory.create :issue, type: "Bug"

      issue1.reload.pin_after issue4.id

      issue2.reload.predecessor_id.should be_nil
      issue3.reload.predecessor_id.should == issue2.id
      issue4.reload.predecessor_id.should == issue3.id
      issue1.reload.predecessor_id.should == issue4.id
    end

    it 'should move the last element to the first position if id of the first element is given' do
      issue4 = Factory.create :issue, type: "UserStory"
      issue3 = Factory.create :issue, type: "Task"
      issue2 = Factory.create :issue, type: "Task"
      issue1 = Factory.create :issue, type: "Bug"

      issue4.reload.pin_after nil

      issue4.reload.predecessor_id.should be_nil
      issue1.reload.predecessor_id.should == issue4.id
      issue2.reload.predecessor_id.should == issue1.id
      issue3.reload.predecessor_id.should == issue2.id
    end
  end
  
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
end
