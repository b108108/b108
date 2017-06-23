require 'find'
require 'rmagick'
require 'fileutils'

module ExportBin
  class DataProvider
    def initialize(template_instance_id, assets_dir)
      @template_instance_id = template_instance_id
      @assets_dir = assets_dir
    end

    def load_data
      template_instance = ArticleTemplateInstance.find(@template_instance_id)
      export_bins = template_instance.data_json_url.split(",")
      Hash[export_bins.map do |export_bin|
        [export_bin, ExportBin::JsonDataBuilder.build_data_json("#{@assets_dir}/#{export_bin}", template_instance.language, export_bin)]
      end]
    end

    def load_original
      template_instance = ArticleTemplateInstance.find(@template_instance_id)
      assets = Article::Generator.new(template_instance, '', '').find_images_sounds_and_videos_with_sizes
      to_download = assets.select { |path| path[:path].start_with?('template-instances/') && (path[:path].end_with?('.jpeg') || path[:path].upcase.end_with?('.PNG')) }

      dirname = Rails.root.join("public/#{@assets_dir}")


      template_instance = ArticleTemplateInstance.find(@template_instance_id)
      to_download.each do |info|

        path = info[:path]

        if path.end_with?('.jpeg')
          elements = path.split('/')
          export_bin = elements[3]
          name = elements[5]

          exist = ExportBin::JsonDataBuilder.image_exist(template_instance.language, export_bin, name)
          if exist
            file_path = Rails.root.join("public").join(path)
            if File.exist?(file_path)
              width_ratio = select_max_path_for_path(path, to_download)
              unless width_ratio
                width_ratio = "100"
              end


              images_config = YAML.load(ERB.new(File.read(Rails.root + 'config' + 'images.yml')).result)
              config_width = images_config[Rails.env]['width']
              width = width_ratio.to_f * config_width / 100

              tmp_dir = file_path.parent.join("tmp")
              tmp_file = tmp_dir.join(file_path.basename)

              FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)
              File.rename(file_path, tmp_file)
              Images::ImagesUtils.remake_make_preview(tmp_file.basename, tmp_dir, file_path.parent, width)
              File.delete(tmp_file) if File.exist?(tmp_file)
            end
          else
            cropping = CroppingDetails.where("'#{File.basename(name, File.extname(name))}' = concat_ws('-', file_name, cropping_name)").first()
            if cropping
              original_file = ExportBin::JsonDataBuilder.download_image("#{@assets_dir}/#{export_bin}", template_instance.language, export_bin, cropping.file_name + '.jpeg')

              img = Magick::Image.ping(original_file).first
              width = img.columns

              images_config = YAML.load(ERB.new(File.read(Rails.root + 'config' + 'images.yml')).result)
              config_width = images_config[Rails.env]['width']

              crop_ratio = width.to_f/config_width
              if crop_ratio < 1
                crop_ratio = 1
              end

              srop_info = cropping.cropping_area.split ','
              crop_x = srop_info[0].to_i * crop_ratio
              crop_y = srop_info[1].to_i * crop_ratio
              crop_w = srop_info[2].to_i * crop_ratio
              crop_h = srop_info[3].to_i * crop_ratio
              path = File.dirname File.dirname original_file
              FileUtils.rm(path + '/' + name) if File.exist?(path + '/' + name)
              Images::ImagesUtils.crop(original_file, path + '/' + name, crop_x, crop_y, crop_w, crop_h)

              # was_downloaed = was_downloaed(original_file, to_download)
              FileUtils.rm(original_file)
              FileUtils.rm_rf(File.dirname original_file)
            end

          end
        end

      end
      file_to_delete = []

      export_bins = template_instance.data_json_url.split(",")

      not_delete = to_download.collect {|i| i[:path] }
      export_bins.each do |b|
        dir = dirname.join(b)
        Find.find(dir) do |d|
          was_downloaded = was_downloaed(d, not_delete)
          file_to_delete << d if (d =~ /.*\.jpeg$/ || d =~ /.*\.jpg$/ || d =~ /.*\.png/) && !was_downloaded
        end
      end


      file_to_delete.each do |f|
        FileUtils.rm(f)
      end
    end

    def select_max_path_for_path(path, to_download)
      to_download.select { |p| p[:path] == path}.max_by{|x| x[:image_width] ? x[:image_width].to_f : 100}[:image_width];
    end

    def was_downloaed(path, to_download)
      count = Rails.root.join("public/").to_s.length
      path_as_string = path.to_s
      p = path_as_string[count, path_as_string.length]
      was_downloaded = (to_download.include?(p))
      was_downloaded
    end
  end
end
