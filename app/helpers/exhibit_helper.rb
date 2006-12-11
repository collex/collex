module ExhibitHelper
  def render_panel(pt)
    render_to_string :inline=>pt.template
  end
end
