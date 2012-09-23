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
    end
  end
end
