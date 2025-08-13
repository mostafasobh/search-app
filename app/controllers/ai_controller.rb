class AiController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :chat ]
  def chat
    service = OpenaiHtmlPromptService.new(
      user_prompt: params[:user_prompt],
      html_fragment: params[:html_fragment],
      url: params[:url]
    )
    res = service.call
    p res
    render json: res
    # render json: {
    #   user_prompt: params[:user_prompt],
    #   html_fragment: params[:html_fragment],
    #   url: params[:url]
    # }
  end
end
