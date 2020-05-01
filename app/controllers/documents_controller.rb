class DocumentsController < ApplicationController
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
    params.require(:document).permit(:record_id, :record_klass, :file)
  end

  def redirection_url
    self.public_send(@document.record_klass.downcase + "_path", @document.record_id)
  end
end
