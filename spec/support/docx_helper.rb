# frozen_string_literal: true

def docx_document_content(file_content)
  tempfile = Tempfile.new
  tempfile.binmode
  tempfile.write file_content
  docx_document = Docx::Document.new(tempfile) unless File.zero?(tempfile)
  tempfile.close
  docx_document.to_s
end
