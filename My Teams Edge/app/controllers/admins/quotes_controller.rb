class Admins::QuotesController < ApplicationController
  before_filter :authenticate_admin!

  def create
  	@form_id = params[:count]
  	@quote = current_admin.quotes.build(params[:quote])
  	if @quote.valid? && @quote.save
  		flash.now.notice = "Quote Saved Successfully."
  	end
  end

  def update
  	@form_id = params[:count]
  	@quote = Quote.find(params[:id])
  	if @quote.valid? && @quote.update_attributes(params[:quote])
  		flash.now.notice = "Quote Updated Successfully."
  	end
  end

end
