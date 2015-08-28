require 'spec_helper'

describe Backlog do
  before :each do
    Backlog.delete_all
  end

  it 'has a valid factory' do
    expect(build :backlog).to be_valid
  end

  describe 'associations' do
    let(:backlog) { Backlog.new }

    it 'responds to issues' do
      expect(backlog).to respond_to(:issues)
    end

    it 'responds to issues=' do
      expect(backlog).to respond_to(:issues=)
    end
  end

  describe '.backlog' do
    it 'returns the first entry of backlogs with name=backlog' do
      backlog = create :backlog

      expect(Backlog.backlog).to eq(backlog)
    end
  end

  describe '.sprint_backlog' do
    it 'returns the first entry of backlogs with name=sprint_backlog' do
      backlog = create :backlog, name: 'sprint_backlog'

      expect(Backlog.sprint_backlog).to eq(backlog)
    end
  end

  describe '.finished_backlog' do
    it 'returns the first entry of backlogs with name=finished_backlog' do
      backlog = create :backlog, name: 'finished_backlog'

      expect(Backlog.finished_backlog).to eq(backlog)
    end
  end

  describe '.finished_backlog' do
    it 'returns the first entry of backlogs with name=new_issues' do
      backlog = create :backlog, name: 'new_issues'

      expect(Backlog.new_issues_list).to eq(backlog)
    end
  end

  describe '#first_issue' do
    let(:backlog) { create :backlog }
    let!(:issue1) { create :issue, backlog: backlog }
    let!(:issue2) { create :issue, backlog: backlog }

    it 'returns the first issue of the list' do
      expect(backlog.first_issue).to eq(issue1)
    end
  end

  describe '#last_issue' do
    let(:backlog) { create :backlog }
    let!(:issue1) { create :issue, backlog: backlog }
    let!(:issue2) { create :issue, backlog: backlog }

    it 'returns the last issue of the list' do
      expect(backlog.last_issue).to eq(issue1)
    end
  end

  describe '#update_with_list' do
    let(:backlog) { create :backlog }
    let(:sprint_backlog) { create :backlog, name: 'sprint_backlog' }
    let(:issue1) { create :task, backlog: backlog }
    let(:issue2) { create :task, backlog: backlog }
    let(:issue3) { create :task, backlog: backlog }
    let(:issue4) { create :task, backlog: sprint_backlog }
    let(:issue5) { create :task, backlog: sprint_backlog }

    it 'moves the third element to the second position within the backlog list' do
      backlog_issue_array = [issue1.id, issue3.id, issue2.id]

      sprint_backlog.update_with_list(backlog_issue_array)

      expect(issue2.reload.predecessor_id).to eq(issue3.id)
      expect(issue3.reload.predecessor_id).to eq(issue1.id)
      expect(issue1.reload.predecessor_id).to be_nil
    end

    it 'moves the second element to the first position within the backlog list' do
      backlog_issue_array = [issue2.id, issue1.id, issue3.id]

      sprint_backlog.update_with_list(backlog_issue_array)

      expect(issue3.reload.predecessor_id).to eq(issue1.id)
      expect(issue1.reload.predecessor_id).to eq(issue2.id)
      expect(issue2.reload.predecessor_id).to be_nil
    end

    it 'moves the first element to the last position within the backlog list' do
      backlog_issue_array = [issue2.id, issue3.id, issue1.id]

      sprint_backlog.update_with_list(backlog_issue_array)

      expect(issue1.reload.predecessor_id).to eq(issue3.id)
      expect(issue3.reload.predecessor_id).to eq(issue2.id)
      expect(issue2.reload.predecessor_id).to be_nil
    end

    it 'moves the third element to the first position within the sprint backlog list' do
      issue1.update(backlog: sprint_backlog)
      issue2.update(backlog: sprint_backlog)
      issue3.update(backlog: sprint_backlog)

      sprint_backlog_issue_array = [issue3.id, issue1.id, issue2.id]

      sprint_backlog.update_with_list(sprint_backlog_issue_array)

      expect(issue2.reload.predecessor_id).to eq(issue1.id)
      expect(issue1.reload.predecessor_id).to eq(issue3.id)
      expect(issue3.reload.predecessor_id).to be_nil
    end

    it 'moves the third element to the first position and change the second position with the third position within the sprint backlog list' do
      issue1.update(backlog: sprint_backlog)
      issue2.update(backlog: sprint_backlog)
      issue3.update(backlog: sprint_backlog)

      sprint_backlog_issue_array = [issue3.id, issue2.id, issue1.id]

      sprint_backlog.update_with_list(sprint_backlog_issue_array)

      expect(issue1.reload.predecessor_id).to eq(issue2.id)
      expect(issue2.reload.predecessor_id).to eq(issue3.id)
      expect(issue3.reload.predecessor_id).to be_nil
    end

    it 'moves the third element of the backlog list to the second position of the sprint backlog list' do
      # should move issue3 to the sprint backlog list
      issue3.backlog = sprint_backlog
      issue3.predecessor_id = issue4.id
      issue3.save

      sprint_backlog_issue_array = [issue4.id, issue3.id, issue5.id]
      backlog_issue_array = [issue1.id, issue2.id]

      sprint_backlog.update_with_list(sprint_backlog_issue_array)
      backlog.update_with_list(backlog_issue_array)

      expect(issue2.reload.predecessor_id).to eq(issue1.id)
      expect(issue1.reload.predecessor_id).to be_nil

      expect(issue5.reload.predecessor_id).to eq(issue3.id)
      expect(issue3.reload.predecessor_id).to eq(issue4.id)
      expect(issue4.reload.predecessor_id).to be_nil
    end

    it 'moves the last element of the sprint backlog list to the first position of the backlog list' do
      # should move issue5 to the backlog list
      issue5.backlog = backlog
      issue5.predecessor_id = nil
      issue5.save

      sprint_backlog_issue_array = [issue4.id]
      backlog_issue_array = [issue5.id, issue1.id, issue2.id, issue3.id]

      sprint_backlog.update_with_list(sprint_backlog_issue_array)
      backlog.update_with_list(backlog_issue_array)

      expect(issue3.reload.predecessor_id).to eq(issue2.id)
      expect(issue2.reload.predecessor_id).to eq(issue1.id)
      expect(issue1.reload.predecessor_id).to eq(issue5.id)
      expect(issue5.reload.predecessor_id).to be_nil
      expect(issue4.reload.predecessor_id).to be_nil
    end

    it 'moves the last element of the sprint backlog list to the second position of the backlog list and than the first' +
      'element of the sprint backlog list to the 4th position of the backlog list' do
      # should move issue5 on the second poition of the backlog list
      issue5.backlog = @backlog
      issue5.predecessor_id = issue1.id
      issue5.save

      sprint_backlog_issue_array = [issue4.id]
      backlog_issue_array = [issue1.id, issue5.id, issue2.id, issue3.id]

      sprint_backlog.update_with_list(sprint_backlog_issue_array)
      backlog.update_with_list(backlog_issue_array)

      expect(issue3.reload.predecessor_id).to eq(issue2.id)
      expect(issue2.reload.predecessor_id).to eq(issue5.id)
      expect(issue5.reload.predecessor_id).to eq(issue1.id)
      expect(issue1.reload.predecessor_id).to be_nil
      expect(issue4.reload.predecessor_id).to be_nil

      # should move issue4 on the 4th poition of the backlog list => sprint backlog list should be empty
      issue4.backlog = backlog
      issue4.predecessor_id = issue2.id
      issue4.save

      backlog_issue_array = [issue1.id, issue5.id, issue2.id, issue4.id, issue3.id]

      backlog.update_with_list(backlog_issue_array)

      expect(issue3.reload.predecessor_id).to eq(issue4.id)
      expect(issue4.reload.predecessor_id).to eq(issue2.id)
      expect(issue2.reload.predecessor_id).to eq(issue5.id)
      expect(issue5.reload.predecessor_id).to eq(issue1.id)
      expect(issue1.reload.predecessor_id).to be_nil

      expect(Backlog.sprint_backlog.issues.count).to eq(0)
    end

    it 'moves the last element of the backlog list to the second position of the sprint backlog list and than the first' +
      'element of the backlog list to the last position of the sprint backlog list' do
      # should move issue2 on the second position of the sprint backlog list
      issue2.backlog = sprint_backlog
      issue2.predecessor_id = issue3.id
      issue2.save

      sprint_backlog_issue_array = [issue3.id, issue2.id, issue4.id]
      backlog_issue_array = [issue1.id]

      sprint_backlog.update_with_list(sprint_backlog_issue_array)
      backlog.update_with_list(backlog_issue_array)

      expect(issue1.reload.predecessor_id).to be_nil
      expect(issue4.reload.predecessor_id).to eq(issue2.id)
      expect(issue2.reload.predecessor_id).to eq(issue3.id)
      expect(issue3.reload.predecessor_id).to be_nil

      # should move issue1 to the last position of the sprint backlog list => backlog list should be empty
      issue1.backlog = sprint_backlog
      issue1.predecessor_id = issue4.id
      issue1.save

      sprint_backlog_issue_array = [issue3.id, issue2.id, issue4.id, issue1.id]

      sprint_backlog.update_with_list(sprint_backlog_issue_array)

      expect(issue1.reload.predecessor_id).to eq(issue4.id)
      expect(issue4.reload.predecessor_id).to eq(issue2.id)
      expect(issue2.reload.predecessor_id).to eq(issue3.id)
      expect(issue3.reload.predecessor_id).to be_nil

      backlog_issue_array = Backlog.backlog.issues
      expect(backlog_issue_array.length).to eq(0)
    end
  end
end
