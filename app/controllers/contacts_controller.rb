class ContactsController < ApplicationController
  def show
    @contact = Contact.find(params[:id])
  end
end