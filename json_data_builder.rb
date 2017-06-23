module ExportBin
  class JsonDataBuilder
    def self.build_data_json(assets_dir, language, export_bin)
      images_dir = "#{assets_dir}/images"
      videos_dir = "#{assets_dir}/videos"
      sounds_dir = "#{assets_dir}/sounds"

      json = ExportBin::JsonDataClient.load_json(export_bin)
      template_instance_assets = TemplateInstanceAssets.new(assets_dir)

      if json['message'] != "Response status code does not indicate success: 403 (Forbidden)."
        result = {
            images: load_files(json, language, images_dir, template_instance_assets, 'images'),
            texts: load_texts(json, language),
            videos: load_files(json, language, videos_dir, template_instance_assets, 'videos'),
            sounds: load_files(json, language, sounds_dir, template_instance_assets, 'sounds')
        }
      end
      create_thumbnails(template_instance_assets)

      result
    end

    def self.download_image(assets_dir, language, export_bin, name)
      images_dir = "#{assets_dir}/images/crop"
      json = ExportBin::JsonDataClient.load_json(export_bin)
      if json['message'] != "Response status code does not indicate success: 403 (Forbidden)."
        load_image(json, language, images_dir, name,)
      end

    end

    private_class_method

    def self.load_image(remote_json, language, load_files_dir, name)
      asset_groups = remote_json['AssetGroups']
      if asset_groups.present?
        asset_groups.each do |asset_group|
          entities = asset_group['Entities']
          if entities.present?
            entities.each do |entity|
              entity['LanguageCodes'].each do |language_code|
                name_from_json = "#{asset_group['GroupId']}-#{entity['Filename']}"
                if language_code == language && File.basename(name, File.extname(name)) == name_from_json
                  return load_image_to_folder_final(entity, load_files_dir, asset_group['GroupId'])
                end
              end
            end
          end
        end
      end

      return nil
    end

    def self.image_exist(language, export_bin, name)
      json = ExportBin::JsonDataClient.load_json(export_bin)
      if json['message'] != "Response status code does not indicate success: 403 (Forbidden)."
        return existing_image(json, language, name)
      end
    end

    def self.existing_image(remote_json, language, name)
      asset_groups = remote_json['AssetGroups']
      if asset_groups.present?
        asset_groups.each do |asset_group|
          entities = asset_group['Entities']
          if entities.present?
            entities.each do |entity|
              entity['LanguageCodes'].each do |language_code|
                name_from_json = "#{asset_group['GroupId']}-#{entity['Filename']}"
                if language_code == language && File.basename(name, File.extname(name)) == name_from_json
                  return true
                end
              end
            end
          end
        end
      end

      return false
    end

    def self.load_files(remote_json, language, load_files_dir, template_instance_assets, type_of_files)
      asset_groups = remote_json['AssetGroups']
      if asset_groups.present?
        asset_groups.each do |asset_group|
          entities = asset_group['Entities']
          if entities.present?
            entities.each do |entity|
              entity['LanguageCodes'].each do |language_code|
                if language_code == language
                  if type_of_files=='images'
                    load_image_to_folder(entity, load_files_dir, asset_group['GroupId'])
                  elsif type_of_files=='videos'
                    load_video_to_folder(entity, load_files_dir, asset_group['GroupId'])
                  elsif type_of_files=='sounds'
                    load_sound_to_folder(entity, load_files_dir, asset_group['GroupId'])
                  end
                end
              end
            end
          end
        end
      end
      if type_of_files=='images'
        return add_files_info_to_base(load_files_dir, template_instance_assets.images_list)
      elsif type_of_files=='videos'
        return add_files_info_to_base(load_files_dir, template_instance_assets.videos_list)
      elsif type_of_files=='sounds'
        return add_files_info_to_base(load_files_dir, template_instance_assets.sounds_list)
      end
    end

    def self.load_image_to_folder(entity, images_dir, group_id)
      if is_image_expansion(entity['Filetype'])
        not_for_convert = ['PNG'].include? entity['Filetype'].upcase
        should_be_converted = ['TIF', 'PSD'].include? entity['Filetype'].upcase
        file_path = load_file(entity, images_dir, group_id)
        if File.exist?(file_path) && !not_for_convert
          make_preview(file_path, should_be_converted, false)
        end
      end
      if is_zip_expansion(entity['Filetype'])
        load_file(entity, images_dir.chomp('images') + 'zips', group_id)
      end
    end

    def self.load_image_to_folder_final(entity, images_dir, group_id)
      if is_image_expansion(entity['Filetype'])
        ext = entity['Filetype'].upcase
        not_for_convert = ['PNG'].include?(ext) || ['JPEG'].include?(ext) || ['JPG'].include?(ext)
        should_be_converted = ['TIF', 'PSD'].include? ext
        file_path = load_file(entity, images_dir, group_id)
        if File.exist?(file_path)
          if  !not_for_convert
            make_preview(file_path, should_be_converted, true)
          else
            file_path
          end
        else
          file_path
        end
      end
    end

    def self.make_preview(file_path, should_be_converted, use_original)
      tmp_dir = file_path.parent.join("tmp")
      tmp_file = tmp_dir.join(file_path.basename)

      FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)
      File.rename(file_path, tmp_file)
      if should_be_converted
        path = Images::ImagesUtils.convert_to_jpeg(tmp_file.basename, tmp_dir, file_path.parent)
        preview_path = Images::ImagesUtils.make_preview(path.basename, tmp_dir.parent, file_path.parent, use_original)
      else
        preview_path = Images::ImagesUtils.make_preview(tmp_file.basename, tmp_dir, file_path.parent, use_original)
      end
      File.delete(tmp_file) if File.exist?(tmp_file)

      preview_path
    end

    def self.load_sound_to_folder(entity, sounds_dir, group_id)
      if is_sound_expansion(entity['Filetype'])
        load_file(entity, sounds_dir, group_id)
      end
    end

    def self.load_video_to_folder(entity, videos_dir, group_id)
      if is_video_expansion(entity['Filetype'])
        load_file(entity, videos_dir, group_id)
      end
    end

    def self.load_file(entity, files_dir, group_id)
      file_name = entity["DownloadHighRes"]
      # file_name = entity["DownloadLowRes"]

      dirname = Rails.root.join("public/#{files_dir}")
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
      file_path = Rails.root.join("public/#{files_dir}/#{group_id}-#{entity['Filename']}.#{entity['Filetype']}")
      FileUtils.rm(file_path) if File.exist?(file_path)
      unless File.exist?(file_path)
        File.open(file_path, 'wb+') do |file|
          file.write(ExportBin::JsonDataClient.get_response_body_from_url(file_name))
          file.close
        end
      end
      file_path
    end

    def self.add_files_info_to_base(load_files_dir, files_list)
      files = files_list.map do |file_name|
        {title: File.basename(file_name, ".*"), path: "#{load_files_dir}/#{file_name}"}
      end
      files
    end

    def self.create_thumbnails(template_instance_images)
      template_instance_images.create_thumbnails
    end

    def self.load_texts(remote_json, language)
      fragment_groups = remote_json['FragmentGroups']
      result = []
      if fragment_groups.present?
        fragment_groups.each do |child|
          entities = child['Entities']
          if entities.present?
            entities.each do |entity|
              entity['LanguageCodes'].each do |language_code|
                if language_code == language
                  content_fields = entity['ContentFields']
                  content_fields.each do |content_field|
                    label = entity['Name'] + '/' + content_field['Label']
                    value = content_field['Value']
                    id = [child['GroupId'], entity['Name'], content_field['Label']]
                    if value != ''
                      js = {
                          title: label,
                          text: value,
                          id: id
                      }
                      result.push js
                    end
                  end
                end
              end
            end
          end
        end
      end
      result.map(&:symbolize_keys)
    end


    def self.is_image_expansion(image_type)
      ['PNG', 'JPG', 'JPEG', 'TIF', 'PSD'].include? image_type.upcase
    end

    def self.is_video_expansion(video_type)
      ['M4V', 'AVI', 'MP4'].include? video_type.upcase
    end

    def self.is_sound_expansion(video_type)
      ['MP3'].include? video_type.upcase
    end

    def self.is_zip_expansion(zip_type)
      ['ZIP'].include? zip_type.upcase
    end
  end
end
