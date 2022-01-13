class SinglePagesController < ApplicationController
  include Seek::AssetsCommon
  before_action :set_up_instance_variable
  before_action :single_page_enabled
  respond_to :html, :js
  
  def show
    @project = Project.find(params[:id])
    @folders = project_folders

    respond_to do |format|
      format.html
    end
  end
  
  def index
  end

  def single_page_enabled
    unless Seek::Config.project_single_page_enabled
      flash[:error]="Not available"
      redirect_to Project.find(params[:id])
    end
  end

  def project_folders
    project_folders =  ProjectFolder.root_folders(@project)
    if project_folders.empty?
      project_folders = ProjectFolder.initialize_default_folders(@project)
      ProjectFolderAsset.assign_existing_assets @project
    end
    project_folders
  end

  def ontology
    begin
      labels = (SampleControlledVocab.find(params[:sample_controlled_vocab_id])
      &.sample_controlled_vocab_terms || [])
      .where("LOWER(label) like :query", query: "%#{params[:query].downcase}%")
      .select("label").limit(params[:limit] || 100)
      render json: { status: :ok, data: labels }
    rescue Exception => e
      render json: {status: :unprocessable_entity, error: e.message } 
    end
  end

  def dynamic_table_data
    begin
      data = []
      if (params[:sample_type_id])
        sample_type = SampleType.find(params[:sample_type_id]) if params[:sample_type_id]
        data = helpers.dt_data(sample_type)[:rows]
      elsif (params[:study_id])
        study = Study.find(params[:study_id]) if params[:study_id]
        assay = Assay.find(params[:assay_id]) if params[:assay_id]
        data = helpers.dt_aggregated(study, params[:include_all_assays], assay)[:rows]
      end
      data = data.map {|row| row.unshift("")} if params[:rows_pad]
      render json: { data: data }
    rescue Exception => e
      render json: {status: :unprocessable_entity, error: e.message } 
    end
  end

  private

  def set_up_instance_variable
    @single_page = true
  end

end