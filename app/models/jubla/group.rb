# encoding: utf-8

#  Copyright (c) 2012-2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

module Jubla::Group
  extend ActiveSupport::Concern

  ALUMNI_GROUPS_CLASSES = [Group::AlumnusGroup,
                           Group::StateAlumnusGroup,
                           Group::FederalAlumnusGroup,
                           Group::FlockAlumnusGroup,
                           Group::RegionalAlumnusGroup].freeze

  included do
    class_attribute :contact_group_type

    # Clear class attribute to customize it just for Jubla
    self.protect_if_methods = {}

    protect_if :root?
    protect_if :children_without_deleted_and_alumni_groups

    before_destroy :delete_alumni_groups

    scope :alumni_groups, -> { where(type: ALUMNI_GROUPS_CLASSES) }
    scope :without_alumni_groups, -> { where.not(type: ALUMNI_GROUPS_CLASSES) }

    self.used_attributes += [:bank_account]

    has_many :course_conditions, class_name: '::Event::Course::Condition', dependent: :destroy

    # define global children
    children Group::SimpleGroup

    root_types Group::Federation

    ::Group::MINIMAL_SELECT << 'groups.kind'

    private

    def delete_alumni_groups
      children.where(type: ALUMNI_GROUPS_CLASSES).delete_all
    end
  end

  def alumni_groups
    groups_in_same_layer.where(type: ALUMNI_GROUPS_CLASSES)
  end

  def alumnus?
    is_a?(Group::AlumnusGroup)
  end

  def census?
    respond_to?(:census_total)
  end

  def children_without_deleted_and_alumni_groups
    children.without_deleted.without_alumni_groups
  end

end
