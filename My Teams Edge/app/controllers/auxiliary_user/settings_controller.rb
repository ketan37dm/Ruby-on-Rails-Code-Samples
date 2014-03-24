class AuxiliaryUser::SettingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authenticate_auxiliary_user!

  include ControllerHelpers::CommonMethods
end
