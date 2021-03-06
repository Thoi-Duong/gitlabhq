require 'spec_helper'

describe TrendingProject do
  let(:user) { create(:user) }
  let(:public_project1) { create(:empty_project, :public) }
  let(:public_project2) { create(:empty_project, :public) }
  let(:public_project3) { create(:empty_project, :public) }
  let(:private_project) { create(:empty_project, :private) }
  let(:internal_project) { create(:empty_project, :internal) }

  before do
    3.times do
      create(:note_on_commit, project: public_project1)
    end

    2.times do
      create(:note_on_commit, project: public_project2)
    end

    create(:note_on_commit, project: public_project3, created_at: 5.weeks.ago)
    create(:note_on_commit, project: private_project)
    create(:note_on_commit, project: internal_project)
  end

  describe '.refresh!' do
    before do
      described_class.refresh!
    end

    it 'populates the trending projects table' do
      expect(described_class.count).to eq(2)
    end

    it 'removes existing rows before populating the table' do
      described_class.refresh!

      expect(described_class.count).to eq(2)
    end

    it 'stores the project IDs for every trending project' do
      rows = described_class.order(id: :asc).all

      expect(rows[0].project_id).to eq(public_project1.id)
      expect(rows[1].project_id).to eq(public_project2.id)
    end

    it 'does not store projects that fall out of the trending time range' do
      expect(described_class.where(project_id: public_project3).any?).to eq(false)
    end

    it 'stores only public projects' do
      expect(described_class.where(project_id: [public_project1.id, public_project2.id]).count).to eq(2)
      expect(described_class.where(project_id: [private_project.id, internal_project.id]).count).to eq(0)
    end
  end
end
