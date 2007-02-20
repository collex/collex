module ExhibitHelper
  def render_panel(pt, mode=:view)
    @mode = mode
    template = ERB.new pt.template
    template.result(binding)
#    render_to_string :inline=>pt.template
    #pt.template
  end
  
  def exhibit_field(name)
    if @mode == :edit
      text_field_tag name
    else
      name
    end
  end
  
  def foo
    span "This is my span"
  end
end
