class Contact < ActiveRecord::Base
   attr_accessible :name, :email, :message, :subject

   #######################  validations  ####################
   validates :name, :presence => true
   validates :subject, :presence => true
   validates :email, :presence => true, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create }, :allow_blank => true 
   validates :message, :presence => true

   after_save :send_notification

   private
   def send_notification
   	ContactNotification.delay.send_contact_notification(self)
   end
end
