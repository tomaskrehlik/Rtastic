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
end
