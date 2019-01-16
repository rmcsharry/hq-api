# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Quill::Delta, type: :util do
  def normalize_xml(xml_string)
    Nokogiri::XML.parse("<w>#{xml_string}<\w>", &:noblanks).to_s
  end

  describe 'delta string parsing' do
    it 'handles malformed delta strings' do
      delta = Quill::Delta.new 'this is not a quill delta'

      expect(delta.to_s).to eq 'this is not a quill delta'
    end

    it 'handles bold-attribute and removes trailing newline' do
      delta = Quill::Delta.new <<-QUILL.squish
        {
          "ops": [
            { "insert": "Quill\\n" }
          ]
        }
      QUILL

      expect(normalize_xml(delta.to_s)).to eq normalize_xml <<-EXPECTATION.squish
        <w:p>
          <w:r>
            <w:t xml:space=\"preserve\">Quill</w:t>
          </w:r>
        </w:p>
      EXPECTATION
    end

    it 'handles bold-attribute' do
      delta = Quill::Delta.new <<-QUILL.squish
        {
          "ops": [
            { "insert": "Quill\\n", "attributes": { "bold": true } }
          ]
        }
      QUILL

      expect(normalize_xml(delta.to_s)).to eq normalize_xml <<-EXPECTATION.squish
        <w:p>
          <w:r>
            <w:rPr>
              <w:b/>
            </w:rPr>
            <w:t xml:space=\"preserve\">Quill</w:t>
          </w:r>
        </w:p>
      EXPECTATION
    end

    it 'handles italic-attribute' do
      delta = Quill::Delta.new <<-QUILL.squish
        {
          "ops": [
            { "insert": "Quill\\n", "attributes": { "italic": true } }
          ]
        }
      QUILL

      expect(normalize_xml(delta.to_s)).to eq normalize_xml <<-EXPECTATION.squish
        <w:p>
          <w:r>
            <w:rPr>
              <w:i/>
            </w:rPr>
            <w:t xml:space=\"preserve\">Quill</w:t>
          </w:r>
        </w:p>
      EXPECTATION
    end

    it 'handles disabled attributes' do
      delta = Quill::Delta.new <<-QUILL.squish
        {
          "ops": [
            { "insert": "Quill\\n", "attributes": { "bold": true, "italic": false } }
          ]
        }
      QUILL

      expect(normalize_xml(delta.to_s)).to eq normalize_xml <<-EXPECTATION.squish
        <w:p>
          <w:r>
            <w:rPr>
              <w:b/>
            </w:rPr>
            <w:t xml:space=\"preserve\">Quill</w:t>
          </w:r>
        </w:p>
      EXPECTATION
    end

    it 'handles multiple attributes' do
      delta = Quill::Delta.new <<-QUILL.squish
        {
          "ops": [
            { "insert": "Quill\\n", "attributes": { "bold": true, "italic": true } }
          ]
        }
      QUILL

      expect(normalize_xml(delta.to_s)).to eq normalize_xml <<-EXPECTATION.squish
        <w:p>
          <w:r>
            <w:rPr>
              <w:b/>
              <w:i/>
            </w:rPr>
            <w:t xml:space=\"preserve\">Quill</w:t>
          </w:r>
        </w:p>
      EXPECTATION
    end

    it 'handles bullet lists' do
      delta = Quill::Delta.new <<-QUILL.squish
        {
          "ops": [
            { "insert": "Quill", "attributes": { "italic": true } },
            { "insert": " text\\nlist" },
            { "insert": " entry", "attributes": { "bold": true } },
            { "insert": "\\n", "attributes": { "list": "bullet" } },
            { "insert": "the end\\n" }
          ]
        }
      QUILL

      expect(normalize_xml(delta.to_s)).to eq normalize_xml <<-EXPECTATION.squish
        <w:p>
          <w:r>
            <w:rPr>
              <w:i/>
            </w:rPr>
            <w:t xml:space=\"preserve\">Quill</w:t>
          </w:r>
          <w:r>
            <w:t xml:space=\"preserve\"> text</w:t>
          </w:r>
        </w:p>
        <w:p>
          <w:pPr>
            <w:numPr>
              <w:ilvl w:val="0"/>
              <w:numId w:val="1"/>
            </w:numPr>
          </w:pPr>
          <w:r>
            <w:t xml:space=\"preserve\">list</w:t>
          </w:r>
          <w:r>
            <w:rPr>
              <w:b/>
            </w:rPr>
            <w:t xml:space=\"preserve\"> entry</w:t>
          </w:r>
        </w:p>
        <w:p>
          <w:r>
            <w:t xml:space=\"preserve\">the end</w:t>
          </w:r>
        </w:p>
      EXPECTATION
    end

    it 'handles new-lines before bullet lists' do
      delta = Quill::Delta.new <<-QUILL.squish
        {
          "ops": [
            { "insert": "Test\\n\\n" },
            { "attributes": { "italic": true, "bold": true }, "insert": "Test" },
            { "insert": " " },
            { "attributes": { "italic": true }, "insert": "Nummer" },
            { "insert": " " },
            { "attributes": { "bold": true }, "insert": "Zwei" },
            { "insert": "\\n\\n" },
            { "attributes": { "bold": true }, "insert": "Punkt 1" },
            { "attributes": { "list": "bullet" }, "insert": "\\n" },
            { "insert": "Punkt 2" },
            { "attributes": { "list": "bullet" }, "insert": "\\n" },
            { "attributes": { "italic": true }, "insert": "Punkt 3" },
            { "attributes": { "list": "bullet" }, "insert": "\\n" }
          ]
        }
      QUILL

      expect(normalize_xml(delta.to_s)).to eq normalize_xml <<-EXPECTATION.squish
        <w:p>
          <w:r>
            <w:t xml:space=\"preserve\">Test</w:t>
          </w:r>
        </w:p>
        <w:p></w:p>
        <w:p>
          <w:r>
            <w:rPr>
              <w:i/>
              <w:b/>
            </w:rPr>
            <w:t xml:space=\"preserve\">Test</w:t>
          </w:r>
          <w:r>
            <w:t xml:space=\"preserve\"> </w:t>
          </w:r>
          <w:r>
            <w:rPr>
              <w:i/>
            </w:rPr>
            <w:t xml:space=\"preserve\">Nummer</w:t>
          </w:r>
          <w:r>
            <w:t xml:space=\"preserve\"> </w:t>
          </w:r>
          <w:r>
            <w:rPr>
              <w:b/>
            </w:rPr>
            <w:t xml:space=\"preserve\">Zwei</w:t>
          </w:r>
        </w:p>
        <w:p></w:p>
        <w:p>
          <w:pPr>
            <w:numPr>
              <w:ilvl w:val="0"/>
              <w:numId w:val="1"/>
            </w:numPr>
          </w:pPr>
          <w:r>
            <w:rPr>
              <w:b/>
            </w:rPr>
            <w:t xml:space=\"preserve\">Punkt 1</w:t>
          </w:r>
        </w:p>
        <w:p>
          <w:pPr>
            <w:numPr>
              <w:ilvl w:val="0"/>
              <w:numId w:val="1"/>
            </w:numPr>
          </w:pPr>
          <w:r>
            <w:t xml:space=\"preserve\">Punkt 2</w:t>
          </w:r>
        </w:p>
        <w:p>
          <w:pPr>
            <w:numPr>
              <w:ilvl w:val="0"/>
              <w:numId w:val="1"/>
            </w:numPr>
          </w:pPr>
          <w:r>
            <w:rPr>
              <w:i/>
            </w:rPr>
            <w:t xml:space=\"preserve\">Punkt 3</w:t>
          </w:r>
        </w:p>
      EXPECTATION
    end
  end
end
