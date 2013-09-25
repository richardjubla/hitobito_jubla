# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

module Jubla::GroupAbility
  extend ActiveSupport::Concern

  included do
    on(Group) do
      permission(:any).may(:evaluate_census).unless_external

      permission(:layer_full).may(:index_event_course_conditions).in_same_layer_or_below
      permission(:layer_full).may(:remind_census, :approve_population, :create_member_counts).in_same_layer_or_below
      permission(:layer_full).may(:update_member_counts).in_same_layer_or_below_if_ast_or_bulei
    end
  end

  def in_same_layer_or_below_if_ast_or_bulei
    in_same_layer_or_below &&
    user.roles.any? do |r|
      r.kind_of?(Group::StateAgency::Leader) ||
      r.kind_of?(Group::FederalBoard::Member)
    end
  end
end