class GeneralController < ApplicationController
  def search
    @q = params[:q]
    @packages = PackagesHelper.search(@q)
    if @packages.length==1 then
      redirect_to "/packages/#{@packages[0].to_s}/"
    end
  end
end
