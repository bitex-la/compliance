module ArbreHelpers
  class HtmlHelper
    def self.show_links(context, links)
      context.instance_eval do 
        div class: 'external_links' do
          links.each_with_index do |link, index|
            span link_to("Link ##{index + 1}",
              link,
              target: '_blank'
            )
            br
          end
        end
      end
    end

    def self.has_many_links(context, builder, links, title)
      context.instance_eval do
        unless links.blank?
          builder.template.concat("<li class='external_links'>".html_safe) 
          builder.template.concat("<label>#{title}</label><br />".html_safe)
          links.each_with_index do |link, index|
            builder.template.concat( 
              context.link_to("Link ##{index + 1}",
                link,
                target: '_blank'
              )
            )
            builder.template.concat('<br/>'.html_safe)
          end
          builder.template.concat('</li>'.html_safe)
        end 
      end
    end

    def self.extra_info_renderer(context, data)
      context.instance_eval do |ctx|
        div class: 'extra_info' do 
          ArbreHelpers::HtmlHelper.render_extra_info_list(ctx, data)
        end
      end
    end

    def self.render_extra_info_list(context, data)    
      if data.is_a?(Array)
        ArbreHelpers::HtmlHelper.render_extra_info_array(context, data)
      else 
        ArbreHelpers::HtmlHelper.render_extra_info_hash(context, data)
      end
    end

    def self.render_extra_info_array(context, data)
      context.instance_eval do
        data.each do |value|
          if ArbreHelpers::HtmlHelper.is_a_list?(value)
            hr
            ArbreHelpers::HtmlHelper.render_extra_info_list(context, value)
          else 
            div do
              ArbreHelpers::HtmlHelper.render_link_or_text(context, nil, value.to_s)
            end
          end
        end
      end
    end

    def self.render_extra_info_hash(context, data)
      data.keys.each do |key|
        label = key
        value = data[key]
        if ArbreHelpers::HtmlHelper.is_a_list?(value)  
          ArbreHelpers::HtmlHelper.render_extra_info_list(context, value)
        else 
          ArbreHelpers::HtmlHelper.render_link_or_text(context, label, value.to_s)
        end
      end
    end

    def self.json_renderer(context, data)
      context.instance_eval do |ctx|
        context.concat("<li class='extra_info'>".html_safe) 
        context.concat('<h4>Extra info</h4>'.html_safe) 
        ArbreHelpers::HtmlHelper.render_list(ctx, data)
        context.concat('</li>'.html_safe)
      end
    end

    def self.render_list(context, data)
      if data.is_a?(Array)
        ArbreHelpers::HtmlHelper.render_array(context, data)
      else 
        ArbreHelpers::HtmlHelper.render_hash(context, data)
      end
    end

    def self.is_a_list?(data)
      data.is_a?(Array) || data.is_a?(Hash)
    end
  
    def self.render_array(context, data)
      context.concat('<ul>'.html_safe)
      data.each do |value|
        if ArbreHelpers::HtmlHelper.is_a_list?(value)
          context.concat('<hr/>'.html_safe)
          value = ArbreHelpers::HtmlHelper.render_list(context, value)
        else
          context.concat('<li>'.html_safe) 
          ArbreHelpers::HtmlHelper.render_text_or_link(context, nil, value.to_s)
          context.concat('</li>'.html_safe)
        end
      end
      context.concat('</ul>'.html_safe) 
    end
  
    def self.render_hash(context, data)
      context.concat('<li>'.html_safe) 
      data.keys.each do |key|
        label = key
        value = data[key]
        if ArbreHelpers::HtmlHelper.is_a_list?(value)  
          ArbreHelpers::HtmlHelper.render_list(context, value)
        else
          ArbreHelpers::HtmlHelper.render_text_or_link(context, label, value.to_s)
        end
      end
      context.concat('</li>'.html_safe) 
    end

    def self.render_text_or_link(context, key, text)
      context.concat("<strong>#{key}: </strong>".html_safe) if key
      if text.starts_with?('http') || text.starts_with?('ftp') || text.starts_with?('https')
        context.concat("<a href='#{text}' target='_blank'>#{text.truncate(40, omission:'...')}</a><br/>".html_safe) 
      else
        context.concat("#{text}<br/>".html_safe) 
      end
    end

    def self.render_link_or_text(context, key, text)
      context.instance_eval do
        strong "#{key}: "
        if text.starts_with?('http') || text.starts_with?('ftp') || text.starts_with?('https')
          span do
            link_to text.truncate(40, omission:'...'), text, target: "_blank"
          end
        else
          span text
        end
        br
      end
    end
  end
end