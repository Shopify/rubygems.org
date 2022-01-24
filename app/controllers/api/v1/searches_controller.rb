class Api::V1::SearchesController < Api::BaseController
  before_action :set_page, only: %i[show autocomplete]
  before_action :verify_query_string, only: %i[show autocomplete]

  def show
    @rubygems = ElasticSearcher.new(query_params, page: @page).api_search
    respond_to do |format|
      format.json { render json: @rubygems }
      format.yaml { render yaml: @rubygems }
    end
  end

  def autocomplete
    if params[:user]
      if params[:query].empty?
        results = User.find(params[:user]).rubygems.limit(10).map{|gem| gem.name }
        render json: results
      else
        results = User.find(params[:user]).rubygems.where('name LIKE ?', "%#{params[:query]}%").limit(10).map{|gem| gem.name }
        render json: results
      end
      # results = ElasticSearcher.new(params[:query], page: @page).suggestions
      # render json: results
    else
      results = ElasticSearcher.new(params[:query], page: @page).suggestions
      render json: results
    end
  end

  private

  def verify_query_string
    render plain: "bad request", status: :bad_request unless params[:query].is_a?(String)
  end

  def query_params
    params.require(:query)
  end
end
