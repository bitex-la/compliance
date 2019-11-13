class ImageConverter

  def self.heic_to_jpg(file_name)
    path = Pathname.new("/tmp/#{file_name.gsub('.heic', '')}.jpg")

    decode_base64_image(params[:data][:attributes][:document], file_name)
    convert_heic_to_jpg("/tmp/#{file_name.gsub('.heic', '')}")

    new_encode64 = Base64.encode64(path.read).delete!("\n")
    File.delete("/tmp/#{file_name}")
    File.delete("/tmp/#{file_name.gsub('.heic', '')}.jpg")
    [
      ['data:image/jpg;base64,', new_encode64].join(''),
      'image/jpg',
      file_name.gsub('.heic', '.jpg')
    ]
  end

  def self.decode_base64_image(image_data, file_name)
    base64_no_metadata = image_data['data:image/heic;base64,'.length..-1]
    decoded_data = Base64.decode64(base64_no_metadata)

    File.open("/tmp/#{file_name}", 'wb') do |f|
      f.write(decoded_data)
    end
  end

  def self.convert_heic_to_jpg(file_name)
    `heif-convert #{file_name}.heic #{file_name}.jpg`
  end

end