# ------------------------------------------------------------------------
#     Copyright 2011 Applied Research in Patacriticism and the University of Virginia
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
# ----------------------------------------------------------------------------
module Admin::SetupsHelper
	def setup_table_header(label)
		return content_tag(:tr) do
			content_tag(:td, label, { class: 'heading', colspan: "4" })
		end
	end

	def setup_line(label, field, rec, explanation, example, control = :input)
		typ = field.include?('password') ? 'password' : 'text'
		html = content_tag(:tr, class: 'row') do
			content_tag(:td, label) +
				content_tag(:td) do
					if control == :textarea
						content_tag(control, rec[field], { id: "setups_#{field}", name: "setups[#{field}]" })
					else
						content_tag(control, "", { id: "setups_#{field}", name: "setups[#{field}]", value: rec[field], type: typ })
					end
				end
		end + content_tag(:tr, { class: 'instructions' }) do
			content_tag(:td, explanation) +
			content_tag(:td, example, { style: "vertical-align: top;"})
		end
		return html
  end

  def setup_checkbox(label, field, rec, explanation, example)
    typ = 'checkbox'
    value = 0
    value = 1 if rec[field] == 'true' || rec[field] == 'on'
    html = content_tag(:tr, class: 'row hoverable') do
      content_tag(:td, label) +
          content_tag(:td) do
            if value == 1
              content_tag(:input, "", id: "setups_#{field}", name: "setups[#{field}]", checked: 1, type: typ )
            else
              content_tag(:input, "", id: "setups_#{field}", name: "setups[#{field}]", type: typ )
            end

          end
    end + content_tag(:tr, { class: 'instructions' }) do
      content_tag(:td, explanation) +
          content_tag(:td, example)
    end
    return html
  end

	def setup_table_button(label)
		html = content_tag(:tr, class: 'center') do
			content_tag(:td) +
				content_tag(:td) do
					submit_tag(label)
				end +
				content_tag(:td) +
				content_tag(:td)
		end
		return html
	end
end
