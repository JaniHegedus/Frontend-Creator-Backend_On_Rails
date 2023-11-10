# frozen_string_literal: true
class UserMailer < ApplicationMailer
  default from: 'no-reply@Frontend-Creator.com'

  def password_reset_email
    @user = params[:user]
    @new_password = params[:new_password]

    mail(to: @user.email, subject: 'Your new password')
  end
  def welcome_email
    @user = params[:user]
    @url  = 'http://Frontend-Creator.com/login'
    mail(to: @user.email, subject: 'Welcome to Frontend Creator')
  end
end

