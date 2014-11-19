require 'spec_helper'
require 'rack/test'

describe 'API v3 Version resource' do
  include Rack::Test::Methods

  let(:current_user) { FactoryGirl.create(:user) }
  let(:role) { FactoryGirl.create(:role, permissions: []) }
  let(:project) { FactoryGirl.create(:project, is_public: false) }
  let(:versions) { FactoryGirl.create_list(:version, 4, project: project) }
  let(:other_versions) { FactoryGirl.create_list(:version, 2) }

  describe '#get' do
    subject(:response) { last_response }

    context 'logged in user' do
      let(:get_path) { "/api/v3/projects/#{project.id}/versions" }
      before do
        allow(User).to receive(:current).and_return current_user
        member = FactoryGirl.build(:member, user: current_user, project: project)
        member.role_ids = [role.id]
        member.save!

        versions
        other_versions

        get get_path
      end

      it_behaves_like 'collection response', 4, 4
    end
  end
end
