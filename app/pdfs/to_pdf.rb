# frozen_string_literal: true

class ToPdf < Prawn::Document
  include ActionView::Helpers::NumberHelper

  Prawn::Font::AFM.hide_m17n_warning = true

  def initialize(view, page_layout = :portrait)
    super(page_layout: page_layout)
    @view = view
    font 'Helvetica', size: 10
  end

  def paragraph(text, *args)
    options = args.extract_options!
    options[:align] ||= :left
    options[:style] ||= :normal
    text text, style: options[:style], align: options[:align]
  end

  def field(label, content, *args)
    options = args.extract_options!
    options[:size] ||= 10

    text "<b>#{label}: </b> #{content.presence || '--'}", inline_format: true,
      size: options[:size]
    move_down 5
  end

  # rubocop:disable Rails/FilePath
  def uploaded_file_path(url)
    return url if Rails.env.test?

    File.join(Rails.root, 'public', url)
  end
  # rubocop:enable Rails/FilePath
end
