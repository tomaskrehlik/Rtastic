class PackagesController < ApplicationController
  def overview
  end

  def actions
  end

  def log
  end
  
  def update
  end
  
  def init
  end
  
  def show
    @package = Package.find_by_name(params[:id])
  end

  def documentation
    if params[:function].nil? then
      @package = Package.find_by_name(params[:name].to_s)
      @function = "index"
    else
      @package = Package.find_by_name(params[:name].to_s)
      @function = params[:function]
      @documentation = Documentation.find_by_package_and_name(params[:name].to_s, params[:function].to_s)
    end
  end

  def builddocs
    parse_Rd_files(params[:name].to_s)
    redirect_to action: "overview"
  end
end
