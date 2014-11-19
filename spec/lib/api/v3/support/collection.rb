#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

shared_examples_for 'collection' do |total, count, self_link, decorator = nil|
  it { expect(collection).to be_json_eql('Collection'.to_json).at_path('_type') }

  describe 'decorator' do
    let(:collected_class) {
      described_class.to_s.gsub(/(?<class>\w*)Collection/, '\k<class>').constantize
    }
    let(:expected_decorator) { decorator || collected_class }
    let(:actual_decorator) { representer.instance_variable_get(:@decorator) }

    it { expect(actual_decorator).to be(expected_decorator) }
  end

  describe 'quantities' do
    it { expect(collection).to be_json_eql(total.to_json).at_path('total') }

    it { expect(collection).to be_json_eql(count.to_json).at_path('count') }

    it { expect(collection).to have_json_size(count).at_path('_embedded/elements') }
  end

  describe '_links' do
    let(:href) { "/api/v3/#{self_link}".to_json }

    it { expect(collection).to be_json_eql(href).at_path('_links/self/href') }
  end
end
