# frozen_string_literal: true

module Admin
  class OauthApplicationsController < Doorkeeper::ApplicationsController
    layout 'admin/application'
    include ApplicationHelper

    before_action :authenticate_user!
    before_action :require_admin_user

    def index
      @applications = Doorkeeper::Application.all
    end

    def create
      @application = Doorkeeper::Application.new(application_params)
      # System accounts (ownerless) are created by not setting an owner
      # To set an owner, we could add a field in the form, but for now we default to ownerless for system applications created in admin.
      if @application.save
        flash[:notice] = I18n.t('doorkeeper.flash.applications.create.notice')
        redirect_to admin_oauth_application_url(@application)
      else
        render :new
      end
    end

    def update
      if @application.update(application_params)
        flash[:notice] = I18n.t('doorkeeper.flash.applications.update.notice')
        redirect_to admin_oauth_application_url(@application)
      else
        render :edit
      end
    end

    def destroy
      if @application.destroy
        flash[:notice] = I18n.t('doorkeeper.flash.applications.destroy.notice')
      end
      redirect_to admin_oauth_applications_url
    end

    private

    def require_admin_user
      return if current_user.admin?

      flash[:notice] = t(:msg_not_authorized)
      redirect_to root_path
    end
  end
end
