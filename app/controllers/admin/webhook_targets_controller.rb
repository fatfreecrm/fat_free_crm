# frozen_string_literal: true

module Admin
  class WebhookTargetsController < ApplicationController
    before_action :set_webhook_target, only: %i[show edit update destroy]

    def index
      @webhook_targets = WebhookTarget.all
    end

    def show; end

    def new
      @webhook_target = WebhookTarget.new
    end

    def edit; end

    def create
      @webhook_target = WebhookTarget.new(webhook_target_params)

      if @webhook_target.save
        redirect_to admin_webhook_target_path(@webhook_target), notice: 'Webhook target was successfully created.'
      else
        render :new
      end
    end

    def update
      if @webhook_target.update(webhook_target_params)
        redirect_to admin_webhook_target_path(@webhook_target), notice: 'Webhook target was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @webhook_target.destroy
      redirect_to admin_webhook_targets_url, notice: 'Webhook target was successfully destroyed.'
    end

    private

    def set_webhook_target
      @webhook_target = WebhookTarget.find(params[:id])
    end

    def webhook_target_params
      params.require(:webhook_target).permit(:name, :url, :enabled)
    end
  end
end
