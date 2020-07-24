module Api
  class ObjectsController < Api::ApplicationController
    before_action :get_model

    TIMESTAMP_COLUMNS = ['created_at', 'updated_at', 'deleted_at'].freeze
    ALLOWED_MODELS = ['Account', 'Contact', 'Lead'].freeze

    def show
      begin
        @object = @model.find(params[:id])

        render json: @object
      rescue => e
        render json: { error: e.message }, status: :bad_request
      end
    end

    def create
      begin
        @object = @model.new(object_params)

        if @model.column_names.include?('user_id')
          @object.user_id = API_USER_ID
        end

        @object.save!
        render json: @object
      rescue => e
        render json: { error: e.message }, status: :bad_request
      end
    end

    private

      def object_params
        params.require(:object).permit(@model.column_names - TIMESTAMP_COLUMNS)
      end

      def get_model
        @model = params[:model].singularize.capitalize.constantize

        raise "#{@model} is not an allowed model" unless ALLOWED_MODELS.include?(@model.to_s)
      end

  end
end
