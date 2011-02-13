require 'sha1'
module RailsDebuggingToolbar
  module Extensions
    module ActionController
      def view_context
        returning(super) do |view|
          extension_module = ::RailsDebuggingToolbar::Extensions::ActionView
          view.extend(extension_module) unless view.kind_of? extension_module
        end
      end
    end
    module ActionView
      def render(options = {}, local_assigns = {}, &block)
        actual_output = super(options, local_assigns, &block)
        id = next_available_render_id

        record_render_details(id, options, local_assigns)

        return debug_log_after_body(actual_output) if actual_output.include? "</body>"

        wrapped_output(actual_output, id)
      end

      private
      attr_writer :my_render_depth
      def render_partial(options = {})
        actual_output = super(options)
        id = next_available_render_id

        on_entering_render
        record_render_details(id, options, {})
        on_leaving_render

        wrapped_output(actual_output, id)
      end

      def on_entering_render
        self.my_render_depth = my_render_depth.succ
      end
      def on_leaving_render
        self.my_render_depth = my_render_depth.pred
      end

      def wrapped_output(actual_output, id)
        open_wrapping = raw("<span class='render-debug partial' id='render-debug-wrapper-#{ h id}'>")
        close_wrapping = raw("</span>")
        
        # insert the wrapping spans, but staying inside any <body> / </body>
        output_with_open_wrapping = actual_output.rpartition(/<body\b.*?>/).insert(2, open_wrapping).join
        output_with_both_wrapping = output_with_open_wrapping.partition('</body>').insert(1, close_wrapping).join
        
        # open_wrapping + actual_output + close_wrapping
        raw(output_with_both_wrapping)
      end

      def debug_log_after_body(actual_output)
        puts "%%%%%%%%%%%%% Rendering debug log"
        puts caller
        
        debug_log = ERB.new(<<-HTML).result(binding)
          <div class='render-debug' id='debug-log'>
            <% recorded_render_details.each_pair do |id, stuff| %>
              <%
              recorded_options = stuff[:options]
              locals = recorded_options[:locals] || {}
              partial = recorded_options[:partial] || "unknown"
              unrecognized_options = recorded_options.reject do |option_name, option_value|
                [:locals, :partial].include? option_name
              end
              %>
              <div class="render-debug render-detail" id="render-debug-detail-<%= h id %>">
                <h3><label for="render-debug-wrapper-<%= h id %>"><code><%= h partial %></code></label></h3>
                <% if locals.any? %>
                  <h4><label for="render-debug-locals-<%= h id %>">Locals</label></h4>
                  <%= print_hash_as_html_for_debugging(locals) %>
                <% end %>

                <% if unrecognized_options.any? %>
                  <h4><label for="render-debug-options-<%= h id %>">Other options</label></h4>
                  <%= print_hash_as_html_for_debugging(unrecognized_options) %>
                <% end %>
              </div>
            <% end %>
          </div>
          <form action="#" class="render-debug" id="debug-show">
            <input type="checkbox" id="enable-debug-detail-checkbox" name="render" value="debug" accesskey="r" />
            <label for="enable-debug-detail-checkbox">Show rendering details (<kbd>r</kbd)>)</label>
            <input type="checkbox" id="debug-follows-cursor-checkbox" name="follow_cursor" checked="checked" accesskey="f" />
            <label for="debug-follows-cursor-checkbox">Debug follows cursor (<kbd>f</kbd)>)</label>
          </form>
          <style type="text/css">
            #debug-log {
              display: block; position: absolute; top: 0px; right: 0px; top: 0px; width: 300px; z-index: -1000;
              background: transparent;
              font-family: sans-serif;
              text-align: left;
              color: #ccc;
              border: none;
              overflow: hidden;
              height: 4px; /* just enough to know it's there */
            }
            #debug-log.active {
              display: block; position: fixed; top: 0px; right: 0px; top: 0px; width: 300px; z-index: 1000;
              background: black; opacity: 0.8;
              border: thin solid white;
              overflow: auto;
              height: 100%;
            }
            #debug-log .render-detail {
              display: none;
            }
            #debug-log .render-detail.active {
              display: block;
              border-top: thin dashed #777;
              padding-bottom: 1ex;
              padding-top: 1ex;
            }
            #debug-log h1,
            #debug-log h2,
            #debug-log h3,
            #debug-log h4,
            #debug-log h5,
            #debug-log h6
            {
              font-weight: bold;
              display: block;
              padding-top: 1ex;
              font-size: 20px;
              color: white;
            }
            #debug-log h3
            {
              color: #f13;
              text-align: center;
              height: auto;
              width: 80%;
              padding-left: 1em;
              padding-right: 1em;
            }
            #debug-log code {
              white-space: pre;
            }
            #debug-log dl {
              display: block;
            }
            #debug-log dt {
              display: block;
              margin-left: 0px;
              font-weight: bold;
            }
            #debug-log dd {
              display: block;
              margin-left: 2px;
              max-height: 4ex;
            }
            form#debug-show {
              display: block; position: fixed; bottom: 0px; left: 0px; width: 30em; z-index: 1000;
              background: black; opacity: 1.0;
              border: thin solid white;
            }
          </style>
          
          <script type="text/javascript">//<![CDATA
          // Load JQuery if it's not already present
          if (typeof(jQuery) === 'undefined') {
            document.write('<scr' + 'ipt type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></scr' + 'ipt>');
          }
          // ]>
          </script>
          <script type="text/javascript">//<![CDATA
          (function ($) {
            $(function() {
              var show_bar_checkbox = $("input#enable-debug-detail-checkbox");
              var follow_cursor_checkbox = $("input#debug-follows-cursor-checkbox");
              var should_follow_cursor = $(follow_cursor_checkbox).is(':checked');
              
              show_bar_checkbox.change(function() {
                if ($(show_bar_checkbox).is(':checked')) {
                  $("#debug-log").addClass("active");
                } else {
                  $("#debug-log").removeClass("active");
                  $(".render-debug.partial").unbind();
                }
              });
              follow_cursor_checkbox.change(function() {
                should_follow_cursor = $(follow_cursor_checkbox).is(':checked');
                if (should_follow_cursor) {
                  // a clean slate for mousing around
                  $("#debug-log .render-detail.active").removeClass("active");
                }
              });
              $(".render-debug.partial").hover(function() {
                if (!should_follow_cursor) { return true; }
                
                var detail_div = $("label[for=" + this.id + "]").parents("#debug-log .render-detail");
                detail_div.addClass("active");
              }, function() {
                if (!should_follow_cursor) { return true; }
                
                var detail_div = $("label[for=" + this.id + "]").parents("#debug-log .render-detail");
                detail_div.removeClass("active");
              });
              
            });
          })(jQuery);
          //]>
          </script>
        HTML
        output_with_debug_log = actual_output.sub("</body>", debug_log + raw("</body>"))
        @debug_log_rendered = true
        output_with_debug_log
      end

      def my_render_depth
        @some_render_depth ||= 0
      end

      def at_outer_level_render?
        (my_render_depth == 0)
      end

      def next_available_render_id
        @render_id_counter ||= 0
        @render_id_counter += 1 # XXX: totally not thread safe
        @render_id_counter
      end

      def record_render_details(id, options, local_assigns)
        recorded_render_details[id] = {:options => options, :local_assigns => local_assigns}
      end

      def recorded_render_details
        @recorded_render_details ||= {}
      end
      
      def print_as_html_for_debugging(subject)
        return h subject.relative_path if subject.respond_to? :relative_path
        return h subject.path if subject.respond_to? :path
        return print_as_html_for_debugging if subject.respond_to? :each_pair
        ERB.new("<code><%= h subject.inspect %></code>").result(binding)
      end
      
      def print_hash_as_html_for_debugging(hsh)
        ERB.new(<<-HTML).result(binding)
          <dl>
            <% hsh.each_pair do |key, value| %>
              <dt><%= h key %></dt>
              <dd><%= print_as_html_for_debugging(value) %></code></dd>
            <% end %>
          </dl>
        HTML
      end

    end
  end
end
