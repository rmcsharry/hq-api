# frozen_string_literal: true

module V1
  # Defines the TaskCommentss controller
  class TaskCommentsController < ApplicationController
    before_action :authenticate_user!
  end
end
