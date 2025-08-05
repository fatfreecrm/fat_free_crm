# frozen_string_literal: true

class Admin::ResearchToolsController < Admin::ApplicationController
  before_action :setup_current_tab, only: %i[index]

  load_resource

  def index
    @research_tools = ResearchTool.all
    respond_with(@research_tools)
  end

  def new
    respond_with(@research_tool)
  end

  def edit
    respond_with(@research_tool)
  end

  def create
    @research_tool.update(research_tool_params)
    respond_with(@research_tool, location: -> { admin_research_tools_path })
  end

  def update
    @research_tool.update(research_tool_params)
    respond_with(@research_tool, location: -> { admin_research_tools_path })
  end

  def destroy
    @research_tool.destroy
    respond_with(@research_tool)
  end

  protected

  def research_tool_params
    params.require(:research_tool).permit(:name, :url_template, :enabled)
  end

  def setup_current_tab
    set_current_tab('admin/research_tools')
  end
end
