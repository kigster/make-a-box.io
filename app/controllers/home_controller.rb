class HomeController < ApplicationController

  before_filter :handle_cache_control,
                :load_parameters,
                :populate_form_fields,
                :handle_units_change


  def index
    if params['commit'] && request.post?
      not_cacheable!
      @config['file'] = exported_file_name
      begin
        @config.validate!
        generate_pdf @config
      rescue Exception => e
        @error = e.message
        Rails.logger.error(e.backtrace.join("\n"))
        # TODO: delete the temp file!
      end
    end
  end

  private
  def handle_cache_control
    if request.get? && params[:config].nil?
      expires_in 15.minutes, :public => true, must_validate: true
    end
  end

  def load_parameters
    @config = Laser::Cutter::Configuration.new(params[:config] || {})
  end

  def populate_form_fields
    %w(width height depth thickness notch page_size).each do |f|
      @config[f] = nil if @config[f] == 0.0 || @config[f] == ""
    end
    @page_size_options = Laser::Cutter::PageManager.new(@config.units).page_size_values.map do |v|
      digits = @config.units.eql?('in') ? 1 : 0
      [sprintf("%s %4.#{digits}f x %4.#{digits}f", *v), sprintf("%s", v[0])]
    end
    @page_size_options.insert(0, ["Auto Fit the Box", ""])
  end

  def handle_units_change
    if params['units'] && params['units'] != @config.units
      @config.units = params['units']
      @config.change_units(params['units'] == 'in' ? 'mm' : 'in')
    end
  end

  def exported_file_name
    "/tmp/makeabox-io-#{@config.width}x#{@config.height}x#{@config.depth}-#{rand(10000)}.box.pdf"
  end

  def generate_pdf(config)
    r = Laser::Cutter::Renderer::LayoutRenderer.new(config)
    r.render
    self.temp_files << config['file']
    send_file config['file'], type: 'application/pdf; charset=utf-8', status: 200
  end


end