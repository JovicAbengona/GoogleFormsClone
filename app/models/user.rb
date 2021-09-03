class User < ApplicationRecord
  include ::QueryHelper

  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEX }
  validates :password, presence: true, length: { minimum: 8 }, confirmation: { case_sensitive: true }

  def self.get_user(user_id)
    query_record(["SELECT id, first_name, last_name, email FROM users WHERE id = ?", user_id])
  end

  def self.login(login_params)
    user_data = query_record(["SELECT id, first_name, last_name, email 
                                FROM users 
                                WHERE email = ? AND password = MD5(?)", 
                                login_params[:email].downcase, 
                                login_params[:password]])
                                
    user_data = user_data["id"] if user_data.present?
    
    if user_data
      status = true
    else
      status = false
    end

    return { :status => status, :user_data => user_data }
  end

  def self.validate_signup(signup_params)
    errors = nil
    user_data = nil

    signup_data = User.new(
      :first_name            => signup_params[:first_name],
      :last_name             => signup_params[:last_name],
      :email                 => signup_params[:email],
      :password              => signup_params[:password],
      :password_confirmation => signup_params[:password_confirmation]
    )

    status = signup_data.valid?

    if status
      user_data = insert_record(["INSERT INTO users (first_name, last_name, email, password, created_at, updated_at)
                    VALUES (?, ?, ?, MD5(?), NOW(), NOW())", 
                    signup_params[:first_name],  
                    signup_params[:last_name], 
                    signup_params[:email].downcase, 
                    signup_params[:password]])

      status = true if user_data
    else
      errors = signup_data.errors.messages
    end

    return { :status => status, :errors => errors, :user_data => user_data }
  end
end
