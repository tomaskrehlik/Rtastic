class GeneralController < ApplicationController
  def search
    @q = params[:q]
    @packages = PackagesHelper.search(@q)
    if @packages.length==1 then
      redirect_to "/packages/#{@packages[0].to_s}/"
    end
  end

  def about

  end

  def development_plans
  
  end

  def donate

  end

  def feedback

  end

  def home
    
  end
end
