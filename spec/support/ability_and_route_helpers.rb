module AbilityAndRouteHelpers
  def add_routes_and_ability_to_view(the_view)
    the_view.extend ::FatFreeCrm::Engine.routes.url_helpers
    the_view.controller.class_eval(<<-RUBYCODE)
      def current_ability
        @current_ability ||= FatFreeCrm::Ability.new(current_user)
      end
    RUBYCODE
    the_view.extend ::FatFreeCrm::ApplicationHelper
  end
end
