class ContactsController < ApplicationController

  def new
    @contact = Contact.new
  end

  def create 
    @contact = Contact.new(params[:contact])
    if @contact.valid?
      @contact.save
      redirect_to root_path, :flash => { :success => "Thank you for reaching out. We will contact you shortly." }
    else
      render "new"
    end
  end
end
