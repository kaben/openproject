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

require 'securerandom'

module API
  module V3
    module Queries
      class QueriesAPI < Grape::API
        resources :queries do

          params do
            requires :id, desc: 'Query id'
          end
          namespace ':id' do

            before do
              @query = Query.find(params[:id])
              @representer =  ::API::V3::Queries::QueryRepresenter.new(@query)
            end

            helpers do
              def allowed_to_manage_stars?
                # TODO: find a better way
                action = env['api.endpoint'].options[:path].first
                QueryPolicy.new(current_user).allowed?(@query, action)
              end
            end

            patch :star do
              # TODO Replace by QueryPolicy
              authorize({ controller: :queries, action: :star }, context: @query.project, allow: allowed_to_manage_stars?)
              # Query name is not user-visible, but apparently used as CSS class. WTF.
              # Normalizing the query name can result in conflicts and empty names in case all
              # characters are filtered out. A random name doesn't have these problems.
              query_menu_item = MenuItems::QueryMenuItem.find_or_initialize_by_navigatable_id(
                @query.id, name: SecureRandom.uuid, title: @query.name
              )
              query_menu_item.save!
              @representer
            end

            patch :unstar do
              # TODO Replace by QueryPolicy
              authorize({ controller: :queries, action: :unstar }, context: @query.project, allow: allowed_to_manage_stars?)
              query_menu_item = @query.query_menu_item
              return @representer if @query.query_menu_item.nil?
              query_menu_item.destroy
              @query.reload
              @representer
            end
          end

        end
      end
    end
  end
end
