module ApplicationHelper
  include Pagy::Frontend

  def render_turbo_stream_flash_messages
    turbo_stream.prepend 'flash', partial: 'layouts/flash'
  end

  def inline_error_for(field, form_obj)
    html = []
    if form_obj.errors[field].any?
      html << form_obj.errors[field].map do |msg|
        tag.div(msg, class: 'text-danger m-0 p-0 text-sm-end position-fixed')
      end
    end
    html.join.html_safe # rubocop:disable Rails/OutputSafety
  end
end
