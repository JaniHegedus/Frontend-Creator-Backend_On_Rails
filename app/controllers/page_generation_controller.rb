require_relative '../Components/file_reader'
require_relative '../models/page_gen_by_image'
class PageGenerationController < ApplicationController
  def initialize
    @openai_api_key = Rails.application.credentials.openai_api_key

  end
  def create
    project = params[:Project] ? JSON.parse(params[:Project]) : {}
    pages = params[:Pages].to_i
    images = params[:Images] ? JSON.parse(params[:Images]) : {}
    languages = params[:Languages] ? JSON.parse(params[:Languages]) : {}
    username = params[:username]
    @page_gen = PageGenByImage.new(
      api_key: @openai_api_key,
      images: images,
      username: username,
      project: project,
      pages: pages,
      languages: languages
    )
    render json: { status: 'success', message: 'Generation created successfully' }, status: :ok
  rescue => e
    render json: { status: 'error', message: e.message }, status: :unprocessable_entity
  end
end
