# frozen_string_literal: true

# Concern to add boilerplate methods for documents generated from templates
module GeneratedDocument
  extend ActiveSupport::Concern

  def apply_template_and_persist_document(template:, template_context:, uploader:, document_category:, name:)
    file, content_type = apply_template(template, template_context)
    persist_document(uploader, file, content_type, document_category, name)
  end

  def find_generated_document_by_category(category)
    documents.find_by(type: 'Document::GeneratedDocument', category: category)
  end

  def find_or_create_document(document_category:, template:, template_context:, uploader:, name:)
    document = find_generated_document_by_category(document_category)
    return document unless document.nil?

    apply_template_and_persist_document(
      template: template,
      template_context: template_context,
      uploader: uploader,
      document_category: document_category,
      name: name
    )
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
    tempfile = load_template(template)
    begin
      document = Docx::Document.new(tempfile)
      document.commit(context)
      generated_document = document.render
    ensure
      tempfile.close
      tempfile.unlink
    end
    generated_document
  end

  def load_template(template)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write template.file.download
    tempfile
  end
end
