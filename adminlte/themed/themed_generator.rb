module Adminlte
	class ThemedGenerator < Rails::Generators::Base
		source_root File.expand_path('../templates', __FILE__)

		argument :controller_path,  :type => :string
		argument :model_name,       :type => :string, :required => false

		class_option :layout,         :type => :string,   :default => 'application', :desc => 'Specify the layout name'
		class_option :engine,         :type => :string,   :default => 'erb', :desc => 'Specify the template engine'
		class_option :will_paginate,  :type => :boolean,  :default => false, :desc => 'Specify if you use will_paginate'
		class_option :themed_type,    :type => :string,   :default => 'crud', :desc => 'Specify the themed type, crud or text. Default is crud'

		def initialize(args, *options)
			super(args, *options)
			initialize_views_variables
		end

		def copy_views
			generate_views
		end

		protected

		def initialize_views_variables
			@base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(controller_path)
			@controller_routing_path = @controller_file_path.gsub(/\//, '_')
			@model_name = @base_name.singularize unless @model_name
			#@model_name = @model_name.camelize
		end

		def controller_routing_path
			@controller_routing_path
		end

		def singular_controller_routing_path
			@controller_routing_path.singularize
		end

		def model_name
			@model_name
		end

		def plural_model_name
			@model_name.downcase.pluralize
		end

		def plural_table_name
			@model_name.downcase.pluralize
		end

		def human_name
			@model_name.humanize
		end

		def singular_table_name
			@model_name.downcase.singularize
		end

		def resource_name
			@model_name.underscore
		end

		def plural_resource_name
			resource_name.pluralize
		end

		def attributes
			columns
		end

		def columns
			excluded_column_names = %w[id created_at updated_at]
			@model_name.camelize.constantize.columns.reject{|c| excluded_column_names.include?(c.name) }
		end

		def extract_modules(name)
			modules = name.include?('/') ? name.split('/') : name.split('::')
			name    = modules.pop
			path    = modules.map { |m| m.underscore }
			file_path = (path + [name.underscore]).join('/')
			nesting = modules.map { |m| m.camelize }.join('::')
			[name, path, file_path, nesting, modules.size]
		end

		def generate_views
			views = {
				'crud' => {
					'views/index.html.erb'  => File.join('app/views', @controller_file_path, "index.html.#{options.engine}"),
					'views/index.js.erb'  => File.join('app/views', @controller_file_path, "index.js.#{options.engine}"),
					'views/new.html.erb'     => File.join('app/views', @controller_file_path, "new.html.#{options.engine}"),
					'views/edit.html.erb'    => File.join('app/views', @controller_file_path, "edit.html.#{options.engine}"),
					'views/_form.html.erb'    => File.join('app/views', @controller_file_path, "_form.html.#{options.engine}"),
					"views/_table.html.erb"    => File.join('app/views', @controller_file_path, "_#{plural_table_name}.html.#{options.engine}"),
					'views/show.html.erb'    => File.join('app/views', @controller_file_path, "show.html.#{options.engine}"),
				}
			}
			selected_views = views[options.themed_type]
			generate_erb_views(selected_views)
		end

		def generate_erb_views(views)
			views.each do |template_name, output_path|
				template template_name, output_path
			end
		end

		def field_type(type)
			case type
			when :integer              then :number_field
			when :float, :decimal      then :text_field
			when :time                 then :time_select
			when :datetime, :timestamp then :datetime_select
			when :date                 then :date_select
			when :text                 then :text_area
			when :boolean              then :check_box
			else
				:text_field
			end
		end

	end
end