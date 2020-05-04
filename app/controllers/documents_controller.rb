class DocumentsController < ApplicationController
  def index
    @documents = Document.where(record_id: params[:id], record_klass: params[:klass])
  end

  def new
    @document = Document.new

    if params[:related]
      model, id = params[:related].split(/_(\d+)/)
      if related = model.classify.constantize.my(current_user).find_by_id(id)
        instance_variable_set("@asset", related)
      else
        respond_to_related_not_found(model) && return
      end
    end

    respond_with(@document)
  end

  def create
    @document = Document.new(document_params)
    if document_params[:file].present? && @document.save
      redirect_to redirection_url
    end
  end

  def destroy
    @document = Document.find(params[:id])
    if @document.destroy
      redirect_to redirection_url
    end
  end

  private

  def document_params
    params.require(:document).permit(:record_id, :record_klass, :file, :uploaded_by_id)
  end

  def redirection_url
    self.public_send(@document.record_klass.downcase + "_path", @document.record_id)
  end
end
