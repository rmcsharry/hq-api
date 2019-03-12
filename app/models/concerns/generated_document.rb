# frozen_string_literal: true

# Concern to add boilerplate methods for documents generated from templates
module GeneratedDocument
  extend ActiveSupport::Concern

  def find_or_create_document(document_category:, template:, template_context:, uploader:, name:)
    document = documents.find_by(type: 'Document::GeneratedDocument', category: document_category)
    return document unless document.nil?

    file, content_type = apply_template(template, template_context)
    persist_document(uploader, file, content_type, document_category, name)
  end

  private

  def apply_template(template, context)
    if Docx.docx?(template.file)
      [generate_docx_document(template, context), Docx::MIME_TYPE]
    else
      [template.file.download, template.file.content_type]
    end
  end

  def persist_document(uploader, file, content_type, category, name)
    document = Document::GeneratedDocument.create(category: category, name: name, uploader: uploader)
    document.file.attach(content_type: content_type, filename: name, io: StringIO.new(file))
    documents << document
    document
  end

  def generate_docx_document(template, context)
    template_path = load_template(template).path
    document = Docx::Document.new(template_path)
    document.commit(context)
    document.render
  end

  def load_template(template)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write template.file.download
    tempfile.close
    tempfile
  end
end
