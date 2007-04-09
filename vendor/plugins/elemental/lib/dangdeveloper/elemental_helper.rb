module DangDeveloper
  module ElementalHelper
    SELF_CLOSING_TAGS = %w{ base meta link hr br param img area input col }
    XHTMLSTRICT_TAGS = %w{
      html head title base meta link style script noscript body 
      div p ul ol li dl dt dd address hr pre blockquote 
      ins del a span bdo br em strong dfn code samp 
      kbd  var  cite  abbr  acronym  q  sub  sup  tt  i  b  big  small 
      object  param  img  map  area  form  label  input  select  optgroup  option 
      textarea  fieldset  legend  button  table  caption  colgroup  col 
      thead  tfoot  tbody  tr  th  td  h1  h2  h3  h4  h5  h6 
    }
    XHTMLTRANSITIONAL_TAGS = %w{ strike center dir noframes basefont u menu iframe font s applet isindex }
    EXISTING_RAILS_METHODS = %w{ form input select }
    XHTML_CONTENT_TAGS = (XHTMLSTRICT_TAGS + XHTMLTRANSITIONAL_TAGS) - SELF_CLOSING_TAGS - EXISTING_RAILS_METHODS
    
    def self.self_closing_tags
      SELF_CLOSING_TAGS
    end
    
    def self.xhtml_content_tags
      XHTML_CONTENT_TAGS
    end
    
    XHTML_CONTENT_TAGS.each do |element|
      eval("def #{element}(*args, &block); block ? content_tag_block('#{element}', *args, &block) : tag_without_block('#{element}', *args); end") 
    end
    SELF_CLOSING_TAGS.each do |element|
      eval("def #{element}(options={}); tag('#{element}', options, false); end")
    end
    def content_tag_block(tag_name, *args, &block)
      options = args.first.is_a?(Hash) ? args.shift : {}
      concat content_tag(tag_name, capture(&block), options), block.binding
    end

    def tag_without_block(tag_name, *args)
      content  = args.first.is_a?(Hash) ? nil : args.shift
      options = args.first.is_a?(Hash) ? args.shift : {}
      options.stringify_keys! 
      # still deciding syntax...
      # content = options.delete "content" if options.has_key? "content"

      if content
        content_tag(tag_name, content, options)
      else
        tag(tag_name, options, false)
      end
    end
  end
end